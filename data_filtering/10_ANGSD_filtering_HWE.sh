#!/bin/bash

# 5. Filtering to exclude variants with Hardy–Weinberg equilibrium (HWE) p-values <1e-6 across the full dataset.
# Individuals with >30% missing data and <50% mapping efficiency were excluded.# 55,070 sites retained.
# 169 individuals; mean depth 3.27x.

# -minInd 85: Require data from at least 50% of individuals.
# -setMaxDepth 1658: Mean depth * 3 * number of individuals.
# Generate genotype likelihoods in Beagle format and restrict SNP calling to high-confidence autosomal scaffolds.

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
AUTOSOMES="path/to/reference_genome/high_confidence_autosome_scaffolds.txt"
ANGSD="path/to/angsd"

"${ANGSD}" \
  -b "${SAMPLELISTS}/Bams_u30MD_70minInd_noRelated.txt" \
  -ref "${REFERENCE}" \
  -out "${RESULTS}/Galap24_autosome_noRelated_HWE1e-06/Galap24_autosome_noRelated_HWE1e06" \
  -rf "${AUTOSOMES}" \
  -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 1 -trim 0 \
  -minMapQ 20 -minQ 20 -minInd 85 -setMinDepthInd 1 -setMaxDepth 1658 -doCounts 1 \
  -GL 2 -doGlf 2 -doMajorMinor 1 -doMaf 1 -minMaf 0.02 -SNP_pval 1e-6 -rmTriallelic 0.05 \
  -doHWE 1 -minHWEpval 1e-6 \
  -nThreads 8 -nQueueSize 10 \
  > "${LOGS}/Galap24_autosome_noRelated_HWE06.log" 2>&1
  
# 55,070 sites retained.
# NEXT: Running ngsLD to infer highly linked SNPs