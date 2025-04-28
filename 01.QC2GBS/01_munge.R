library(GenomicSEM)
library(data.table)
library(dplyr)
setwd("/data1/hyejin/Practice/GBS/v1")

## (1) Munging files

munge("/data1/hyejin/Practice/GBS/data/Aging.N.txt",   
      "/data1/hyejin/Tool/LDSC/w_hm3.snplist",
      trait.names="Aging",
      info.filter=0.9,
      maf.filter=0.01
)

munge("/data1/hyejin/Practice/GBS/data/AD.N.tsv",
      "/data1/hyejin/Tool/LDSC/w_hm3.snplist",
      trait.names="AD",
      info.filter=0.9,
      maf.filter=0.01
)

