#!/usr/bin/env python3
import argparse
import numpy as np
from collections import OrderedDict

def pop_order_from_popmap(path):
    seen = OrderedDict()
    with open(path) as f:
        for line in f:
            s = line.strip()
            if not s: continue
            sid, pop = s.split("\t")
            if pop not in seen:
                seen[pop] = None
    return list(seen.keys())

p = argparse.ArgumentParser(description="Remove dummy population columns from WGSassign .pop_af.npy")
p.add_argument("--pop-af", required=True, help=".pop_af.npy produced by WGSassign")
g = p.add_mutually_exclusive_group(required=True)
g.add_argument("--pop-names", help="Text file with one population name per line matching AF columns")
g.add_argument("--pop-af-IDs", help="The pop_af_IDs file used to build AFs (to infer column order)")
p.add_argument("--drop", nargs="+", required=True, help="Population name(s) to drop, e.g., DROPPED")
p.add_argument("--out-pop-af", required=True, help="Output cleaned .pop_af.npy")
p.add_argument("--out-pop-names", required=True, help="Output pop_names.txt for the cleaned AFs")
args = p.parse_args()

af = np.load(args.pop_af)  # shape (L, K)
if args.pop_names:
    names = [line.strip() for line in open(args.pop_names) if line.strip()]
else:
    names = pop_order_from_popmap(args.pop_af_IDs)

if af.shape[1] != len(names):
    raise SystemExit(f"Mismatch: AF columns={af.shape[1]} vs names={len(names)}")

drop_set = set(args.drop)
keep_idx = [i for i, n in enumerate(names) if n not in drop_set]
if not keep_idx:
    raise SystemExit("After dropping, no populations remain.")
af_keep = af[:, keep_idx]
names_keep = [names[i] for i in keep_idx]

np.save(args.out_pop_af, af_keep)
with open(args.out_pop_names, "w") as f:
    f.write("\n".join(names_keep) + "\n")
print(f"Original {af.shape} -> cleaned {af_keep.shape}")
