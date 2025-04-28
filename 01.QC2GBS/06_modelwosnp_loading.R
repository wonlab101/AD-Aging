library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v2")


## (+) Running SEM model without SNPs
load(file="../v1/02_LDSCoutput_AD_Aging.RData")

model_wo_snp <- 'S=~1*Aging + AD
NS=~1*AD

S~~0*NS

Aging ~~ 0*AD
Aging ~~0*Aging
AD~~0*AD'

model_wo_snp_output <- usermodel(LDSCoutput,
                                 estimation="DWLS",
                                 model = model_wo_snp)

save(model_wo_snp_output, file="03_Model_wo_snp_output.RData")

