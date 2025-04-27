#!/bin/bash
#SBATCH -J addN
#SBATCH -p cpu
#SBATCH -o ./%x_%j.out
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=20-00:00:00
#SBATCH --mail-user=heajene@gmail.com
#SBATCH --mail-type=END,FAIL

ml purge
ml load wonlab

awk 'BEGIN{OFS="\t"} NR==1{$(NF+1)="N"} NR>1{$(NF+1)=1958774}1' /data1/hyejin/Practice/GBS/data/Aging.txt > /data1/hyejin/Practice/GBS/data/Aging.N.txt
