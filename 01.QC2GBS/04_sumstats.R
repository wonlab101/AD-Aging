## 2024.11.12

library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v1")

## (3) Clean the SNPs for GWAS
files = c("/data1/hyejin/Practice/GBS/data/Aging.N.txt", "/data1/hyejin/Practice/GBS/data/GCST90027158_buildGRCh38.N.tsv")
ref <- "/data1/hyejin/Tool/Reference/reference.1000G.maf.0.005.txt"
trait.names <- c("Aging", "AD") 

info.filter = 0.9
maf.filter = 0.01

# for other GWAS files, parameters of the sumstats function may need changing
p_sumstats<-sumstats(files=files, ref=ref,
                     trait.names = c("Aging", "AD"),
                     betas=NULL,
                     se.logit=c(F,F),
                     OLS=c(T, T),
                     linprob=c(F, F),
                     N=NULL,
                     info.filter=info.filter,
                     maf.filter=maf.filter)

save(p_sumstats, file="04_p_sumstats.RData")

