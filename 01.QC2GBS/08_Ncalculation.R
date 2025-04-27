## (Updated) 2025-02-14

setwd("/data1/hyejin/Practice/GBS/data")
getwd()

library(data.table)
library(dplyr)


AD_aging_GBS_v2_factor1 <- fread("./AD_aging_GBS_v2_factor1", data.table = F)
AD_aging_GBS_v2_factor2 <- fread("./AD_aging_GBS_v2_factor2", data.table = F)


##################################
###__Preprocess for formatting ###
##################################
process_GBSdata <- function(data) {
  processed_data <- data %>%
    filter((error == 0) & (warning == 0)) %>%
    rename(BETA = est, P = Pval_Estimate, Z = Z_Estimate) %>%
    dplyr::select(SNP, CHR, BP, MAF, A1, A2, BETA, SE, Z, P, chisq, chisq_df, chisq_pval, AIC)
  
  return(processed_data)
}


AD_aging_GBS_v2_factor1_processed <- process_GBSdata(AD_aging_GBS_v2_factor1)
AD_aging_GBS_v2_factor2_processed <- process_GBSdata(AD_aging_GBS_v2_factor2)


################################################
###__Neff & N_hat calculation ###
################################################

calculate_Neff_unit_loading <- function(df) {
  lambda <- 1

  # Specify MAF threshold
  lower_limit <- 0.1
  upper_limit <- 0.4
  df2 <- subset(df, MAF >= lower_limit & MAF <= upper_limit)
  
  # Calculate nj and Neff
  df3 <- df2 %>% 
    mutate(nj = ((Z / (BETA * lambda))^2) / (2 * MAF * (1 - MAF)))
  
  Neff_value <- sum(df3$nj) / nrow(df3)
  
  # Add 'N' column
  df <- df %>% mutate(N = Neff_value)
  return(df)
}

AD_aging_GBS_v2_factor1_processed <- calculate_Neff_unit_loading(AD_aging_GBS_v2_factor1_processed)
AD_aging_GBS_v2_factor2_processed <- calculate_Neff_unit_loading(AD_aging_GBS_v2_factor2_processed)


#######################
###__Freq alignment ###
#######################
freq_alignment <- function(data) {
  data %>%
    left_join(ref, by = "SNP") %>%
    mutate(MAF_final = ifelse(((A1_ref == A1) & (A2_ref == A2)), MAF_ref,
                              ifelse(((A1_ref == A2) & (A2_ref == A1)), 1 - MAF_ref, NA))) %>%
    mutate(MAF = MAF_final) %>%
    select(-MAF_final, -A1_ref, -A2_ref, -MAF_ref)
}

ref <- fread("/data1/sanghyeon/wonlab_contribute/combined/software/GenomicSEM/data/reference.1000G.maf.0.005.allele_aligned.txt", data.table = FALSE) %>%
  select(SNP, MAF_ref = MAF, A1_ref = A1, A2_ref = A2)

d1 <- freq_alignment(AD_aging_GBS_v2_factor1_processed)
d2 <- freq_alignment(AD_aging_GBS_v2_factor2_processed)

fwrite(d1, "./AD_aging_GBS_v2_factor1_reformatted.tsv", sep = "\t")
fwrite(d2, "./AD_aging_GBS_v2_factor2_reformatted.tsv", sep = "\t")

