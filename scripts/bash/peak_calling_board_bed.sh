#!/bin/bash
#SBATCH --job-name=peak_calling_board_bed
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50GB
#SBATCH --time=7:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_peak_calling_bed.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_peak_calling_bed.out

# Define the input file as the first argument
input_file=$1

# Run MACS2 bdgbroadcall
macs2 bdgbroadcall -i $input_file -o ${input_file%.bedgraph}.bed

# Remove input file
rm $input_file


