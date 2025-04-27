#!/bin/bash
#SBATCH -J QCtoGBS
#SBATCH -p cpu
#SBATCH -o ./%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=heajene@gmail.com
#SBATCH --mail-type=END,FAIL

ml purge
ml load wonlab

export OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1 MKL_NUM_THREADS=1 NUMEXPR_NUM_THREADS=1 VECLIB_MAXIMUM_THREADS=1


CONDA_PATH=/data1/software/anaconda3
ENV_NAME=gSEM
ENV_PATH=$CONDA_PATH/envs/$ENV_NAME
source $CONDA_PATH/bin/activate $ENV_PATH

python /data1/hyejin/Practice/GBS/v1/00_QC.py
bash /data1/hyejin/Practice/GBS/v1/00.1_addN.sh 
Rscript /data1/hyejin/Practice/GBS/v1/01_munge.R
Rscript /data1/hyejin/Practice/GBS/v1/02_LDSC.R
Rscript /data1/hyejin/Practice/GBS/v1/03_modelwosnp_variance.R
Rscript /data1/hyejin/Practice/GBS/v1/04_sumstats.R
Rscript /data1/hyejin/Practice/GBS/v1/05_GBS_variance.R

