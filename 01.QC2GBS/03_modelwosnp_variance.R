## (Updated) 2025.02.14

library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v1")


## (+) Running SEM model without SNPs
load(file="02_LDSCoutput_AD_Aging.RData")

model_wo_snp <- 'S=~NA*Aging + AD
NS=~NA*AD

NS~~1*NS
S~~1*S
S~~0*NS

Aging~~0*AD
Aging~~0*Aging
AD~~0*AD'

model_wo_snp_output <- usermodel(LDSCoutput,
                                 estimation="DWLS",
                                 model = model_wo_snp)
model_wo_snp_output

save(model_wo_snp_output, file="03_Model_wo_snp_output.RData")

