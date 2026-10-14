#!/usr/bin/env python3
import argparse, sys

p = argparse.ArgumentParser(description="Create ordered --pop_af_IDs; mask non-kept samples to DROPPED.")
p.add_argument("--base-pop", required=True, help="Your in-order 2-col file: sample_id<TAB>population (Reference_ID_WGAassign.txt)")
p.add_argument("--keep", required=True, help="keep_all.txt: sample IDs to KEEP this iteration (one per line)")
p.add_argument("--out", required=True, help="Output pop_af_IDs file for this iteration")
p.add_argument("--dropped-name", default="DROPPED", help="Name to assign to masked samples (default: DROPPED)")
args = p.parse_args()

keep = set(x.strip() for x in open(args.keep) if x.strip())
n = 0
with open(args.base_pop) as fin, open(args.out, "w") as fout:
    for line in fin:
        if not line.strip(): continue
        sid, pop = line.rstrip("\n").split("\t")
        if sid not in keep:
            pop = args.dropped_name
        fout.write(f"{sid}\t{pop}\n")
        n += 1
sys.stderr.write(f"Wrote {n} rows to {args.out}\n")
