#!/bin/bash
#SBATCH --job-name=AverageOverBed
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10GB
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_AverageOverBed.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_AverageOverBed.out
# Check for correct usage

bw_file=$1
bed_file=$2
output_file=$3
path_to_script=/scratch/project/triage_ml/ChrisC/scripts/bigWigAverageOverBed

$path_to_script $bw_file $bed_file $output_file
echo "Successful"
