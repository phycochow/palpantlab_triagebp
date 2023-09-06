#!/bin/bash
#SBATCH --job-name=bedgraph_to_bw
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=500GB
#SBATCH --time=6:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/bedgraph_to_bw_results_%j.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/bedgraph_to_bw_results_%j.out

# Check for correct usage
if [ $# -ne 3 ]; then
    echo "Usage: $0 <bedgraph_file> <genome file> <output_bw>"
    exit 1
fi

bedgraph_file="$1"
genome_file="$2"
output_bw="$3"
path_to_script="/scratch/project/triage_ml/ChrisC/scripts/bedGraphToBigWig"

# Check if the provided files exist
if [ ! -f "$bedgraph_file" ]; then
    echo "----------------------------------------------------------"
    echo "Error: Input BW file '$bedgraph_file' not found."
    echo "----------------------------------------------------------"
    exit 1
fi

# Run the script
if [ -f "$path_to_script" ]; then
    "$path_to_script" "$bedgraph_file" "$genome_file" "$output_bw"
    echo "Conversion completed successfully."
else
    echo "----------------------------------------------------------"
    echo "Error: Script '$path_to_script' not found."
    echo "----------------------------------------------------------"
    exit 1
fi

