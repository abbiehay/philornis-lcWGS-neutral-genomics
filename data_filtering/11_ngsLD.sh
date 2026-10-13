#!/bin/bash
set -euo pipefail

# Estimate linkage disequilibrium using ngsLD.
#
# Input: ANGSD Beagle genotype-likelihood file and MAF file.
# 169 individuals; 55,070 SNPs.
# No maximum distance limit is applied during LD estimation.

NGSLD="path/to/ngsLD/ngsLD"
RESULTS="path/to/angsd_pipeline/angsd_results/Galap24_autosome_noRelated_HWE1e-06"

PREFIX="Galap24_autosome_noRelated_HWE1e06"

BEAGLE="${RESULTS}/${PREFIX}.beagle.gz"
MAFS="${RESULTS}/${PREFIX}.mafs.gz"
POSITIONS="${RESULTS}/${PREFIX}_positions_with_chrom.txt"
LD_OUT="${RESULTS}/${PREFIX}.ld"

N_IND=169
N_SITES=55070
N_THREADS=15

# Extract scaffold names and SNP positions from the MAF file.
zcat "${MAFS}" | cut -f1,2 > "${POSITIONS}"

# Estimate pairwise linkage disequilibrium.
"${NGSLD}" \
  --geno "${BEAGLE}" \
  --probs \
  --posH "${POSITIONS}" \
  --n_ind "${N_IND}" \
  --n_sites "${N_SITES}" \
  --out "${LD_OUT}" \
  --n_threads "${N_THREADS}"

# Output: ${LD_OUT}
# Use this file as input for prune_graph.
