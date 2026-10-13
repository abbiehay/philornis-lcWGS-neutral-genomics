#!/bin/bash
set -euo pipefail

# Generate genotype likelihoods and called genotypes for the retained unlinked SNPs.
# Use the indexed positions file identified by ngsLD and prune_graph.
# The input positions have already undergone SNP filtering and LD pruning, so no additional SNP or MAF filtering thresholds are applied here.
# The .pos file must be indexed before use with -sites.

# 169 individuals

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
AUTOSOMES="path/to/reference_genome/high_confidence_autosome_scaffolds.txt"
ANGSD="path/to/angsd"

PREFIX="Galap24_autosome_noRelated_HWE1e06_unlinked_50kb_r2_05"
RESULT_DIR="${RESULTS}/Galap24_autosome_noRelated_HWE1e-06_unlinked_dist50kb_r2_05"
SITES="${RESULTS}/Galap24_autosome_noRelated_HWE1e-06/Galap24_autosome_noRelated_HWE1e06_UnlinkedSites_r2_05_formatted.pos"

"${ANGSD}" \
  -b "${SAMPLELISTS}/Bams_u30MD_70minInd_noRelated.txt" \
  -ref "${REFERENCE}" \
  -out "${RESULT_DIR}/${PREFIX}" \
  -rf "${AUTOSOMES}" \
  -sites "${SITES}" \
  -GL 2 -doGlf 2 -doMajorMinor 1 -doMaf 1 \
  -doPost 1 -doGeno 32 -doPlink 0 -doBcf 1 \
  -minMapQ 20 -minQ 20 \
  -nThreads 8 -nQueueSize 10 \
  > "${LOGS}/${PREFIX}.log" 2>&1

# 33,638 sites retained
# Final filtered neutral SNP dataset used for downstream analyses
