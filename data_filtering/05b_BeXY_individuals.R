# ============================================================
# Infer individual sex karyotypes from BeXY posterior probabilities
# ============================================================

# Install BeXY if needed (run once)
# install.packages("path/to/bexy_0.1.3.tar.gz", repos = NULL, type = "source")

library(bexy)
library(ggplot2)
library(ggrepel)

# ------------------------------------------------------------
# 1. Define input and output paths
# ------------------------------------------------------------

INPUT_FILE <- "path/to/BeXY/bexy_output_189Ind_s_statePosteriors.txt"
OUTPUT_DIR <- "path/to/BeXY/individual_karyotype_analysis"

dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------
# 2. Load and format posterior probabilities
# ------------------------------------------------------------

# Load posterior probabilities for each individual's possible karyotypes
s_post <- read.table(INPUT_FILE, header = TRUE)

# Check the dimensions of the input table
dim(s_post)

# Assign karyotype names to the posterior probability rows
rownames(s_post) <- c("XY", "XX", "X", "XXY", "XYY", "XXX", "XXYY")

# Transpose so individuals are rows and karyotypes are columns
indiv_probs <- as.data.frame(t(s_post))
colnames(indiv_probs) <- rownames(s_post)

# Add individual IDs and move them to the first column
indiv_probs$individual <- rownames(indiv_probs)
indiv_probs <- indiv_probs[, c("individual", setdiff(names(indiv_probs), "individual"))]
rownames(indiv_probs) <- NULL

# Infer each individual's karyotype from the highest posterior probability
karyotype_names <- rownames(s_post)

indiv_probs$karyotype <- apply(
  indiv_probs[, karyotype_names],
  1,
  function(x) karyotype_names[which.max(x)]
)

# Check the inferred karyotypes and posterior probabilities
head(indiv_probs)

# Export posterior probabilities and inferred karyotypes
write.table(
  indiv_probs,
  file = file.path(OUTPUT_DIR, "individual_karyotype_probs.txt"),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

# Count individuals assigned to each karyotype
table(indiv_probs$karyotype)

# ------------------------------------------------------------
# 3. Plot the number of individuals per inferred karyotype
# ------------------------------------------------------------

karyotype_counts <- as.data.frame(table(indiv_probs$karyotype))
colnames(karyotype_counts) <- c("Karyotype", "Count")

p_karyotype_counts <- ggplot(
  karyotype_counts,
  aes(x = Karyotype, y = Count, fill = Karyotype)
) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(
    title = "Number of Individuals by Inferred Sex Karyotype",
    x = "Karyotype",
    y = "Count"
  )

print(p_karyotype_counts)

# ------------------------------------------------------------
# 4. Plot the distribution of inferred karyotypes
# ------------------------------------------------------------

# Calculate counts, percentages, and label positions
total_n <- sum(karyotype_counts$Count)

karyotype_counts$Percent <- round(
  100 * karyotype_counts$Count / total_n,
  1
)

karyotype_counts$ymax <- cumsum(karyotype_counts$Count)
karyotype_counts$ymin <- c(0, head(karyotype_counts$ymax, -1))
karyotype_counts$ypos <- (karyotype_counts$ymax + karyotype_counts$ymin) / 2

# Create labels showing karyotype, count, and percentage
karyotype_counts$Label <- paste0(
  karyotype_counts$Karyotype, ": ",
  karyotype_counts$Count, " (",
  karyotype_counts$Percent, "%)"
)

p_karyotype_pie <- ggplot(
  karyotype_counts,
  aes(ymax = ymax, ymin = ymin, xmax = 1, xmin = 0, fill = Karyotype)
) +
  geom_rect(color = "white") +
  coord_polar(theta = "y") +
  theme_void() +
  labs(title = "Distribution of Inferred Sex Karyotypes in Individuals") +
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
      "XX" = "purple",
      "XY" = "orange",
      "X" = "brown",
      "XXY" = "steelblue",
      "XYY" = "darkgreen",
      "XXX" = "pink",
      "XXYY" = "grey50"
    )
  ) +
  theme(
    legend.title = element_text(size = 16, face = "bold"),
    legend.text = element_text(size = 14),
    legend.position = c(0.1, 0.1),
    legend.justification = c("left", "bottom"),
    legend.margin = margin(0, 0, 0, 0)
  )

print(p_karyotype_pie)

ggsave(
  filename = file.path(OUTPUT_DIR, "individual_karyotype_pie_chart.png"),
  plot = p_karyotype_pie,
  width = 6,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white"
)

# ------------------------------------------------------------
# 5. Plot posterior probabilities for individuals assigned XX
#    or XY karyotypes
# ------------------------------------------------------------

# Subset individuals by their inferred karyotype
indiv_xx <- subset(indiv_probs, karyotype == "XX")
indiv_xy <- subset(indiv_probs, karyotype == "XY")

# Extract posterior probabilities for the assigned karyotypes
xx_post <- indiv_xx$XX
xy_post <- indiv_xy$XY

# XX posterior probabilities
p_xx <- ggplot(indiv_xx, aes(x = XX)) +
  geom_histogram(binwidth = 0.02, fill = "purple", color = "black") +
  labs(
    title = "Posterior Probability for XX Individuals",
    x = "Posterior Probability (XX)",
    y = "Number of Individuals"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    panel.border = element_blank()
  ) +
  scale_y_continuous(
    breaks = seq(
      0,
      max(table(cut(xx_post, breaks = seq(0, 1, by = 0.02)))),
      5
    )
  )

# XY posterior probabilities
p_xy <- ggplot(indiv_xy, aes(x = XY)) +
  geom_histogram(
    binwidth = 0.02,
    fill = "orange",
    color = "black",
    boundary = 0
  ) +
  labs(
    title = "Posterior Probability for XY Individuals",
    x = "Posterior Probability (XY)",
    y = "Number of Individuals"
  ) +
  scale_x_continuous(
    limits = c(0.5, 1),
    breaks = seq(0.5, 1, 0.1)
  ) +
  scale_y_continuous(breaks = seq(0, 60, 5)) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    panel.border = element_blank()
  )

# Display and save histograms
print(p_xx)
print(p_xy)

ggsave(
  file.path(OUTPUT_DIR, "xx_individuals_histogram.png"),
  plot = p_xx,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)

ggsave(
  file.path(OUTPUT_DIR, "xy_individuals_histogram.png"),
  plot = p_xy,
  width = 6,
  height = 4,
  dpi = 300,
  units = "in",
  bg = "white"
)

# ------------------------------------------------------------
# 6. Inspect individuals assigned to the X karyotype
# ------------------------------------------------------------

indiv_x <- subset(indiv_probs, karyotype == "X")

# Print individual IDs and their posterior probabilities for X
print(indiv_x[, c("individual", "X")])

# ------------------------------------------------------------
# 7. Identify individuals whose maximum posterior probability
#    is less than 1
# ------------------------------------------------------------

# Calculate the highest posterior probability across all karyotypes
indiv_probs$max_prob <- apply(
  indiv_probs[, karyotype_names],
  1,
  max
)

# Subset individuals whose maximum posterior probability is < 1
indiv_less_than_1 <- subset(indiv_probs, max_prob < 1)

# Print their inferred karyotypes and all posterior probabilities
print(
  indiv_less_than_1[
    ,
    c(
      "individual", "karyotype",
      "XY", "XX", "X", "XXY", "XYY", "XXX", "XXYY"
    )
  ]
)
