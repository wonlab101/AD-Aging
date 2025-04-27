#!/bin/bash
#SBATCH -J munging
#SBATCH -p cpu
#SBATCH -o ./%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=heajene@gmail.com
#SBATCH --mail-type=END,FAIL

module purge

CONDA_PATH=/data1/software/anaconda3
ENV_NAME=ldsc
ENV_PATH=$CONDA_PATH/envs/$ENV_NAME
source $CONDA_PATH/bin/activate $ENV_PATH

workf=/data1/hyejin/Practice/GBS
ldsc=/data1/hyejin/Tool/LDSC
snplist="/data1/hyejin/CreativityGWAS/LDSC/1.data/w_hm3.snplist"

# Only use version v2
version="v2"
factors=("factor1" "factor2")

for factor in "${factors[@]}"; do
  sumstat="AD_aging_GBS_${version}_${factor}"

  echo "###============ start !"
  echo "Processing tag: ${sumstat}"

  inf="${workf}/${version}/ldsc/${sumstat}_ldscinput"
  outf="${workf}/${version}/ldsc/${sumstat}_ldscoutput"

  python2 ${ldsc}/ldsc/munge_sumstats.py \
      --sumstats ${inf} \
      --out ${outf} \
      --merge-alleles ${snplist} \
      --chunksize 500000

  echo "###============ Done !"
done
