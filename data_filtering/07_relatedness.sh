#!/bin/bash

# VCFtools relatedness2: Galapagos 2024 autosomal dataset
# Ensure bcftools and vcftools are installed and available in the environment.

# 1. Convert the hard-called autosomal BCF to VCF.
bcftools view Galap24_autosomal.bcf \
  -Ov \
  -o Galap24_autosomal.vcf

# 2. Extract and clean sample IDs from the VCF header.
# Retain the portion of each sample name before the first underscore.
grep "^#CHROM" Galap24_autosomal.vcf \
  | cut -f10- \
  | tr '\t' '\n' \
  | xargs -n 1 basename \
  | cut -d_ -f1 \
  > Galap24_sample_names.txt

# 3. Replace VCF sample IDs with the cleaned names.
bcftools reheader \
  -s Galap24_sample_names.txt \
  -o Galap24_autosomal_cleaned.vcf \
  Galap24_autosomal.vcf

# Check that sample IDs were updated correctly.
grep "^#CHROM" Galap24_autosomal_cleaned.vcf

# 4. Estimate pairwise relatedness using VCFtools --relatedness2.
vcftools \
  --vcf Galap24_autosomal_cleaned.vcf \
  --relatedness2 \
  --out Galap24_autosomal_kinship

# 5. Remove self-comparisons, retaining pairs of distinct individuals.
awk '$1 != $2' \
  Galap24_autosomal_kinship.relatedness2 \
  > Galap24_autosomal_kinship_no_self_comparisons.txt
