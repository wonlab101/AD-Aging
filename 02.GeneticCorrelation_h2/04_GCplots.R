library(ggplot2)
library(dplyr)
library(data.table)
library(patchwork)

# Basic settings
position_dodge_val <- position_dodge(width = 0.5)
colors <- c("Aging-independent AD" = "#FF7F00", "AD" = "#FDBE85", "Aging" = "#A6C8E3")

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
data_long2 <- load_and_annotate("./factor2_GCresults.txt", "Aging-independent AD")
AD         <- load_and_annotate("./OriginalAD_GCresults.txt", "AD")
Aging      <- load_and_annotate("./OriginalAging_GCresults.txt", "Aging")

# Filter significant results only
data_long2_new <- data_long2 %>% filter(p_star != "")
AD_new <- AD %>% filter(p_star != "")
Aging_new <- Aging %>% filter(p_star != "")

# Custom theme
theme_step1 <- function(base_size = 11, base_family = "",
                        base_line_size = base_size / 22,
                        base_rect_size = base_size / 22) {
  theme(
    title = element_text(family = 'Arial', size = 18, color = 'black'),
    text = element_text(family = 'Arial', size = 16, color = 'black'),
    axis.title = element_text(family = 'Arial', size = 18, color = 'black'),
    axis.text = element_text(family = 'Arial', size = 16, color = 'black'), 
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line = element_line(colour = "black", size = rel(1)),
    legend.background = element_rect(color = 'black'),
    legend.title = element_text(family = 'Arial', size = 16),
    legend.text = element_text(family = 'Arial', size = 14),
    legend.direction = "vertical",
    legend.box = c("horizontal", "vertical"),
    legend.spacing.x = unit(0.1, 'cm'),
    plot.margin = unit(c(0.25, 1, 1, 0.5), 'cm'),
    axis.title.y = element_text(margin = margin(r = 10, unit = "pt")),
    axis.text.x = element_text(angle = 90, hjust = 1)  # Move x-axis rotation here
  )
}

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
      text_offset = case_when(p1 == "Aging-independent AD" ~ 0.07, TRUE ~ -0.07),
      v_offset = case_when(p1 == "Aging-independent AD" ~ 0.7, TRUE ~ -0.7)
    )
  return(df)
}

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
    theme_step1()
}

# Plot 1: External traits
sig_traits <- union(data_long2_new$p2, AD_new$p2) %>% unique()

final_dt <- bind_rows(
  preprocess_gc_data(data_long2 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging-independent AD"),
  preprocess_gc_data(Aging      %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging"),
  preprocess_gc_data(AD         %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD")
)

final_dt$SubchapterLevel <- factor(final_dt$SubchapterLevel, levels = c(
  "Cognitive\nfunction", "Mental\nhealth", "Neuroticism", "Neurological\ndiseases",
  "Psychiatric\ndisorders", "Physical\nhealth", "Laboratory\nand\nPhysical\nfindings"
))

p1 <- plot_gc(final_dt)

# Plot 2: Brain structure (DTI and ROI)
sig_traits <- union(data_long2_new$p2, Aging_new$p2) %>% unique()

roi_dt <- bind_rows(
  preprocess_gc_data(data_long2 %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging-independent AD"),
  preprocess_gc_data(Aging      %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "Aging"),
  preprocess_gc_data(AD         %>% semi_join(data.frame(p2 = sig_traits), by = "p2"), "AD")
)

roi_dt <- roi_dt %>% filter(SubchapterLevel %in% c("DTI110", "ROI101"))
roi_dt$SubchapterLevel <- factor(roi_dt$SubchapterLevel, levels = c("DTI110", "ROI101"))
p2 <- plot_gc(roi_dt)

# Plot 3: AD biomarkers
bio_dt <- bind_rows(
  preprocess_gc_data(data_long2 %>% filter(SubchapterLevel == "AD biomarker"), "Aging-independent AD"),
  preprocess_gc_data(Aging      %>% filter(SubchapterLevel == "AD biomarker"), "Aging"),
  preprocess_gc_data(AD         %>% filter(SubchapterLevel == "AD biomarker"), "AD")
)
p3 <- plot_gc(bio_dt)

# Combine all plots
combined_plot <- p1 + (p2 / p3) +
  plot_layout(widths = c(1, 1)) +
  plot_annotation(tag_levels = 'a') &
  theme(plot.tag = element_text(size = 16, face = "plain"))

# Show combined plot
print(combined_plot)

# Save to PDF
ggsave("/data1/hyejin/Practice/GBS/results/fig2_gc_combined.pdf", plot = combined_plot,
       width = 21, height = 15, device = cairo_pdf)
