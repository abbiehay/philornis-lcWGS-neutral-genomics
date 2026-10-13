#!/bin/bash

# Parameter descriptions
# Further details can be found in the ANGSD manual: https://popgen.dk/angsd/index.php/Main_Page
# and the Physalia lcWGS GitHub: https://github.com/nt246/physalia-lcwgs/blob/main/day_2/markdowns/01_filtering.md
# -b: Input BAM file list.
# -ref: Reference genome.
# -out: Output directory and filename prefix.
# -rf: Restrict SNP calling to high-confidence autosomal scaffolds.
# -uniqueOnly: Filter for uniquely mapped reads.
# -remove_bads: Remove reads with poor alignments.
# -only_proper_pairs: Retain properly paired reads.
# -baq: Enable base alignment quality recalibration.
# -trim: Number of bases trimmed from read ends.
# -minMapQ: Read mapping quality filter.
# -minQ: Base quality filter.
# -minInd: Minimum number of individuals required per site.
# -setMinDepthInd: Minimum read depth per individual.
# -setMaxDepth: Maximum total read depth per site.
# -doCounts: Calculate allele counts.
# -GL: Specify the genotype likelihood model.
# -doGlf: Specify the genotype likelihood output format.
# -doMajorMinor: Infer major and minor alleles.
# -doMaf: Estimate minor allele frequencies.
# -minMaf: Minor allele frequency filter.
# -SNP_pval: SNP significance filter.
# -rmTriallelic: Filter triallelic sites.
# -doPost: Calculate genotype posterior probabilities.
# -doGeno: Specify the genotype output format.
# -doPlink: Control PLINK output.
# -doBcf: Generate BCF output.
# -nThreads: Number of processing threads.
# -nQueueSize: Number of jobs queued for processing.

# 4. SNP calling after excluding highly related individuals.
# Restrict SNP calling to high-confidence autosomal scaffolds.
# Individuals with >30% missing data and <50% mapping efficiency were excluded.
# Highly related individuals (kinship >0.0884) were removed from the sample list before SNP calling.
# 169 individuals; mean depth 3.27x.
# -minInd 85: Require data from at least 50% of individuals.
# -setMaxDepth 1658: Mean depth * 3 * number of individuals.
# Generate genotype likelihoods, genotype posterior probabilities, and a BCF file with hard-called genotypes.

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
AUTOSOMES="path/to/reference_genome/high_confidence_autosome_scaffolds.txt"
ANGSD="path/to/angsd"

"${ANGSD}" -b "${SAMPLELISTS}/Bams_u30MD_70minInd_noRelated.txt" \
-ref "${REFERENCE}" \
-out "${RESULTS}/Galap24_autosome_noRelated_minInd50/Galap24_autosome_noRelated" \
-rf "${AUTOSOMES}" \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 1 -trim 0 \
-minMapQ 20 -minQ 20 -minInd 85 -setMinDepthInd 1 -setMaxDepth 1658 -doCounts 1 \
-GL 2 -doGlf 2 -doMajorMinor 1 -doMaf 1 -minMaf 0.02 -SNP_pval 1e-6 -rmTriallelic 0.05 \
-doPost 1 -doGeno 32 -doPlink 0 -doBcf 1 \
-nThreads 8 -nQueueSize 10 \
> "${LOGS}/Galap24_autosome_noRelated.log" 2>&1

# 56,063 sites retained.
# NEXT: Filter resulting dataset for HWE.
