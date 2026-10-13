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
# -doBcf: Generate BCF output.
# -doGeno: Specify the genotype output format.
# -nThreads: Number of processing threads.
# -nQueueSize: Number of jobs queued for processing.

# 3. SNP calling after excluding sex-linked scaffolds.
# Restrict SNP calling to high-confidence autosomal scaffolds.
# Individuals with >30% missing data and <50% mapping efficiency were excluded.
# Generate a Beagle genotype likelihood file and a BCF file with hard-called genotypes.
# 189 individuals; mean depth 3.31x
# -minInd 95: Minimum site coverage in 50% of individuals.
# -setMaxDepth 1877: Mean depth * 3 * number of individuals.

REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
RESULTS="path/to/angsd_pipeline/angsd_results"
LOGS="path/to/angsd_pipeline/logs"
AUTOSOMES="path/to/reference_genome/high_confidence_autosome_scaffolds.txt"
ANGSD="path/to/angsd"

"${ANGSD}" -b "${SAMPLELISTS}/Bams_u30MD_70minInd.txt" \
-ref "${REFERENCE}" \
-out "${RESULTS}/Galap24_autosomal/Galap24_autosomal" \
-rf "${AUTOSOMES}" \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -baq 1 -trim 0 \
-minMapQ 20 -minQ 20 -minInd 95 -setMinDepthInd 1 -setMaxDepth 1877 -doCounts 1 \
-GL 2 -doGlf 2 -doMajorMinor 1 -doMaf 1 -minMaf 0.02 -SNP_pval 1e-6 -rmTriallelic 0.05 \
-doBcf 1 -doGeno 4 \
-nThreads 8 -nQueueSize 10 \
> "${LOGS}/SNPcall_Galap25_autosome.log" 2>&1

# 66,403 sites retained
# NEXT: Convert BCF to VCF (as per instructions in 02_ind_missing_data.sh) and infer highly related individuals using vcftools
