#!/bin/bash
#SBATCH -J GC
#SBATCH -p cpu
#SBATCH -o ./%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=5
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=heajene@gmail.com
#SBATCH --mail-type=END,FAIL

module purge

CONDA_PATH=/data1/software/anaconda3
ENV_NAME=ldsc
ENV_PATH=$CONDA_PATH/envs/$ENV_NAME
source $CONDA_PATH/bin/activate $ENV_PATH

ldsc="/data1/hyejin/Tool/LDSC"
inputdir1="/data1/hyejin/Practice/GBS/v2/ldsc"
inputdirs2=(
    "/data1/yeeun/Project/Creativity_GWAS/LDSC/Data/SYK"
    "/data1/yeeun/Project/Creativity_GWAS/LDSC/Data"
)
outdir=${inputdir1}/output

export OMP_NUM_THREADS="1"

for tmpSample1 in ${inputdir1}/*.sumstats.gz
do
    echo "##############################"
    echo "current file : ${tmpSample1}"
    outfilename1=${tmpSample1##*/}
    trait1=${outfilename1%%.sumstats.gz*}

    for inputdir2 in "${inputdirs2[@]}"
    do
        for tmpSample2 in ${inputdir2}/*.sumstats.gz
        do
            outfilename2=${tmpSample2##*/}
            trait2=${outfilename2%%.sumstats.gz*}

            echo "current health-related trait : ${tmpSample2}"
            echo "correlation between ${trait1} and ${trait2}"

            python2 ${ldsc}/ldsc/ldsc.py \
                --rg ${tmpSample1},${tmpSample2} \
                --ref-ld-chr ${ldsc}/eur_w_ld_chr/ \
                --w-ld-chr ${ldsc}/eur_w_ld_chr/ \
                --out ${outdir}/${trait1}_${trait2} \
                --print-coefficients
        done
    done

    echo "##############################"
    echo "date"
    echo -e "\n\n\n\n"
done
