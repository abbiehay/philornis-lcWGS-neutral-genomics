# ============================================================
# BeXY: Classify scaffolds using posterior karyotype probabilities (R Script)
# ============================================================
#
# Input: BeXY scaffold karyotype posterior probabilities
# Output:
#   - Scaffold posterior probabilities and classifications
#   - High-confidence scaffold lists
#   - Histograms and plots of scaffold classifications
#   - Summary statistics for posterior probabilities
#
# BeXY repository: https://bitbucket.org/WegmannLab/bexy.git


# 1. Load packages
# ------------------------------------------------------------

# Install the local BeXY package if required:
# install.packages("path/to/bexy_0.1.3.tar.gz",
#                  repos = NULL, type = "source")

library(bexy)
library(ggplot2)
library(ggrepel)


# 2. Define input and output paths
# ------------------------------------------------------------

INPUT_FILE <- "path/to/BeXY/bexy_output_189Ind_t_statePosteriors.txt"
OUTPUT_DIR <- "path/to/BeXY/posterior_analysis"

dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)


# 3. Load and organise posterior probabilities
# ------------------------------------------------------------

# Load posterior probabilities for scaffold karyotype assignments.
# Expected format: four rows (autosome, Y, X, different),
# with one column per scaffold.

t_post <- read.table(INPUT_FILE, header = TRUE)

# Check input dimensions.
dim(t_post)

# Assign karyotype categories to rows.
rownames(t_post) <- c("autosome", "Y", "X", "different")

# Transpose so each row represents a scaffold and each column
# represents its posterior probability for a karyotype category.
probs <- as.data.frame(t(t_post))

colnames(probs) <- c("autosome", "Y", "X", "different")

# Add scaffold names as a column.
probs$scaffold <- rownames(probs)

# Place scaffold names in the first column and reset row names.
probs <- probs[, c("scaffold", "autosome", "Y", "X", "different")]
rownames(probs) <- NULL

# Assign each scaffold to the category with the highest posterior
# probability. This is the most probable category, not necessarily
# a high-confidence assignment.
categories <- c("autosome", "Y", "X", "different")

probs$type <- apply(
  probs[, categories],
  1,
  function(x) categories[which.max(x)]
)

# Inspect classifications and count scaffolds per category.
head(probs)
table(probs$type)

# Save posterior probabilities and scaffold classifications.
write.table(
  probs,
  file.path(OUTPUT_DIR, "scaffold_karyotype_probs.txt"),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# 4. Identify high-confidence sex-linked scaffolds
# ------------------------------------------------------------

# Retain scaffolds with posterior probability >0.99 for X, Y,
# or different, where that category is more probable than the
# other sex-linked categories.

sex_linked_confident <- subset(
  probs,
  (X > 0.99 & X > Y & X > different) |
  (Y > 0.99 & Y > X & Y > different) |
  (different > 0.99 & different > X & different > Y)
)

rownames(sex_linked_confident) <- NULL

# Assign the most probable sex-linked category.
sex_linked_confident$type <- apply(
  sex_linked_confident[, c("X", "Y", "different")],
  1,
  function(x) c("X", "Y", "different")[which.max(x)]
)

sex_linked_confident <- sex_linked_confident[
  , c("scaffold", "autosome", "Y", "X", "different", "type")
]

head(sex_linked_confident)

write.table(
  sex_linked_confident,
  file.path(OUTPUT_DIR, "sex_linked_scaffolds_confident.txt"),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# 5. Count scaffolds assigned to each category
# ------------------------------------------------------------

type_counts <- table(probs$type)

df_counts <- as.data.frame(type_counts)
colnames(df_counts) <- c("Scaffold_Type", "Count")

# Bar plot of the number of scaffolds assigned to each category.
p_counts <- ggplot(
  df_counts,
  aes(x = Scaffold_Type, y = Count, fill = Scaffold_Type)
) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(
    title = "Number of Scaffolds by Type",
    x = "Scaffold Type",
    y = "Number of Scaffolds"
  )

print(p_counts)

ggsave(
  file.path(OUTPUT_DIR, "scaffold_types_barplot.png"),
  plot = p_counts,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)


# 6. Examine posterior probabilities for X-linked scaffolds
# ------------------------------------------------------------

# Select scaffolds for which X has the highest posterior probability.
x_scaffolds <- subset(probs, type == "X")

# Count X-assigned scaffolds with posterior probability below 0.8.
X_n_under_0.8 <- sum(x_scaffolds$X < 0.8)
X_n_under_0.8

# Plot the distribution of posterior probabilities for X.
p_x <- ggplot(x_scaffolds, aes(x = X)) +
  geom_histogram(
    binwidth = 0.02,
    fill = "#F8766D",
    color = "black"
  ) +
  labs(
    title = "Posterior Probabilities for X-Linked Scaffolds",
    subtitle = "Scaffolds where X has the highest posterior probability",
    x = "Posterior Probability of X",
    y = "Number of Scaffolds"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    panel.border = element_blank()
  ) +
  scale_y_continuous(breaks = seq(0, 2500, 500))

print(p_x)

ggsave(
  file.path(OUTPUT_DIR, "x_scaffolds_histogram.png"),
  plot = p_x,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)

# Export scaffolds with posterior probability of X >0.99.
high_conf_x <- subset(probs, X > 0.99)
x_scaffold_names <- high_conf_x$scaffold

write.table(
  x_scaffold_names,
  file.path(OUTPUT_DIR, "high_confidence_X-linked_scaffolds.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)


# 7. Examine posterior probabilities for Y-linked scaffolds
# ------------------------------------------------------------

# Select scaffolds for which Y has the highest posterior probability.
y_scaffolds <- subset(probs, type == "Y")

# Count Y-assigned scaffolds with posterior probability below 0.99.
Y_n_under_0.99 <- sum(y_scaffolds$Y < 0.99)
Y_n_under_0.99

# Plot the distribution of posterior probabilities for Y.
p_y <- ggplot(y_scaffolds, aes(x = Y)) +
  geom_histogram(
    binwidth = 0.02,
    fill = "skyblue2",
    color = "black"
  ) +
  labs(
    title = "Posterior Probabilities for Y-Linked Scaffolds",
    subtitle = "Scaffolds where Y has the highest posterior probability",
    x = "Posterior Probability of Y",
    y = "Number of Scaffolds"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    panel.border = element_blank()
  )

print(p_y)

ggsave(
  file.path(OUTPUT_DIR, "y_scaffolds_histogram.png"),
  plot = p_y,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)

# Export scaffolds with posterior probability of Y >0.99.
high_conf_y <- subset(probs, Y > 0.99)
y_scaffold_names <- high_conf_y$scaffold

write.table(
  y_scaffold_names,
  file.path(OUTPUT_DIR, "high_confidence_Y-linked_scaffolds.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)


# 8. Examine posterior probabilities for autosomal scaffolds
# ------------------------------------------------------------

# Select scaffolds for which autosome has the highest posterior probability.
auto_scaffolds <- subset(probs, type == "autosome")

# Count autosome-assigned scaffolds with posterior probability >0.99.
auto_n_above_0.99 <- sum(auto_scaffolds$autosome > 0.99)
auto_n_above_0.99

# Identify all scaffolds with autosome posterior probability <0.99,
# regardless of their most probable category.
non_autosomes_under_0.99 <- subset(probs, autosome < 0.99)

non_auto_scaffolds <- non_autosomes_under_0.99$scaffold

write.table(
  non_auto_scaffolds,
  file.path(OUTPUT_DIR, "scaffolds_less_than_0.99_autosome_prob.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)

# Plot autosome posterior probabilities for scaffolds where
# autosome is the most probable category.
p_aut <- ggplot(auto_scaffolds, aes(x = autosome)) +
  geom_histogram(
    binwidth = 0.02,
    fill = "springgreen3",
    color = "black"
  ) +
  labs(
    title = "Posterior Probabilities for Autosomal Scaffolds",
    subtitle = "Scaffolds where autosome has the highest posterior probability",
    x = "Posterior Probability of Autosome",
    y = "Number of Scaffolds"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    panel.border = element_blank()
  )

print(p_aut)

ggsave(
  file.path(OUTPUT_DIR, "autosome_scaffolds_histogram.png"),
  plot = p_aut,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)

# Export scaffolds with autosome posterior probability <0.99.
not_autosomes <- subset(probs, autosome < 0.99)
non_autosome_scaffold_names <- not_autosomes$scaffold

write.table(
  non_autosome_scaffold_names,
  file.path(OUTPUT_DIR, "non_autosome_scaffolds.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)

# Export high-confidence autosomal scaffolds with posterior probability >0.99.
high_conf_autosomes <- subset(probs, autosome > 0.99)
autosomal_scaffold_names <- high_conf_autosomes$scaffold

write.table(
  autosomal_scaffold_names,
  file.path(OUTPUT_DIR, "high_confidence_autosomes.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)


# 9. Export high-confidence X-, Y-, and combined XY-linked scaffolds
# ------------------------------------------------------------

# Sort X-linked scaffolds by decreasing posterior probability.
high_conf_x <- probs[probs$X > 0.99, ]
high_conf_x <- high_conf_x[order(-high_conf_x$X), ]

write.table(
  high_conf_x$scaffold,
  file.path(OUTPUT_DIR, "high_confidence_X_scaffolds_sorted.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)

# Sort Y-linked scaffolds by decreasing posterior probability.
high_conf_y <- probs[probs$Y > 0.99, ]
high_conf_y <- high_conf_y[order(-high_conf_y$Y), ]

write.table(
  high_conf_y$scaffold,
  file.path(OUTPUT_DIR, "high_confidence_Y_scaffolds_sorted.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)

# Combine high-confidence X- and Y-linked scaffold names.
xy_scaffolds <- c(high_conf_x$scaffold, high_conf_y$scaffold)

write.table(
  xy_scaffolds,
  file.path(OUTPUT_DIR, "high_confidence_XY_scaffolds.txt"),
  quote = FALSE,
  row.names = FALSE,
  col.names = FALSE
)


# 10. Plot the overall distribution of scaffold classifications
# ------------------------------------------------------------

# Calculate scaffold counts and percentages for each most probable category.
type_counts <- table(probs$type)

df_counts <- as.data.frame(type_counts)
colnames(df_counts) <- c("Scaffold_Type", "Count")

df_counts$Percent <- round(
  100 * df_counts$Count / sum(df_counts$Count),
  1
)

df_counts$Label <- paste0(
  df_counts$Scaffold_Type, "\n",
  df_counts$Count, " (", df_counts$Percent, "%)"
)

# Calculate segment boundaries and label positions for the pie chart.
df_counts <- df_counts[order(-df_counts$Count), ]
df_counts$ymax <- cumsum(df_counts$Count)
df_counts$ymin <- c(0, head(df_counts$ymax, -1))
df_counts$ypos <- (df_counts$ymin + df_counts$ymax) / 2

p_pie <- ggplot(
  df_counts,
  aes(ymax = ymax, ymin = ymin, xmax = 1, xmin = 0, fill = Scaffold_Type)
) +
  geom_rect(color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "Distribution of Scaffold Types") +
  geom_label_repel(
    aes(x = 1.2, y = ypos, label = Label),
    nudge_x = 0.5,
    segment.size = 0.5,
    show.legend = FALSE,
    size = 6,
    box.padding = 0.3,
    direction = "y"
  ) +
  scale_fill_manual(
    values = c(
      "autosome" = "springgreen3",
      "Y" = "skyblue2",
      "X" = "#F8766D",
      "different" = "grey70"
    )
  ) +
  theme(
    legend.title = element_text(size = 16, face = "bold"),
    legend.text = element_text(size = 14),
    legend.position = c(0.1, 0.1),
    legend.justification = c("left", "bottom"),
    legend.margin = margin(0, 0, 0, 0)
  )

print(p_pie)

ggsave(
  file.path(OUTPUT_DIR, "scaffold_types_pie_chart.png"),
  plot = p_pie,
  width = 6,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)


# 11. Calculate the proportion of category-assigned scaffolds
#     with posterior probability >0.99
# ------------------------------------------------------------

# These percentages are calculated among scaffolds where each category
# has the highest posterior probability.

prop_auto_highconf <- mean(auto_scaffolds$autosome > 0.99) * 100
prop_x_highconf <- mean(x_scaffolds$X > 0.99) * 100
prop_y_highconf <- mean(y_scaffolds$Y > 0.99) * 100

cat(
  "Autosome-assigned scaffolds with Pr(autosome) > 0.99:",
  round(prop_auto_highconf, 1), "%\n"
)

cat(
  "X-assigned scaffolds with Pr(X) > 0.99:",
  round(prop_x_highconf, 1), "%\n"
)

cat(
  "Y-assigned scaffolds with Pr(Y) > 0.99:",
  round(prop_y_highconf, 1), "%\n"
)

# NEXT: Use scaffolds with >0.99 posterior probability of being autosomal for subsequent SNP filtering.