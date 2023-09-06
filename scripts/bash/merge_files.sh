#!/bin/bash
#SBATCH --job-name=merge_files1
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2GB
#SBATCH --time=50:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_merge_files.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_merge_files.out

# Check for correct usage
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <num_files> <files_per_batch> <num_batches> <run>"
    exit 1
fi

# Calculate the number of .bedgraph files
num_files=$1
files_per_batch=$2
num_batches=$3
run=$4
path_to_script="/scratch/project/triage_ml/ChrisC/scripts/bash/calc_sum_unique.sh"
min_files_to_continue=2

for ((batch_number = 1; batch_number <= num_batches && num_files >= min_files_to_continue; batch_number++)); do
    # Create a directory for the batch
    batch_dir="batch_${batch_number}"
    mkdir -p "$batch_dir"

    # Move bedgraph files to the batch directory
    files_to_move=$((files_per_batch < num_files ? files_per_batch : num_files))
    for ((i = 1; i <= files_to_move; i++)); do
        file_to_move=$(ls *.bedgraph | head -n 1)
        mv "$file_to_move" "$batch_dir"
    done

    # Change directory to the batch directory
    cd "$batch_dir"

    # Submit the calc_sum.sh script as a job and get the job ID
    job_id=$(sbatch $path_to_script $batch_number $run | awk '{print $4}')
    job_id_list+=("$job_id")
    cd ..

    # Update the remaining number of files
    num_files=$((num_files - files_to_move))
done

# Wait until all matrices in each batch directory are completed.
for id in "${job_id_list[@]}"; do
    while [[ $(squeue -h -j $id -t PD,R) ]]; do
        sleep 20
    done
    echo "Job $id completed out of ${#job_id_list[@]}."
done
