# Software and package versions

The following software and packages were used in the neutral *Philornis downsi* analyses and data processing

## Software and package versions

| **Software** | **Version** | **Reference** |
|---|---|---|
| [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) | 0.12.1 | Andrews (2010) |
| [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) | 0.39 | Bolger et al. (2014) |
| [fastp](https://github.com/OpenGene/fastp) | 0.24.0 | Chen et al. (2018) |
| [NextGenMap](https://github.com/Cibiv/NextGenMap) | 0.5.5 | Sedlazeck et al. (2013) |
| [Picard](https://broadinstitute.github.io/picard/) | 2.18.29 | Broad Institute |
| [BamUtil](https://github.com/statgen/bamUtil) | 1.0.15 | Jun et al. (2015) |
| [SAMtools](https://www.htslib.org/) | 1.19.2 | Li et al. (2009) |
| [ANGSD](https://github.com/ANGSD/angsd) | 0.941-22-gc877e7f | Korneliussen et al. (2014) |
| realSFS | ANGSD-associated | Korneliussen et al. (2014) |
| thetaStat | ANGSD-associated | Korneliussen et al. (2014) |
| [VCFtools](https://vcftools.github.io/) | 0.1.16 | Danecek et al. (2011) |
| BeXY | 1.0 | Caduff et al. (2024) |
| [ngsLD](https://github.com/fgvieira/ngsLD) | 1.2.1 | Fox et al. (2019) |
| [prune_graph](https://github.com/fgvieira/prune_graph) | 0.3.4 | GitHub repository |
| [ngsDist](https://github.com/fgvieira/ngsDist) | 1.0.10 | Vieira et al. (2016) |
| [PCAngsd](https://github.com/Rosemeis/pcangsd) | 1.36.1 | Meisner and Albrechtsen (2018) |
| [NGSadmix](https://github.com/fgvieira/ngsAdmix/blob/master/ngsAdmix.cpp) | 33 | Skotte et al. (2013) |
| [ADMIXTURE](https://dalexander.github.io/admixture/) | 1.3.0 | Alexander et al. (2009) |
| NeEstimator2 | 2.1 | Do et al. (2014) |
| WGSassign | 0.0 | DeSaix et al. (2024) |
| [diveRsity](https://cran.r-project.org/package=diveRsity) | 1.9.90 | Keenan et al. (2013); Sundqvist et al. (2016) |
| [R](https://www.r-project.org/) | 4.4.2 | R Core Team (2024) |
| [ggplot2](https://ggplot2.tidyverse.org/) | 4.0.2 | Wickham (2016) |
| [geosphere](https://cran.r-project.org/package=geosphere) | 1.5.20 | Hijmans (2024) |
| [vegan](https://cran.r-project.org/package=vegan) | 2.7.1 | Oksanen et al. (2022) |

**Notes**

- ANGSD reports version `0.941-22-gc877e7f` (commit `c877e7f`) and HTSlib version `1.14-9-ge769401d`.
- Software versions reflect the recorded installations and should be interpreted in conjunction with the analysis scripts.
– Dependencies were generally managed via Miniconda.

## References

Alexander, D. H., Novembre, J., & Lange, K. (2009). Fast model-based estimation of ancestry in unrelated individuals. *Genome Research, 19*, 1655–1664. https://doi.org/10.1101/gr.094052.109

Andrews, S. (2010). *FastQC: A quality control tool for high throughput sequence data*. https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

Bolger, A. M., Lohse, M., & Usadel, B. (2014). Trimmomatic: A flexible trimmer for Illumina sequence data. *Bioinformatics, 30*(15), 2114–2120. https://doi.org/10.1093/bioinformatics/btu170

Broad Institute. *Picard Toolkit*. https://broadinstitute.github.io/picard/

Caduff, M., Eckel, R., Leuenberger, C., & Wegmann, D. (2024). Accurate Bayesian inference of sex chromosome karyotypes and sex-linked scaffolds from low-depth sequencing data. *Molecular Ecology Resources, 24*(3), e13913. https://doi.org/10.1111/1755-0998.13913

Chen, S., Zhou, Y., Chen, Y., & Gu, J. (2018). fastp: An ultra-fast all-in-one FASTQ preprocessor. *Bioinformatics, 34*(17), i884–i890. https://doi.org/10.1093/bioinformatics/bty560

Danecek, P., Auton, A., Abecasis, G., et al. (2011). The variant call format and VCFtools. *Bioinformatics, 27*(15), 2156–2158. https://doi.org/10.1093/bioinformatics/btr330

DeSaix, M. G., et al. (2024). Population assignment from genotype likelihoods for low-coverage whole-genome sequencing data. *Methods in Ecology and Evolution, 15*, 493–510. https://doi.org/10.1111/2041-210X.14286

Do, C., Waples, R. S., Peel, D., Macbeth, G. M., Tillett, B. J., & Ovenden, J. R. (2014). NeEstimator v2: Re-implementation of software for the estimation of contemporary effective population size (Ne) from genetic data. *Molecular Ecology Resources, 14*(1), 209–214. https://doi.org/10.1111/1755-0998.12157

Fox, E. A., Wright, A. E., Fumagalli, M., & Vieira, F. G. (2019). ngsLD: Evaluating linkage disequilibrium using genotype likelihoods. *Bioinformatics, 35*(19), 3855–3856. https://doi.org/10.1093/bioinformatics/btz200

Hijmans, R. J. (2024). *geosphere: Spherical trigonometry*. R package. https://CRAN.R-project.org/package=geosphere

Jun, G., et al. (2015). BamUtil. https://github.com/statgen/bamUtil

Keenan, K., McGinnity, P., Cross, T. F., Crozier, W. W., & Prodöhl, P. A. (2013). diveRsity: An R package for the estimation of population genetics parameters and their associated errors. *Methods in Ecology and Evolution, 4*(8), 782–788. https://doi.org/10.1111/2041-210X.12067

Korneliussen, T. S., Albrechtsen, A., & Nielsen, R. (2014). ANGSD: Analysis of next generation sequencing data. *BMC Bioinformatics, 15*, 356. https://doi.org/10.1186/s12859-014-0356-4

Li, H., Handsaker, B., Wysoker, A., et al. (2009). The Sequence Alignment/Map format and SAMtools. *Bioinformatics, 25*(16), 2078–2079. https://doi.org/10.1093/bioinformatics/btp352

Meisner, J., & Albrechtsen, A. (2018). Inferring population structure and admixture proportions in low-depth NGS data. *Genetics, 210*(2), 719–731. https://doi.org/10.1534/genetics.118.301336

Oksanen, J., Simpson, G. L., Blanchet, F. G., et al. (2022). *vegan: Community Ecology Package*. R package. https://CRAN.R-project.org/package=vegan

R Core Team. (2024). *R: A language and environment for statistical computing*. R Foundation for Statistical Computing, Vienna, Austria. https://www.R-project.org/

Sedlazeck, F. J., Rescheneder, P., & von Haeseler, A. (2013). NextGenMap: Fast and accurate read mapping in highly polymorphic genomes. *Bioinformatics, 29*(21), 2790–2791. https://doi.org/10.1093/bioinformatics/btt468

Skotte, L., Korneliussen, T. S., & Albrechtsen, A. (2013). Estimating individual admixture proportions from next generation sequencing data. *Genetics, 195*(3), 693–702. https://doi.org/10.1534/genetics.113.154138

Sundqvist, L., Keenan, K., Zackrisson, M., Prodöhl, P., & Kleinhans, D. (2016). Directional genetic differentiation and relative migration. *Ecology and Evolution, 6*(11), 3461–3475. https://doi.org/10.1002/ece3.2096

Vieira, F. G., Lassalle, F., Korneliussen, T. S., & Fumagalli, M. (2016). Improving the estimation of genetic distances from low-coverage sequencing data. *Molecular Biology and Evolution, 33*(9), 2516–2526. https://doi.org/10.1093/molbev/msw124

Wickham, H. (2016). *ggplot2: Elegant Graphics for Data Analysis*. Springer. https://ggplot2.tidyverse.org/

## Software repositories

- [ANGSD](https://github.com/ANGSD/angsd)
- [prune_graph](https://github.com/fgvieira/prune_graph)
- [ngsLD](https://github.com/fgvieira/ngsLD)
- [ngsDist](https://github.com/fgvieira/ngsDist)
- [NGSadmix](https://github.com/fgvieira/ngsAdmix/blob/master/ngsAdmix.cpp)

