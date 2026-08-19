#!/usr/bin/env python3
"""Sample verified outputs for blinded human audit of semantic judge decisions."""
import argparse, csv, json, random
from pathlib import Path

def main():
    p=argparse.ArgumentParser(); p.add_argument('--root',type=Path,default=Path('/u/mjha1/Proof2Silicon/journal_phase/journal_eval'))
    p.add_argument('--n',type=int,default=150); p.add_argument('--seed',type=int,default=20260811)
    p.add_argument('--output',type=Path,default=None); a=p.parse_args(); rng=random.Random(a.seed)
    yes=[]; no=[]
    for cond in a.root.iterdir():
        tdir=cond/'trajectories'
        if not tdir.is_dir(): continue
        for path in tdir.glob('*.json'):
            d=json.loads(path.read_text())
            for att in d.get('attempts',[]):
                if not att.get('verifier_success'): continue
                item={'condition':cond.name,'task_id':d.get('task_id'),'sample_or_attempt':att.get('sample_or_attempt'),'task_file':str(path),'dafny_code':att.get('dafny_code',''),'judge_raw':(att.get('semantic_metadata') or {}).get('raw',''),'judge_label':att.get('semantic_aligned')}
                (yes if att.get('semantic_aligned') else no).append(item)
    rng.shuffle(yes); rng.shuffle(no)
    target=a.n; half=target//2
    chosen=yes[:half]+no[:target-half]
    if len(chosen)<target:
        pool=yes[half:]+no[target-half:]; rng.shuffle(pool); chosen += pool[:target-len(chosen)]
    rng.shuffle(chosen)
    out=a.output or (a.root/'semantic_human_audit.csv')
    fields=['audit_id','condition','task_id','sample_or_attempt','task_file','dafny_code','human_same_task','human_notes','judge_label_hidden','judge_raw_hidden']
    with out.open('w',newline='',encoding='utf-8') as f:
        w=csv.DictWriter(f,fieldnames=fields); w.writeheader()
        for i,x in enumerate(chosen,1):
            w.writerow({'audit_id':i,'condition':x['condition'],'task_id':x['task_id'],'sample_or_attempt':x['sample_or_attempt'],'task_file':x['task_file'],'dafny_code':x['dafny_code'],'human_same_task':'','human_notes':'','judge_label_hidden':x['judge_label'],'judge_raw_hidden':x['judge_raw']})
    print(f'wrote {len(chosen)} verified examples to {out}')
    print('For a blinded annotation, hide the final two columns before giving the sheet to annotators.')
if __name__=='__main__': main()
