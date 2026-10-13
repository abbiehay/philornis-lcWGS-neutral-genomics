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

The workflow below describes the main stages of processing and filtering low-coverage genomic data for the Galápagos-only 2024 and Galápagos–mainland datasets. Scripts are intended to be run sequentially, with output files from each stage used as inputs to subsequent stages.

### 1. Initial SNP calling

ANGSD was used for initial SNP calling from the BAM files, generating BCF files containing hard-called genotypes for assessing individual missingness and genotype likelihoods for subsequent analyses.

### 2. Calculate individual missingness using VCFtools

The initial BCF file was converted to VCF format, and sample identifiers were standardised. VCFtools was used to calculate per-individual missingness using `--missing-indv`.

### 3. Exclude individuals failing missingness or mapping-efficiency thresholds

Individuals with more than 30% missing data or less than 50% mapping efficiency were excluded. The remaining BAM files were used for subsequent SNP calling.

Mapping efficiency was assessed using the scripts in the [*Philornis* data-processing repository](https://github.com/). See `04_mapping.sh` for the mapping-efficiency workflow.

### 4. Identify high-confidence autosomal scaffolds using BeXY

BeXY was used to classify scaffolds as autosomal or sex-linked and identify high-confidence autosomal scaffolds. This analysis was performed once using the Galápagos-only data. The resulting autosomal scaffold list was applied to both the Galápagos-only and Galápagos–mainland datasets.

### 5. SNP calling restricted to autosomal scaffolds

ANGSD was used to call SNPs restricted to the high-confidence autosomal scaffolds identified by BeXY, using the filtered BAM lists. Genotype likelihoods in Beagle format and BCF files containing hard-called genotypes were generated.

Filtering settings included:

- Minimum mapping quality: 20.
- Minimum base quality: 20.
- Minimum site coverage: data from at least 50% of individuals.
- Minimum minor allele frequency: 0.02.
- SNP significance threshold: \(1 \times 10^{-6}\).
- Triallelic-site filtering: `-rmTriallelic 0.05`.

### 6. Estimate pairwise relatedness

The autosomal BCF was converted to VCF format, and sample identifiers were standardised. VCFtools `--relatedness2` was used to estimate pairwise relatedness. Self-comparisons were removed from the resulting pairwise relatedness table.

### 7. Identify and remove highly related individuals

Pairs with kinship estimates greater than 0.0884 were identified. Highly related individuals were removed from the sample lists before subsequent SNP calling.

### 8. SNP calling after removing related individuals

ANGSD was rerun using the updated BAM list, restricting SNP calling to the high-confidence autosomal scaffolds. The mapping, base-quality, site-coverage, minor allele frequency, SNP significance and triallelic-site filters were applied again. Genotype likelihoods, genotype posterior probabilities and hard-called genotypes were generated.

### 9. Filter variants by Hardy–Weinberg equilibrium

Variants with Hardy–Weinberg equilibrium (HWE) p-values below 1e-6 were excluded using ANGSD.

### 10. Estimate linkage disequilibrium with ngsLD

Pairwise linkage disequilibrium (LD) was estimated using `ngsLD`, with genotype likelihoods from the ANGSD Beagle output and scaffold and position information extracted from the corresponding MAF file. No maximum distance limit was applied during LD estimation. The resulting pairwise LD file was used as input for `prune_graph`.

### 11. Prune linked SNPs with prune_graph

`prune_graph` was used to identify unlinked SNPs based on the pairwise LD estimates from `ngsLD`. The pruning criteria were:

- Physical distance: 50 kb.
- LD threshold: \(r^2 \geq 0.5\) for SNP pairs within the specified distance.

The retained SNP positions were reformatted and indexed for use with ANGSD.

### 12. Generate the final unlinked SNP set

ANGSD was rerun using the indexed positions file produced by `prune_graph`, with the `-sites` option restricting the analysis to the retained unlinked SNPs. Mapping-quality and base-quality filters were retained. SNP and minor allele frequency thresholds were not reapplied because the input positions had already undergone SNP filtering and LD pruning.

The resulting unlinked SNP sets were used for downstream population genomic analyses.

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
