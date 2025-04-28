library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v2")

## (4) Run GWAS-by-subtraction
load(file="../v1/02_LDSCoutput_AD_Aging.RData")
load(file="../v1/04_p_sumstats.RData")

model_w_snp<-'S=~1*Aging + AD
NS=~1*AD

S~SNP
NS~SNP

S~~0*NS

Aging ~~ 0*AD
Aging ~~0*Aging
AD~~0*AD
SNP~~SNP'

outputGWAS<-userGWAS(covstruc=LDSCoutput,SNPs=p_sumstats,estimation="DWLS",model=model_w_snp,sub =c("S~SNP","NS~SNP"), cores=25)
save(outputGWAS, file="05_outputGWAS.RData")

aging_ad <- outputGWAS[[1]]
write.table(aging_ad, "../data/AD_aging_GBS_v2_factor1", sep="\t", quote=T, row.names=F, col.names=T)
ad_aging <- outputGWAS[[2]]
write.table(ad_aging, "../data/AD_aging_GBS_v2_factor2", sep="\t", quote=T, row.names=F, col.names=T)
