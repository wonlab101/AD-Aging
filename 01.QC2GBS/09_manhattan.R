setwd("/data1/hyejin/Practice/GBS/")
library(data.table)
library(dplyr)
library(gwaRs)
library(ggplot2)

#### factor2
df1 <- fread("./data/AD_aging_GBS_v2_factor2_reformatted.tsv", sep="\t", data.table=F, nThread=15)

df1 <- df1 %>%
  dplyr::select(CHR, SNP, BP, P) %>%
  filter(P != "0")

#### factor1
df2 <- fread("./data/AD_aging_GBS_v2_factor1_reformatted.tsv", sep="\t", data.table=F, nThread=15)

df2 <- df2 %>%
  dplyr::select(CHR, SNP, BP, P) %>%
  filter(P != "0")

df1$Trait <- "Unique AD"
df2$Trait <- "AD-Linked Aging"
mirroredData <- rbind(df1, df2)

mirrored_plot<-mirrored_man_plot(mirroredData, trait1 = "Unique AD", trait2 = "AD-Linked Aging",
                                 genomewideline_trait1 = -log10(5e-08), genomewideline_trait2 = -log10(5e-08),
                                 suggestiveline_trait1 = -log10(1e-06), suggestiveline_trait2 = -log10(1e-06),
                                 suggestiveline_color = "black", suggestiveline_type = "solid",
                                 trait1_chromCols = c("#FF7F00", "#FDBE85"),
                                 trait2_chromCols = c("#1F78B4", "#A6C8E3")) + theme_step1()  
print(mirrored_plot)

theme_step1 <- function(base_size = 11, base_family = "",
                        base_line_size = base_size / 22,
                        base_rect_size = base_size / 22,
                        remove_labels = TRUE) { 
  theme(
    text = element_text(family = 'Arial', size = 16, color = 'black'),
    axis.title = element_text(family = 'Arial', size = 18, color = 'black'),
    axis.text = element_text(family = 'Arial', size = 20, color = 'black'),  
    panel.border = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = "white", colour = NA),
    axis.line = element_line(colour = "black", size = rel(1)),
    plot.margin = unit(c(0.25, 1, 1, 0.5), 'cm'),
    axis.title.y = element_text(margin = margin(r = 10, unit = "pt")),
    axis.text.x = element_text(angle = 90, hjust = 1),
    
    plot.tag = if (remove_labels) element_blank() else NULL
  )
}

ggsave("./results/mirrored_manhattan.png", plot = mirrored_plot, width = 6, height = 9, dpi = 300)

