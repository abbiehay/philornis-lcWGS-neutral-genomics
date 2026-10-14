#!/usr/bin/env bash
# WGSassign population assignment workflow for the 2024 Galápagos dataset
#
# This script documents the workflow used for reference-population assignment with WGSassign.
#
# WGSassign documentation:
# https://github.com/mgdesaix/WGSassign
#
# Installation (run separately, as needed):
#   conda install mamba -c conda-forge
#   git clone https://github.com/mgdesaix/WGSassign.git
#   cd WGSassign
#   mamba env create -f environment.yml
#   conda activate WGSassign
#   python setup.py build_ext --inplace
#   pip install -e .
#
# Activate the WGSassign environment before running this workflow:
#   conda activate WGSassign
#   WGSassign --help
#
set -euo pipefail

# ---- Paths: edit these for your system ----
PROJECT_DIR="${PROJECT_DIR:-/path/to/Philornis}"
WGSASSIGN_REPO="${WGSASSIGN_REPO:-/path/to/WGSassign}"
SAMPLE_LIST_DIR="${PROJECT_DIR}/sample_lists"
WGSASSIGN_OUT="${PROJECT_DIR}/WGSassign_out"
ANGSD_WGSASSIGN_DIR="${PROJECT_DIR}/angsd_pipeline/angsd_results/Galap24_autosome_noRelated_HWE1e06_unlinked_wgsAssign"

BEAGLE="${ANGSD_WGSASSIGN_DIR}/Galap24_autosome_noRelated_HWE1e06_unlinked_wgsAssign.beagle.gz"
ANGSD_COUNTS="${ANGSD_WGSASSIGN_DIR}/Galap24_autosome_noRelated_HWE1e06_unlinked_wgsAssign.counts.gz"
IND_AD_FILE="${ANGSD_WGSASSIGN_DIR}/Galap24_autosome_noRelated_HWE1e06_unlinked_wgsAssign.counts.gz.majmin.counts.txt.gz"
REFERENCE_IDS="${SAMPLE_LIST_DIR}/Reference_ID_WGAassign.txt"

# Keep generate_pop_af_IDs_iter.py and slice_pop_af.py in the working directory,
# or update their paths in the commands below.

# 1. Prepare input files

# Run ANGSD first to generate the Beagle file used by WGSassign.
# WGSassign uses the Beagle file and a reference-ID file.

# Reference-ID file requirements:
# The reference-ID file must be tab-delimited with two columns: individual ID and reference population.
# Row order must match sample order in the Beagle file. IDs do not need to match Beagle sample names.
# One option is to create this file from the BAM list used to generate the Beagle file, with population labels in column 2.
# Use a headerless .txt file.

# For z-score assignment (including assignment relative to unsampled populations):
# When generating the Beagle file in ANGSD, also use -doCounts 1 -dumpCounts 4 to output allele counts for all individuals and loci.
# Use the WGSassign script below to generate the allele-count file.
# Make the script executable (once, if needed).
chmod +x "${WGSASSIGN_REPO}/WGSassign/allele_counts_beagle.py"
# Run with the ANGSD Beagle and counts files.
counts="${ANGSD_COUNTS}"
beagle="${BEAGLE}"
(
  cd "${ANGSD_WGSASSIGN_DIR}"
  python "${WGSASSIGN_REPO}/WGSassign/allele_counts_beagle.py" "${counts}" "${beagle}"
)
# Output: a .majmin.counts.txt.gz file for use with WGSassign.
# The file contains L (loci) rows and 2 × N (individuals) columns.

# 2. Estimate reference-population allele frequencies

# Estimate reference-population allele frequencies for assignment.
# Allele-frequency estimation is parallelized across loci; adjust the thread count to suit the available resources.
# --loo excludes each reference individual from the allele-frequency estimate for its assigned population.
# This avoids evaluating an individual against allele frequencies estimated using that individual's own data.
# --ne_obs also estimates effective sample size (optional).

WGSassign \
  --beagle "${BEAGLE}" \
  --pop_af_IDs "${REFERENCE_IDS}" \
  --get_reference_af \
  --loo \
  --ne_obs \
  --threads 10 \
  --out "${WGSASSIGN_OUT}/Galap24_WGSassign"
# Outputs include:
# - .args: parameters used in the command.
# - .fisher_obs.npy: Fisher’s exact test statistics for each locus and population.
# - .ne_obs.txt and .ne_obs.npy: estimated effective sample sizes for populations.
# - .ne_ind.txt: estimated effective sample size for each individual.
# - .pop_af.npy: population allele frequencies used for assignment and z-score calculations.
# - .pop_like_LOO.txt: tab-delimited matrix of individual-by-population log-likelihoods calculated with leave-one-out.
# - .pop_names.txt: population names corresponding to columns in .pop_af.npy.

# 3. Calculate z-scores for reference individuals
# Calculate each reference individual's z-score for its assigned population in the reference-ID file.
# Z-scores compare an individual's observed likelihood with the expected likelihood for an individual from that population at comparable read depth.
WGSassign \
  --beagle "${BEAGLE}" \
  --pop_af_IDs "${REFERENCE_IDS}" \
  --pop_names "${WGSASSIGN_OUT}/Galap24_WGSassign.pop_names.txt" \
  --ind_ad_file "${IND_AD_FILE}" \
  --get_reference_z_score \
  --out "${WGSASSIGN_OUT}/Galap24_WGSassign" \
  --threads 20
# .reference_z_ind.txt contains z-scores for reference individuals under their assigned populations.

# Assign individuals using the estimated reference-population allele frequencies:
WGSassign \
  --beagle "${BEAGLE}" \
  --pop_af_IDs "${REFERENCE_IDS}" \
  --pop_af_file "${WGSASSIGN_OUT}/Galap24_WGSassign.pop_af.npy" \
  --pop_names "${WGSASSIGN_OUT}/Galap24_WGSassign.pop_names.txt" \
  --ind_ad_file "${IND_AD_FILE}" \
  --get_assignment_z_score \
  --out "${WGSASSIGN_OUT}/Galap24_WGSassign" \
  --threads 20 \
  > "${WGSASSIGN_OUT}/Galap24_WGSassign_assignment_z.log" 2>&1
# .pop_like_LOO.txt and .pop_names.txt can be used for post-processing in RStudio.

# 4. Iteratively standardise reference-population effective sample sizes (ESS) – random subsampling method

# Inspect the .ne_obs.txt output. DeSaix et al. (2024) note that assignments can be biased by effective sample size (ESS). If ESS differs among reference populations, subset individuals to standardise ESS across populations.
# Initially reduce all reference populations to the size of the smallest population (SL; 21 individuals).
# Create a single-column .txt file containing the SampleIDs to retain. These individuals were randomly selected using an online random-number generator.
# generate_pop_af_IDs_iter.py creates a full-length, order-preserving --pop_af_IDs file that retains selected individuals in their original reference populations and assigns all excluded individuals to a dummy population (DROPPED).
# This avoids regenerating the Beagle file when subsetting reference populations.

# Create the amended reference-ID file for this iteration.
python3 generate_pop_af_IDs_iter.py 
  --base-pop "${REFERENCE_IDS}" 
  --keep "${WGSASSIGN_OUT}/WGSassign_ref_subsample/keep_all.iter2.txt" 
  --out "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign.iter2.txt" 
  --dropped-name DROPPED

# Re-estimate reference allele frequencies, leave-one-out estimates, and ESS,
# including DROPPED as a temporary population.
WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign.iter2.txt" 
  --get_reference_af 
  --loo 
  --ne_obs 
  --threads 10 
  --out "${WGSASSIGN_OUT}/iter_2/Galap24_WGSassign_iter2"

# SECOND ITERATION: If ESS remains unequal, randomly exclude additional individuals from populations with higher ESS and repeat this process until ESS is sufficiently standardised. Update the keep list and output paths for each iteration.

python3 generate_pop_af_IDs_iter.py 
  --base-pop "${REFERENCE_IDS}" 
  --keep "${WGSASSIGN_OUT}/WGSassign_ref_subsample/keep_all.final.txt" 
  --out "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign.final.txt" 
  --dropped-name DROPPED

WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign.final.txt" 
  --get_reference_af 
  --loo 
  --ne_obs 
  --threads 10 
  --out "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final"

# Remove the DROPPED population before assignment.
python3 slice_pop_af.py 
  --pop-af "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final.pop_af.npy" 
  --pop-names "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final.pop_names.txt" 
  --drop DROPPED 
  --out-pop-af "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final.nodropped.pop_af.npy" 
  --out-pop-names "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final.nodropped.pop_names.txt"

# 6. Calculate z-scores for reference individuals.
WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign.final.txt" 
  --pop_names "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final.nodropped.pop_names.txt" 
  --ind_ad_file "${IND_AD_FILE}" 
  --get_reference_z_score 
  --out "${WGSASSIGN_OUT}/final/Galap24_WGSassign_final" 
  --threads 20


# 5. Alternative approach: subsample reference individuals based on reference-population z-scores.

# Inspect the .ne_obs.txt output. If ESS differs among reference populations, subset individuals to standardise ESS.
# Initially reduce all reference populations to the size of the smallest population (SL; 21 individuals), retaining the 21 individuals with the highest z-scores for their reference populations.
# Prepare a single-column keep list containing the SampleIDs to retain (those with highest reference-population z-score per population)
# generate_pop_af_IDs_iter.py creates a full-length, order-preserving --pop_af_IDs file that retains selected individuals in their original populations and assigns all excluded individuals to a dummy population (DROPPED). This avoids regenerating the Beagle file when subsetting reference populations.
# Review the .ne_obs.txt output and repeat the subsampling and reference allele-frequency estimation process as needed until ESS is sufficiently standardised across populations. The following commands show one example iteration.
# Create an amended reference-ID file in which excluded individuals are assigned to DROPPED.

python3 generate_pop_af_IDs_iter.py 
  --base-pop "${REFERENCE_IDS}" 
  --keep "${WGSASSIGN_OUT}/WGSassign_highestRefZ_subsample/keep_highestRefZ.iter1.txt" 
  --out "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign_highestRefZ.iter1.txt" 
  --dropped-name DROPPED

# Re-estimate reference allele frequencies, leave-one-out estimates, and ESS with DROPPED included.
WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign_highestRefZ.iter1.txt" 
  --get_reference_af 
  --loo 
  --ne_obs 
  --threads 10 
  --out "${WGSASSIGN_OUT}/highestRefZ_iter1/Galap24_WGSassign_highestRefZ_iter1"

# Remove the DROPPED population before assignment using the final iteration's output files.
python3 slice_pop_af.py 
  --pop-af "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_iter3.pop_af.npy" 
  --pop-names "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_iter3.pop_names.txt" 
  --drop DROPPED 
  --out-pop-af "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_nodropped.pop_af.npy" 
  --out-pop-names "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_nodropped.pop_names.txt"

# Calculate z-scores for reference individuals.
WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign_highestRefZ.iter3.txt" 
  --pop_names "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_iter3.pop_names.txt" 
  --ind_ad_file "${IND_AD_FILE}" 
  --get_reference_z_score 
  --out "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ" 
  --threads 20

# Retain z-scores only for reference individuals not assigned to DROPPED.
awk 'NR==FNR{pop[$1]=$2;next} (pop[$1]!="DROPPED")' 
  "${SAMPLE_LIST_DIR}/Reference_ID_WGSassign_highestRefZ.iter3.txt" 
  "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ.reference_z_ind.txt" \
  > "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ.reference_z_ind.kept.txt"

# Assign individuals using the cleaned allele-frequency files (without DROPPED).
# The original reference-ID file retains each individual's real reference population.
WGSassign 
  --beagle "${BEAGLE}" 
  --pop_af_IDs "${REFERENCE_IDS}" 
  --pop_af_file "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_nodropped.pop_af.npy" 
  --pop_names "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_nodropped.pop_names.txt" 
  --ind_ad_file "${IND_AD_FILE}" 
  --get_assignment_z_score 
  --out "${WGSASSIGN_OUT}/highestRefZ_iter3/Galap24_WGSassign_highestRefZ_assign" 
  --threads 20

# .pop_like_LOO.txt and .pop_names.txt can be used for post-processing in RStudio.
