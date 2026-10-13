# philornis-lcWGS-neutral-genomics

## *Philornis downsi* Population Genomics: ANGSD Filtering and Neutral Analyses

This repository contains scripts for SNP filtering and neutral population-genomic analyses of invasive *Philornis downsi* across the Galápagos Islands and between the Galápagos and mainland Ecuador. The workflow uses ANGSD for low-coverage whole-genome sequencing data and includes filtering for missing data, mapping quality, Hardy–Weinberg equilibrium (HWE), and linkage disequilibrium (LD).

Scripts and documentation will be added as the project develops. The scripts currently uploaded document the **Galápagos-only 2024 dataset**. The Galápagos–mainland dataset was filtered using the same general workflow, with one exception: high-confidence autosomal scaffolds were identified using the Galápagos-only data and then applied to the combined Galápagos–mainland dataset.

## Contents

To add

## Reference genome

Reads were mapped to the *Philornis downsi* reference genome, assembly GCA_019455685.1 (Romine et al., 2022).

**Reference genome citation:**

Romine, M. G., Knutie, S. A., Crow, C. M., Vaziri, G. J., Chaves, J. A., Koop, J. A. H., & Lamichhaney, S. (2022). The genome sequence of the avian vampire fly (*Philornis downsi*), an invasive nest parasite of Darwin’s finches in Galápagos. *G3 Genes|Genomes|Genetics*, 12, jkab414. https://doi.org/10.1093/g3journal/jkab414

## Data availability

Raw sequencing data are available through the NCBI Sequence Read Archive (SRA) under [BioProject PRJNA1468418](https://www.ncbi.nlm.nih.gov/bioproject/1468418).

BioSample accession numbers: SAMN60281468–SAMN60281636 and SAMN60394944–SAMN60394967.

Raw sequencing reads and large intermediate files, including BAM files, are not distributed in this repository.

## Software environment and execution

Processing scripts are executed as Bash scripts on a high-performance computing (HPC) server. Most software was installed using Miniconda.

The workflow uses the following tools:

- **ANGSD** — genotype likelihood estimation, SNP filtering, and generation of Beagle-format genotype likelihoods.
- **BCFtools** — manipulation of variant files where required.
- **VCFtools** — pairwise relatedness estimation.
- **ngsLD** — estimation of pairwise linkage disequilibrium.
- **prune_graph** — pruning of linked SNPs to generate a set of unlinked sites.
- **Bash and standard Unix utilities** — file preparation and processing.

Software-specific installation instructions and commands are documented in the relevant scripts or accompanying sections as the repository develops. Software versions and execution environments should be recorded to support reproducibility.

## SNP filtering workflow

The workflow below describes the main stages of processing and filtering low-coverage genomic data. Scripts are intended to be run sequentially, with output files from each stage used as inputs to subsequent stages.

### 1. Initial sample filtering

Individuals were filtered based on missing data and mapping efficiency. Individuals with more than 30% missing data or less than 50% mapping efficiency were excluded. Highly related individuals were subsequently removed based on pairwise relatedness estimates.

For the Galápagos-only 2024 dataset, 169 individuals remained after these filtering steps, with a mean sequencing depth of 3.27×.

### 2. Identify high-confidence autosomal scaffolds

High-confidence autosomal scaffolds were identified using the Galápagos-only data. The resulting scaffold list was used to restrict downstream SNP calling to autosomal regions.

The same scaffold list was applied to the Galápagos–mainland dataset.

### 3. ANGSD SNP calling and filtering

ANGSD was used to estimate genotype likelihoods and identify SNPs using the filtered BAM list and high-confidence autosomal scaffolds.

Key settings for the Galápagos-only 2024 dataset included:

- Minimum mapping quality: 20.
- Minimum base quality: 20.
- Minimum number of individuals per site: 85 (50% of the 169 individuals).
- Minimum minor allele frequency: 0.02.
- SNP significance threshold: \(1 \times 10^{-6}\).
- Triallelic-site filtering: `-rmTriallelic 0.05`.
- HWE filtering: exclude variants with HWE p-values below \(1 \times 10^{-6}\).

The filtered output included genotype likelihoods in Beagle format and a MAF file for downstream analyses.

### 4. Estimate linkage disequilibrium with ngsLD

Pairwise linkage disequilibrium was estimated using `ngsLD`, with genotype likelihoods from the ANGSD Beagle output and SNP scaffold/position information extracted from the corresponding MAF file.

For the Galápagos-only 2024 dataset, the analysis used:

- 169 individuals.
- 55,070 SNPs.
- 15 threads.

No maximum distance limit was applied during LD estimation. The resulting pairwise LD file was used as input for `prune_graph`.

### 5. Prune linked SNPs with prune_graph

`prune_graph` was used to identify a set of unlinked SNPs based on the pairwise LD estimates from `ngsLD`.

The pruning criteria were:

- Physical distance: 50 kb.
- LD threshold: \(r^2 \geq 0.5\) for SNP pairs within the specified distance.

The retained SNP positions were reformatted and indexed for use with ANGSD.

### 6. Generate the final unlinked SNP set in ANGSD

ANGSD was rerun using the indexed positions file produced by `prune_graph`, with the `-sites` option restricting the analysis to the retained unlinked SNPs.

The mapping-quality and base-quality filters were retained. SNP and MAF thresholds were not reapplied at this stage because the input positions were derived from the previously filtered SNP set.

**Final result:** 33,638 sites retained for downstream analyses of the Galápagos-only 2024 dataset.

## Neutral population-genomic analyses

This repository will also include scripts for downstream neutral population-genomic analyses of the Galápagos-only and Galápagos–mainland datasets.

Planned and forthcoming sections include:

- **Genetic diversity:** estimation and comparison of within-population genetic diversity.
- **Population structure:** assessment of genomic differentiation among islands and between Galápagos and mainland populations.
- **Gene flow and connectivity:** analyses of population connectivity and directional genomic dispersal.
- **Additional neutral analyses:** further scripts and documentation will be added as the workflow develops.

Scripts and documentation for these analyses will be added in future updates.


## Citation

If you use the reference genome, please cite Romine et al. (2022), as listed above. A repository citation and version-specific release information can be added here when the repository is formally released.
