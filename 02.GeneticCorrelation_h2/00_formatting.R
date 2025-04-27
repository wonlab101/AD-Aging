# Define processing function
process_LDSCdata <- function(data) { 
  data %>% dplyr::select(SNP, A1, A2, Z, P, N)
}

# Define input list
data_list <- list(
  v1_factor1 = d1,
  v1_factor2 = d2,
  v2_factor1 = d3,
  v2_factor2 = d4
)

# Define output path prefix
output_paths <- list(
  v1_factor1 = "../v1/ldsc/AD_aging_GBS_v1_factor1_ldscinput",
  v1_factor2 = "../v1/ldsc/AD_aging_GBS_v1_factor2_ldscinput",
  v2_factor1 = "../v2/ldsc/AD_aging_GBS_v2_factor1_ldscinput",
  v2_factor2 = "../v2/ldsc/AD_aging_GBS_v2_factor2_ldscinput"
)

# Loop over and process/write files
for (tag in names(data_list)) {
  processed <- process_LDSCdata(data_list[[tag]])
  fwrite(processed, output_paths[[tag]], sep = "\t")
}
