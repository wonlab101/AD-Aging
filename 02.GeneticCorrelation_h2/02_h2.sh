#!/bin/bash
#SBATCH -J h2
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
ld=/data1/hyejin/GLGCgSEM/LDSC/eur_w_ld_chr/

# Set version and define factors
version="v2"
factors=("factor1" "factor2")

# Loop over factors only
for factor in "${factors[@]}"; do
  sumstat="AD_aging_GBS_${version}_${factor}"

  echo "###============ start !"
  echo "Processing tag: ${sumstat}"

  inf="${workf}/${version}/ldsc/${sumstat}_ldscoutput.sumstats.gz"
  outf="${workf}/${version}/ldsc/${sumstat}_h2"

  python2 ${ldsc}/ldsc/ldsc.py \
      --h2 ${inf} \
      --ref-ld-chr ${ld} \
      --w-ld-chr ${ld} \
      --out ${outf}

  echo "###============ Done !"
done
