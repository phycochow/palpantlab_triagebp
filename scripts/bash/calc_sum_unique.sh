#!/bin/bash
#SBATCH --job-name=calc_unique_sum
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500GB
#SBATCH --time=30:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_calc_unique_sum.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_calc_unique_sum.out
# Check for correct usage

iter=$1
run=$2

unionbedg_command="bedtools unionbedg -i"
for file in *.bedgraph; do unionbedg_command+=" $file"; done
unionbedg_command+=" | awk 'BEGIN { OFS=\"\\t\" } { sum = 0; for (i = 4; i <= NF; i++) sum += \$i; print \$1, \$2, \$3, sum }' > matrix_merged_${run}_${iter}.bedgraph"
source /home/s4669612/miniconda3/bin/activate py3.11
eval "$unionbedg_command"

mv matrix_merged_${run}_${iter}.bedgraph ..
