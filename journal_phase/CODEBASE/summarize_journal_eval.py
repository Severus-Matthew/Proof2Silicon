#!/usr/bin/env python3
"""Aggregate completed journal-eval conditions and compute paired significance.

Produces all_conditions.csv plus pairwise_stats.csv. Pairwise comparisons use
paired task IDs, McNemar's exact binomial test for binary aligned success, and a
paired bootstrap 95% CI for the success-rate difference.
"""
from __future__ import annotations
import argparse, csv, json, math, random
from pathlib import Path
from typing import Dict, List


def load_tasks(condition: Path) -> Dict[str, dict]:
    p=condition/'tasks.csv'
    if not p.exists(): return {}
    with p.open(encoding='utf-8') as f:
        return {r['task_id']:r for r in csv.DictReader(f)}

def b(v): return str(v).lower() in {'1','true','yes'}

def binom_two_sided(k,n):
    if n==0: return 1.0
    k=min(k,n-k)
    p=2.0*sum(math.comb(n,i) for i in range(k+1))/(2**n)
    return min(1.0,p)

def bootstrap_diff(a,bv,iters=10000,seed=20260811):
    rng=random.Random(seed); n=len(a)
    if n==0: return (0.0,0.0,0.0)
    obs=sum(x-y for x,y in zip(a,bv))/n
    vals=[]
    for _ in range(iters):
        vals.append(sum(a[i]-bv[i] for i in (rng.randrange(n) for __ in range(n)))/n)
    vals.sort(); return obs, vals[int(.025*iters)], vals[min(iters-1,int(.975*iters))]

def main():
    p=argparse.ArgumentParser(); p.add_argument('--root',type=Path,default=Path('/u/mjha1/Proof2Silicon/journal_phase/journal_eval'))
    p.add_argument('--bootstrap-iters',type=int,default=10000); a=p.parse_args()
    conditions=[x for x in sorted(a.root.iterdir()) if x.is_dir() and (x/'summary.json').exists()]
    summaries=[]
    for c in conditions:
        d=json.loads((c/'summary.json').read_text()); cfg=json.loads((c/'config.json').read_text()) if (c/'config.json').exists() else {}
        summaries.append({'condition':c.name,**{f'cfg_{k}':v for k,v in cfg.items() if k in {'instructor','policy','coder','evaluation_mode','feedback_mode','recursion_hint','adapter_scale','slm_decode','seed'}},**d})
    if summaries:
        keys=sorted({k for r in summaries for k in r})
        with (a.root/'all_conditions.csv').open('w',newline='',encoding='utf-8') as f:
            w=csv.DictWriter(f,fieldnames=keys); w.writeheader(); w.writerows(summaries)
    pairs=[]
    for i in range(len(conditions)):
        A=load_tasks(conditions[i])
        for j in range(i+1,len(conditions)):
            B=load_tasks(conditions[j]); ids=sorted(set(A)&set(B))
            if not ids: continue
            xa=[1 if b(A[t].get('any_aligned')) else 0 for t in ids]
            xb=[1 if b(B[t].get('any_aligned')) else 0 for t in ids]
            n10=sum(x==1 and y==0 for x,y in zip(xa,xb)); n01=sum(x==0 and y==1 for x,y in zip(xa,xb))
            diff,lo,hi=bootstrap_diff(xa,xb,a.bootstrap_iters)
            pairs.append({'condition_a':conditions[i].name,'condition_b':conditions[j].name,'n_paired':len(ids),'aligned_rate_a':sum(xa)/len(ids),'aligned_rate_b':sum(xb)/len(ids),'difference_a_minus_b':diff,'bootstrap95_lo':lo,'bootstrap95_hi':hi,'mcnemar_n10':n10,'mcnemar_n01':n01,'mcnemar_exact_p':binom_two_sided(min(n10,n01),n10+n01)})
    if pairs:
        with (a.root/'pairwise_stats.csv').open('w',newline='',encoding='utf-8') as f:
            w=csv.DictWriter(f,fieldnames=list(pairs[0])); w.writeheader(); w.writerows(pairs)
    print(f'conditions={len(conditions)} pairwise_comparisons={len(pairs)}')
    print(a.root/'all_conditions.csv'); print(a.root/'pairwise_stats.csv')
if __name__=='__main__': main()
