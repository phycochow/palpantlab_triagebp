#!/bin/bash
#SBATCH --job-name=bw_to_bedgraph
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10GB
#SBATCH --time=00:30:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/bw_to_bedgraph_results_%j.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/bw_to_bedgraph_results_%j.out

# Check for correct usage
if [ $# -ne 2 ]; then
    echo "Usage: $0 <bw_file> <output_bedgraph>"
    exit 1
fi

bw_file="$1"
output_bedgraph="$2"
path_to_script="/scratch/project/triage_ml/ChrisC/scripts/bigWigToBedGraph"

# Check if the provided files exist
if [ ! -f "$bw_file" ]; then
    echo "----------------------------------------------------------"
    echo "Error: Input BW file '$bw_file' not found."
    echo "----------------------------------------------------------"
    exit 1
fi

# Run the script
if [ -f "$path_to_script" ]; then
    "$path_to_script" "$bw_file" "$output_bedgraph"
    echo "Conversion completed successfully."
else
    echo "----------------------------------------------------------"
    echo "Error: Script '$path_to_script' not found."
    echo "----------------------------------------------------------"
    exit 1
fi

