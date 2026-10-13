#!/bin/bash

# Infer sex-linked scaffolds and individual genetic sex using BeXY
# BeXY repository: https://bitbucket.org/WegmannLab/bexy.git
# BeXY is used to analyse low-coverage whole-genome sequencing data.


# 1. Install and compile BeXY
# Requirements: C++17-compatible compiler (GCC 8 or later) and CMake 3.14 or later

gcc --version
cmake --version

git clone https://bitbucket.org/WegmannLab/bexy.git
cd bexy

bash compile_bexy.sh -c /usr/bin/cmake

# BeXY executable: path/to/bexy/build/bexy


# 2. Generate individual idxstats files from BAM files
# Requires BAM files and their associated index files.
# Each .idxstats file contains per-scaffold read counts for one individual.

BEXY="path/to/bexy/build/bexy"
SAMPLELISTS="path/to/angsd_pipeline/sample_lists"
IDXSTATS="path/to/BeXY/idxstats_individuals"
REFERENCE="path/to/reference_genome/GCA_019455685.1_ASM1945568v1_genomic.fna"
RESULTS="path/to/BeXY/BeXY_outputs_189Ind"
ANGSD_RESULTS="path/to/angsd_pipeline/angsd_results"

mkdir -p "${IDXSTATS}"

while read -r bamfile; do
    sample=$(basename "${bamfile}" .bam)
    samtools idxstats "${bamfile}" > "${IDXSTATS}/${sample}.idxstats"
done < "${SAMPLELISTS}/Bams_u30MD_70minInd.txt"


# 3. Create the BeXY idxstats master file
# Create a headerless text file listing the paths to all individual .idxstats files.
# Save the file as bexy_output_189Ind.txt.


# 4. Extract scaffold names and lengths from the reference genome index
# The resulting file provides scaffold names and lengths for BeXY.

cut -f1,2 "${REFERENCE}.fai" \
> "path/to/BeXY/scaffold_lengths_refgenome.txt"


# 5. Infer sex-linked scaffolds and individual genetic sex using idxstats
# Use per-individual scaffold read counts without prior sex information.
# BeXY uses the idxstats master file and reference scaffold lengths for inference.

"${BEXY}" --task infer \
    --out "${RESULTS}/bexy_output_189Ind" \
    --idxstats "path/to/BeXY/bexy_output_189Ind.txt" \
    --ref "path/to/BeXY/scaffold_lengths_refgenome.txt" \
    --maxNumThreads 20


# 6. Infer sex-linked scaffolds and individual genetic sex using genotype likelihoods
# Use the ANGSD Beagle genotype likelihood file and scaffold information.
# Provide known sex information through sex_info.txt where required by the analysis.

"${BEXY}" --beagle "${ANGSD_RESULTS}/SNPcall_58/SNPcall_58.beagle" \
    --outprefix bexy_output \
    --scaffold_file "${ANGSD_RESULTS}/SNPcall_58/scaffold_names.txt" \
    --sex_file "path/to/sex_info.txt"
