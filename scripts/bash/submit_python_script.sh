#!/bin/bash
#SBATCH --job-name=submit_python_script
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500GB
#SBATCH --time=10:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_submit_python_script.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_submit_python_script.out


path_to_script="$1"
input_file="$2"

source /home/s4669612/miniconda3/bin/activate py3.11

python $path_to_script $input_file


