# Galapagos 2024: Summarising VCFtools relatedness2 results
# Pairwise relatedness was estimated using VCFtools --relatedness2 on the full genomic dataset.

# Purpose:
# 1. Identify highly related pairs using a kinship threshold of >0.0884 (half sibs or closer).
# 2. Annotate pairwise kinship estimates with sex and island metadata.
# 3. Summarise relatedness by sex to investigate potential patterns of sex-biased migration.

# The single individual labelled "pupa" was excluded from sex-specific summaries because its sex could not be determined.

library(dplyr)
library(tidyr)

# 1. Read sample metadata and exclude the individual pupa of unknown sex.
meta <- read.table(
  "path/to/Galap24_sample_metadata.tsv",
  header = TRUE, sep = "\t", stringsAsFactors = FALSE
)
meta <- meta[tolower(meta$Sex) != "pupa", ]

# 2. Read pairwise kinship estimates for the full dataset.
Kinship_All <- read.table(
  "path/to/relatedness_no_self_comparisons.txt",
  header = TRUE, sep = "\t"
)
colnames(Kinship_All) <- c(
  "INDV1", "INDV2", "IBS0", "IBS1",
  "SNP_COUNT", "N_AA", "KINSHIP"
)
Kinship_All$INDV1 <- as.character(Kinship_All$INDV1)
Kinship_All$INDV2 <- as.character(Kinship_All$INDV2)

# 3. Annotate each individual in each pair with sex and island.
Kinship_All <- Kinship_All %>%
  left_join(
    meta[, c("SampleID", "Sex", "Island")],
    by = c("INDV1" = "SampleID")
  ) %>%
  rename(Sex1 = Sex, Island1 = Island) %>%
  left_join(
    meta[, c("SampleID", "Sex", "Island")],
    by = c("INDV2" = "SampleID")
  ) %>%
  rename(Sex2 = Sex, Island2 = Island)

Kinship_All$Sex1 <- tolower(Kinship_All$Sex1)
Kinship_All$Sex2 <- tolower(Kinship_All$Sex2)
Kinship_All$Island1 <- as.character(Kinship_All$Island1)
Kinship_All$Island2 <- as.character(Kinship_All$Island2)

# 4. Calculate mean pairwise kinship across the full dataset.
individuals <- unique(c(Kinship_All$INDV1, Kinship_All$INDV2))
Kinship_matrix <- matrix(
  NA, nrow = length(individuals), ncol = length(individuals),
  dimnames = list(individuals, individuals)
)

for (i in 1:nrow(Kinship_All)) {
  id1 <- Kinship_All$INDV1[i]
  id2 <- Kinship_All$INDV2[i]
  kin <- Kinship_All$KINSHIP[i]
  Kinship_matrix[id1, id2] <- kin
  Kinship_matrix[id2, id1] <- kin
}

diag(Kinship_matrix) <- 0.5
Kinship_All_no_diag <- Kinship_matrix[upper.tri(Kinship_matrix)]
average_kinship_All <- mean(Kinship_All_no_diag, na.rm = TRUE)

cat(
  "Average kinship (all pairs):",
  round(average_kinship_All, 3), "\n"
)

# 5. Export the annotated pairwise kinship table.
write.table(
  Kinship_All, "Kinship_All_annotated.tsv",
  sep = "\t", quote = FALSE, row.names = FALSE
)

# 6. Identify highly related pairs (kinship >0.0884).
high_kinship_pairs <- subset(Kinship_All, KINSHIP > 0.0884)
write.table(
  high_kinship_pairs, "high_kinship_pairs.txt",
  sep = "\t", quote = FALSE, row.names = FALSE
)

# 7. Calculate mean kinship among pairs of the same sex on the same island.
Kinship_same <- Kinship_All %>%
  filter(
    !is.na(Sex1), !is.na(Sex2),
    !is.na(Island1), !is.na(Island2),
    Sex1 == Sex2, Island1 == Island2
  )

kinship_summary <- Kinship_same %>%
  group_by(Island = Island1, Sex = Sex1) %>%
  summarise(
    Average_Kinship = mean(KINSHIP, na.rm = TRUE),
    .groups = "drop"
  )

kinship_wide <- kinship_summary %>%
  pivot_wider(names_from = Sex, values_from = Average_Kinship)

kinship_wide[, -1] <- round(kinship_wide[, -1], 4)

write.csv(
  kinship_wide, "average_kinship_island_by_sex.csv",
  row.names = FALSE, quote = FALSE
)
print(kinship_wide)

# 8. Calculate each individual's mean relatedness to other individuals
# on the same island, then summarise by island and sex.
individual_kinship <- Kinship_All %>%
  filter(
    INDV1 != INDV2,
    !is.na(Sex1), !is.na(Island1),
    !is.na(Island2),
    Island1 == Island2
  ) %>%
  group_by(INDV1, Sex1, Island1) %>%
  summarise(
    Average_Relatedness = mean(KINSHIP, na.rm = TRUE),
    .groups = "drop"
  )

summary_table <- individual_kinship %>%
  group_by(Island1, Sex1) %>%
  summarise(
    Mean_Average_Relatedness = mean(
      Average_Relatedness, na.rm = TRUE
    ),
    .groups = "drop"
  )

summary_wide <- summary_table %>%
  pivot_wider(names_from = Sex1, values_from = Mean_Average_Relatedness)

summary_wide[, -1] <- round(summary_wide[, -1], 4)

write.csv(
  summary_wide, "average_relatedness_to_all_by_island_sex.csv",
  row.names = FALSE, quote = FALSE
)
print(summary_wide)
