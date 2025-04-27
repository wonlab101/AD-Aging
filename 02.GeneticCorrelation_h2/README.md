# 🧬 Genetic correlation Pipeline

This repository contains the full pipeline for conducting genetic correlation anlaysis using LDSC.



# 🔧 Tools
LDSC (https://github.com/bulik/ldsc)



## 🔧 Step-by-Step Guide

########################
### 00_formatting.R ###
########################

Prepared GWAS summary statistics for LDSC analysis.



########################
### 01_munge.sh ###
########################

Step 1: munge

Converted GWAS summary statistics to LDSC-compatible format (z-statistic scale) using munge_sumstats.py from the LDSC package.

Reference panel: Used HapMap3 SNPs
Available: https://utexas.box.com/s/vkd36n197m8klbaio3yzoxsee6sxo11v.



########################
### 02_h2.sh ###
########################

Step 2: SNP-based heritability calculation

Ran the multivariable LDSC.
Calculated SNP-based heritability using ldsc.py from the LDSC package.



########################
### 03_GC.sh ###
########################

Step 3: genetic correlation analysis 

Performed pairwise LDSC-based genetic correlation with external traits.



########################
### 04_GCplots.R ###
########################

Step 4: visualization
