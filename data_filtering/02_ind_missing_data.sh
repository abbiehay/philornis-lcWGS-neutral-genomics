#!/bin/bash

# Filtering for missing data

# Define input and output paths
INPUT="path/to/Galap_mainland_MDfiltered_autosomes_noRelated.bcf"
OUTPUT="path/to/output"
SAMPLE_NAMES="${OUTPUT}/sample_names.txt"

# 1. Convert BCF (generated previously via ANGSD) to VCF
bcftools view "${INPUT}" -Ov \
-o "${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated.vcf"

# 2. Extract and clean sample names
grep "^#CHROM" "${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated.vcf" \
| cut -f10- \
| tr '\t' '\n' \
| xargs -n 1 basename \
| cut -d_ -f1 \
> "${SAMPLE_NAMES}"

# 3. Rename sample columns in the VCF
bcftools reheader \
-s "${SAMPLE_NAMES}" \
-o "${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated_cleaned.vcf" \
"${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated.vcf"

# 4. Check that sample names were updated
grep "^#CHROM" "${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated_cleaned.vcf"

# 5. Calculate missing data per individual
vcftools \
--vcf "${OUTPUT}/Galap_mainland_MDfiltered_autosomes_noRelated_cleaned.vcf" \
--missing-indv

# Output: out.imiss contains missingness statistics for each individual
# Next: Exclude individuals with >30% missing data and <50% mapping efficiency 
# (estimated using samtools depth; see the philornis_lcWGS_data_processing repository).
# Re-run subsequent SNP calls using the filtered sample list.
