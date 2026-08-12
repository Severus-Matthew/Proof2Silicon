#!/usr/bin/env python3
"""Cheap preflight for journal evaluation: files, Dafny, credentials and API models."""
import argparse, os, shutil, sys
from pathlib import Path
from test_journal import POLICY_CHECKPOINTS, parse_model_spec, call_model

ROOT = Path('/u/mjha1/Proof2Silicon/journal_phase')
DEFAULT_MODELS = [
    'openai:gpt-5.4-mini',
    'openai:gpt-5.4',
    'hf:Qwen/Qwen3-Coder-30B-A3B-Instruct:featherless-ai',
    'hf:deepseek-ai/DeepSeek-V3.1',
    'hf:Qwen/Qwen3-Coder-Next',
    'hf:zai-org/GLM-4.5-Air',
    'hf:mistralai/Devstral-Small-2-24B-Instruct-2512',
]

def main():
    p=argparse.ArgumentParser(); p.add_argument('--models',nargs='*',default=DEFAULT_MODELS); p.add_argument('--skip-api',action='store_true'); a=p.parse_args()
    failures=[]; dataset=ROOT/'Input_dataset_3'
    if not dataset.is_dir(): failures.append(f'missing dataset: {dataset}')
    else:
        n=sum(1 for x in dataset.iterdir() if x.is_dir()); print('dataset task folders:',n)
        if n==0: failures.append('Input_dataset_3 has zero task folders')
    for name,path in POLICY_CHECKPOINTS.items():
        ok=path.is_file() and path.stat().st_size>0; print(f'checkpoint {name}:','OK' if ok else 'MISSING',path)
        if not ok: failures.append(f'missing checkpoint {name}: {path}')
    dafny=shutil.which('dafny'); print('dafny:',dafny or 'MISSING')
    if not dafny: failures.append('dafny executable not found')
    print('OPENAI_API_KEY:','set' if os.environ.get('OPENAI_API_KEY') else 'MISSING'); print('HF_TOKEN:','set' if os.environ.get('HF_TOKEN') else 'MISSING')
    if not os.environ.get('OPENAI_API_KEY'): failures.append('OPENAI_API_KEY missing')
    if not os.environ.get('HF_TOKEN'): failures.append('HF_TOKEN missing')
    if not a.skip_api and not failures:
        for raw in a.models:
            spec=parse_model_spec(raw)
            try:
                text,_,_=call_model(spec,'Reply with exactly OK.','OK',max_tokens=8,reasoning='low' if spec.provider=='openai' else None,temperature=0.0,retries=2)
                print(f'model {raw}: OK ({text[:60]!r})')
            except Exception as e:
                print(f'model {raw}: FAILED ({e})'); failures.append(f'model unavailable: {raw}: {e}')
    if failures:
        print('\nPREFLIGHT FAILED:'); [print(' -',x) for x in failures]; sys.exit(1)
    print('\nPREFLIGHT PASSED')
if __name__=='__main__': main()
