## 2024.12.19

library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v1")

## (2) Multivariable LD score regression 
traits <- c("Aging.sumstats.gz", "AD.sumstats.gz")
sample.prev <- c(NA, NA)
population.prev <- c(NA, NA) 

ld <- "/data1/hyejin/Tool/LDSC/eur_w_ld_chr/"
wld <- "/data1/hyejin/Tool/LDSC/eur_w_ld_chr/"

trait.names <- c("Aging", "AD")

LDSCoutput <- ldsc(traits,
                   sample.prev,
                   population.prev,
                   ld,
                   wld,
                   trait.names)

save(LDSCoutput, file="02_LDSCoutput_AD_Aging.RData")

