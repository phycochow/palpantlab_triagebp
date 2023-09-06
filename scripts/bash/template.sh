#!/bin/bash
#SBATCH --job-name=
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=80GB
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/_%j.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/_%j.out
# Check for correct usage

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

