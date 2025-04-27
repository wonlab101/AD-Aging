library(ggplot2)
library(dplyr)
library(data.table)
library(patchwork)

# Basic settings
position_dodge_val <- position_dodge(width = 0.5)
colors <- c("Unique AD" = "#FF7F00", "AD" = "#FDBE85", "AD-Linked Aging" = "#1F78B4", "Aging" = "#A6C8E3")

# Load phenotype mapping file
mappingf <- fread("./updated_pheno_rg_mapping.txt")

# Function to load and annotate genetic correlation results
load_and_annotate <- function(file_path, label) {
  df <- fread(file_path)
  colnames(df) <- c("p1", "p2", "rg", "se", "z", "p", "h2_obs", "h2_obs_se",
                    "h2_int", "h2_int_se", "gcov_int", "gcov_int_se")
  df <- df %>%
    distinct(p2, .keep_all = TRUE) %>%
    left_join(mappingf, by = c("p2" = "Filename")) %>%
    select(SubchapterLevel, Description, p2, rg, se, z, p) %>%
    filter(!is.na(SubchapterLevel)) %>%
    group_by(SubchapterLevel) %>%
    mutate(p_fdr = p.adjust(p, method = "fdr")) %>%
    ungroup() %>%
    mutate(
      p_star = cut(p_fdr, breaks = c(-Inf, 0.001, 0.01, 0.05, Inf),
                   labels = c("***", "**", "*", ""), right = FALSE),
      p1 = label
    )
  return(df)
}

# Load datasets
data_long2 <- load_and_annotate("./factor2_GCresults.txt", "Unique AD")
data_long1 <- load_and_annotate("./factor1_GCresults.txt", "AD-Linked Aging")
AD          <- load_and_annotate("./OriginalAD_GCresults.txt", "AD")
Aging       <- load_and_annotate("./OriginalAging_GCresults.txt", "Aging")

# Filter significant results only
data_long1_new <- data_long1 %>% filter(p_star != "")
data_long2_new <- data_long2 %>% filter(p_star != "")
AD_new <- AD %>% filter(p_star != "")
Aging_new <- Aging %>% filter(p_star != "")

# Custom theme
custom_theme <- theme_minimal() +
  theme(
    strip.text.y.right = element_text(size = 10, face = "bold"),
    strip.placement = "outside",
    axis.text.y = element_text(size = 10, hjust = 1),
    legend.position = "none",
    panel.border = element_rect(color = "black", fill = NA, size = 1),
    panel.spacing.y = unit(0.2, "lines")
  )

# Preprocess for plotting
preprocess_gc_data <- function(df, p1_label) {
  df$p1 <- p1_label
  df$SubchapterLevel <- gsub(" ", "\n", df$SubchapterLevel)
  df$Description <- df$Description %>%
    gsub("Schizophrenia \\(2022\\)", "Schizophrenia", .) %>%
    gsub("Major depression \\(2023\\)", "Major depression", .) %>%
    gsub("Ischemic Heart Disease", "Ischemic heart disease", .) %>%
    gsub("white\\.matter", "White matter", .) %>%
    gsub("gray\\.matter", "Gray matter", .) %>%
    gsub("left\\.inferior\\.parietal", "Left inferior parietal", .)
  df <- df %>%
    mutate(
      text_offset = case_when(p1 %in% c("Unique AD", "AD") ~ 0.07, TRUE ~ -0.07),
      v_offset = case_when(p1 %in% c("Unique AD", "AD-Linked Aging") ~ 0.7, TRUE ~ -0.7)
    )
  return(df)
}

# Common plotting function
plot_gc <- function(df) {
  ggplot(df, aes(x = rg, y = Description, color = p1)) +
    geom_point(size = 4, alpha = 0.5, position = position_dodge_val) +
    geom_errorbarh(aes(xmin = pmax(rg - se, -1.1), xmax = pmin(rg + se, 1.1)),
                   height = 0.2, alpha = 0.6, size = 1.5, position = position_dodge_val) +
    geom_text(aes(x = rg + text_offset, label = p_star, vjust = v_offset),
              size = 3, position = position_dodge_val) +
    geom_vline(xintercept = 0, color = "black", linetype = "solid", size = 0.5) +
    scale_x_continuous(breaks = seq(-1.0, 1.0, by = 0.2), limits = c(-1.1, 1.1), expand = c(0, 0)) +
    scale_color_manual(values = colors) +
    facet_grid(rows = vars(SubchapterLevel), scales = "free_y", space = "free") +
    labs(x = expression("Genetic correlation (" * italic(r)[g] * ")"), y = "", color = "Category") +
    custom_theme
}

# --- Plot 1: Based on significant traits from Unique AD and AD
sig_traits <- union(data_long2_new$p2, AD_new$p2) %>% unique()

final_dt <- bind_rows(
  preprocess_gc_data(data_long2 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Unique AD"),
  preprocess_gc_data(data_long1 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD-Linked Aging"),
  preprocess_gc_data(Aging      %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging"),
  preprocess_gc_data(AD         %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD")
)

final_dt$SubchapterLevel <- factor(final_dt$SubchapterLevel, levels = c(
  "Cognitive\nfunction", "Mental\nhealth", "Neuroticism", "Neurological\ndiseases",
  "Psychiatric\ndisorders", "Physical\nhealth", "Laboratory\nand\nPhysical\nfindings"
))

p1 <- plot_gc(final_dt)

# --- Plot 2: Brain structure (DTI and ROI) based on AD-linked Aging + Aging
sig_traits <- union(data_long1_new$p2, Aging_new$p2) %>% unique()

roi_dt <- bind_rows(
  preprocess_gc_data(data_long1 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD-Linked Aging"),
  preprocess_gc_data(data_long2 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Unique AD"),
  preprocess_gc_data(Aging      %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging"),
  preprocess_gc_data(AD         %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD")
)

roi_dt <- roi_dt %>% filter(SubchapterLevel %in% c("DTI110", "ROI101"))
roi_dt$SubchapterLevel <- factor(roi_dt$SubchapterLevel, levels = c("DTI110", "ROI101"))
p2 <- plot_gc(roi_dt)

# --- Plot 3: AD biomarkers
bio_dt <- bind_rows(
  preprocess_gc_data(data_long2 %>% filter(SubchapterLevel == "AD biomarker"), "Unique AD"),
  preprocess_gc_data(data_long1 %>% filter(SubchapterLevel == "AD biomarker"), "AD-Linked Aging"),
  preprocess_gc_data(Aging      %>% filter(SubchapterLevel == "AD biomarker"), "Aging"),
  preprocess_gc_data(AD         %>% filter(SubchapterLevel == "AD biomarker"), "AD")
)
p3 <- plot_gc(bio_dt)

# --- Combine all plots
combined_plot <- p1 + (p2 / p3) +
  plot_layout(widths = c(1, 1)) +
  plot_annotation(tag_levels = 'a') &
  theme(plot.tag = element_text(size = 16, face = "plain"))

# Show combined plot
print(combined_plot)

# Save to PDF
ggsave("/data1/hyejin/Practice/GBS/results/fig2_gc_combined.pdf", plot = combined_plot,
       width = 21, height = 15, device = cairo_pdf)
