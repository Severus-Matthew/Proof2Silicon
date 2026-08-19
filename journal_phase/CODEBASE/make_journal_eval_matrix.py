#!/usr/bin/env python3
"""Generate tiered Proof2Silicon journal evaluation condition matrices."""
from __future__ import annotations
import argparse, csv
from pathlib import Path

CORE_CODERS = [
    "openai:gpt-5.4-mini",
    "openai:gpt-5.4",
    "hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai",
    "hf:deepseek-ai/DeepSeek-V3.1",
]
EXTENDED_CODERS = [
    "hf:Qwen/Qwen3-Coder-Next",
]
POLICIES=["openai","qwen","mixed"]; SEED=20260811

def add(rows,name,instructor,coder,*,policy="na",mode="repair",feedback="full",recursion=True,scale=1.0,decode="train_match",attempts=7,seed=SEED,external="openai:gpt-5.4"):
    rows.append({"name":name,"instructor":instructor,"policy":policy or "na","coder":coder,"evaluation_mode":mode,"feedback_mode":feedback,"recursion_hint":"1" if recursion else "0","adapter_scale":str(scale),"slm_decode":decode,"max_attempts":str(attempts),"seed":str(seed),"external_instructor_model":external})

def tag(coder): return coder.replace(":","_").replace("/","_")

def build(suite):
    rows=[]
    if suite in {"core","full"}:
        for coder in CORE_CODERS:
            t=tag(coder)
            for instr in ("none","untrained","self","external"): add(rows,f"{instr}__{t}",instr,coder)
            for policy in POLICIES: add(rows,f"trained_{policy}__{t}","trained",coder,policy=policy)
    if suite in {"transfer","full"}:
        for coder in EXTENDED_CODERS:
            t=tag(coder)
            for instr in ("none","untrained","self","external"): add(rows,f"transfer_{instr}__{t}",instr,coder)
            add(rows,f"transfer_mixed__{t}","trained",coder,policy="mixed")
    if suite in {"ablations","full"}:
        reps=[CORE_CODERS[0],CORE_CODERS[2]]
        for coder in reps:
            t=tag(coder)
            for policy in POLICIES:
                for scale in (0.0,0.25,0.5,1.0,1.5): add(rows,f"lora_{policy}_{scale:g}__{t}","trained",coder,policy=policy,scale=scale)
        for coder in reps:
            t=tag(coder)
            for decode in ("greedy","train_match"): add(rows,f"decode_mixed_{decode}__{t}","trained",coder,policy="mixed",decode=decode)
        for coder in reps:
            t=tag(coder)
            for instr,policy in (("none","na"),("untrained","na"),("trained","mixed")):
                for rec in (False,True): add(rows,f"rechint_{instr}_{policy}_{int(rec)}__{t}",instr,coder,policy=policy,recursion=rec)
        for coder in reps:
            t=tag(coder)
            for feedback in ("full","coder_only","none"): add(rows,f"feedback_mixed_{feedback}__{t}","trained",coder,policy="mixed",feedback=feedback)
    if suite in {"passk","full"}:
        reps=[CORE_CODERS[0],CORE_CODERS[2]]
        for coder in reps:
            t=tag(coder)
            for instr,policy in (("none","na"),("untrained","na"),("self","na"),("external","na"),("trained","mixed")):
                add(rows,f"passk_{instr}_{policy}__{t}",instr,coder,policy=policy,mode="independent",feedback="none",attempts=5)
    unique=[]; seen=set()
    for row in rows:
        key=tuple(row[k] for k in row if k!="name")
        if key not in seen: seen.add(key); unique.append(row)
    return unique

def main():
    p=argparse.ArgumentParser(); p.add_argument("--suite",choices=["core","transfer","ablations","passk","full"],default="full"); p.add_argument("--output",type=Path,required=True); a=p.parse_args()
    rows=build(a.suite); a.output.parent.mkdir(parents=True,exist_ok=True)
    with a.output.open("w",newline="",encoding="utf-8") as f:
        w=csv.DictWriter(f,fieldnames=list(rows[0]) if rows else [],delimiter="\t"); w.writeheader(); w.writerows(rows)
    print(f"Wrote {len(rows)} conditions to {a.output}")
if __name__=="__main__": main()
