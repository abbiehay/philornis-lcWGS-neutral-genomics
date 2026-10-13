#!/bin/bash

# Parameter descriptions
# Further details can be found in the ANGSD manual: https://popgen.dk/angsd/index.php/Main_Page
# and the Physalia lcWGS GitHub: https://github.com/nt246/physalia-lcwgs/blob/main/day_2/markdowns/01_filtering.md
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
# -setMaxDepth: Maximum total read depth per site.
# -doCounts: Calculate allele counts.
# -GL: Specify the genotype likelihood model.
# -doGlf: Specify the genotype likelihood output format.
# -doMajorMinor: Infer major and minor alleles.
# -doMaf: Estimate minor allele frequencies.
# -minMaf: Minor allele frequency filter.
# -SNP_pval: SNP significance filter.
# -rmTriallelic: Filter triallelic sites.
# -nThreads: Number of processing threads.
# -nQueueSize: Number of jobs queued for processing.

# 2. SNP calling after excluding individuals with >30% missing data and <50% mapping efficiency.
# Generate a Beagle genotype likelihood file.
# 189 individuals; mean depth 3.31x
# -minInd 95: 50% of individuals (reduced from 70% to retain more SNPs after excluding individuals with high missingness and low mapping efficiency).
# -setMaxDepth 1877: Mean depth * 3 * number of individuals

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
ANGSD="path/to/angsd"

"${ANGSD}" -b "${SAMPLELISTS}/Bams_u30MD_70minInd.txt" \
-ref "${REFERENCE}" \
-out "${RESULTS}/SNPcall_58/SNPcall_58" \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 1 -trim 0 \
-minMapQ 20 -minQ 20 -minInd 95 -setMinDepthInd 1 -setMaxDepth 1877 -doCounts 1 \
-GL 2 -doGlf 2 -doMajorMinor 1 -doMaf 1 -minMaf 0.02 -SNP_pval 1e-6 -rmTriallelic 0.05 \
-nThreads 8 -nQueueSize 10 \
> "${LOGS}/SNPcall_58.log" 2>&1

# 70029 sites retained
# Next: Infer autosomal and sex-linked scaffolds using BeXY
