# 🧬 GWAS-by-Subtraction Pipeline

This repository contains the full pipeline for conducting GWAS-by-Subtraction (GBS) using summary statistics and Genomic SEM.



# 🔧 Tools
Genomic SEM (https://github.com/GenomicSEM/GenomicSEM)
LDSC (https://github.com/bulik/ldsc)



## 🔧 Step-by-Step Guide

############################
##### 00_QC.py #####
############################

Performed quality control to retain only the necessary data lines.

#AD GWAS summary statistics from:
Bellenguez, C., Küçükali, F., Jansen, I.E. et al. New insights into the genetic etiology of Alzheimer’s disease and related dementias. Nat Genet 54, 412–436 (2022).
https://doi.org/10.1038/s41588-022-01024-z

#Aging GWAS summary statistics from:
Rosoff, D.B., Mavromatis, L.A., Bell, A.S. et al. Multivariate genome-wide analysis of aging-related traits identifies novel loci and new drug targets for healthy aging. Nat Aging 3, 1020–1035 (2023).
https://doi.org/10.1038/s43587-023-00455-5



############################
## 00.1_addN.sh ##
############################

Appended reported effective sample size (N=1,958,774) to Aging GWAS summary statistics.



############################
### 01_munge.R ###
############################

Step 1: munge

Converted summary statistics to LDSC-compatible format (z-statistic scale) using the munge function.

Reference panel: Used HapMap3 SNPs
Available: https://utexas.box.com/s/vkd36n197m8klbaio3yzoxsee6sxo11v.



############################
### 02_LDSC.R ###
############################

Step 2: multivariable LDSC

Ran the multivariable LDSC.
Used the ldsc function to estimate the genetic covariance matrix (S) and the corresponding sampling covariance matrix (V) for multivariable LD Score regression.

Used the LD scores and weights (ld and wld) provided by the original LDSC package.
Available: https://utexas.box.com/s/vkd36n197m8klbaio3yzoxsee6sxo11v.



############################
# 03_modelwosnp_variance.R #
############################

Step 3: SEM model w/o SNPs

Ran the SEM model w/o SNPs.
Fit the initial Genomic SEM model using the genetic covariance matrix derived from GWAS summary statistics using unit variance identification (latent factor variance = 1).
This corresponds to the model shown in Figure 2a, excluding SNP effects.



############################
# 04_sumstats.R #
############################

Step 4: clean the GWAS

Prepared SNPs for GWAS.
Preprocessed summary statistics to enable genome-wide model fitting for each SNP.

Used the 1000 Genomes reference file
Available: https://utexas.box.com/s/vkd36n197m8klbaio3yzoxsee6sxo11v.



############################
### 05_GBS_variance.R ###
############################

Step 5: GBS

Ran the GBS using the GenomicSEM framework.
Performed using unit variance identification (latent factor variance = 1) for clearer interpretation in visualizations.



############################
#### run1.sh ####
############################

From QC to GBS.
Sequentially ran all steps from QC of summary statistics to GBS (unit variance identification).



############################
# 06_modelwosnp_loading.R #
############################

Step 6: SEM model w/o SNPs

Ran the SEM model w/o SNPs.
Fit the initial Genomic SEM model using the genetic covariance matrix derived from GWAS summary statistics using unit loading identification (latent factor loading = 1).



############################
### 07_GBS_loading.R ###
############################

Step 7: GBS

Ran the GBS using the GenomicSEM framework.
Performed using unit loading identification (latent factor loading = 1) for post-GWAS analyses.



############################
#### run2.sh ####
############################

Sequentially ran two steps from SEM model without SNPs to GBS (unit loading identification).



############################
### 08_Ncalculation.R ###
############################

Step 8: Neff calculation

Computed the effective sample size and updated the summary statistics accordingly.



############################
### 09_manhattan.R ###
############################

Step 9: Visualize GWAS results

Created Manhattan and QQ plots.

