#!/bin/bash

# Parameter descriptions
# Further details can be found in ANGSD manual: popgen.dk/angsd/index.php/Main_Page, and the Physalia lcWGS GitHub: https://github.com/nt246/physalia-lcwgs/blob/main/day_2/markdowns/01_filtering.md
# -b: Input BAM file list.
# -ref: Reference genome.
# -out: Output directory and filename prefix.
# -uniqueOnly: Filter for uniquely mapped reads.
# -remove_bads: Remove reads with poor alignments.
# -only_proper_pairs: Retain properly paired reads.
# -C: Adjust mapping quality based on mismatches.
# -baq: Enable base alignment quality recalibration.
# -minMapQ: Read mapping quality filter.
# -minQ: Base quality filter.
# -minInd: Minimum number of individuals required per site.
# -setMinDepthInd: Read depth per individual.
# -setMinDepth: Total read depth per site.
# -setMaxDepth: Maximum total read depth per site.
# -doCounts: Calculate allele counts.
# -nThreads: Number of processing threads.

# 1. Initial SNP calling: Generate BCF file with hard-called genotypes and a Beagle genotype likelihood file.
# 219 individuals; mean depth 3.17x
# -minInd 153: 70% of individuals
# -setMaxDepth 2083: Mean depth * 3 * number of individuals

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
ANGSD="path/to/angsd"

"${ANGSD}" -b "${SAMPLELISTS}/ALL_bams.txt" 
-ref "${REFERENCE}" 
-out "${RESULTS}/SNPcall_55/SNPcall_55" 
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 1 -trim 0 
-minMapQ 20 -minQ 20 -minInd 153 -setMinDepthInd 1 -setMaxDepth 2083 -doCounts 1 
-GL 2 -doMajorMinor 1 -doMaf 1 -minMaf 0.02 -SNP_pval 1e-6 -rmTriallelic 0.05 
-doPost 1 -doGeno 32 -doPlink 0 -doBcf 1 
-nThreads 8 -nQueueSize 10 \
> "${LOGS}/SNPcall_55.log" 2>&1

# 4951 sites retained