#!/bin/bash
#SBATCH --job-name=generateTRIAGEbpRTS
#SBATCH --account=a_palpant
#SBATCH --partition=general
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2GB
#SBATCH --time=120:00:00
#SBATCH --output=/scratch/project/triage_ml/ChrisC/logs/%j_generateTRIAGEbpRTS.out
#SBATCH --error=/scratch/project/triage_ml/ChrisC/logs/%j_generateTRIAGEbpRTS.out

#######################################################################################################################
                                            	     # Setup #
#######################################################################################################################
# Peak calling script
path_to_peak_call="/scratch/project/triage_ml/ChrisC/scripts/bash/peak_calling_board_bed.sh"

# Normalisation scripts
path_to_submit_py_small="/scratch/project/triage_ml/ChrisC/scripts/bash/submit_python_script_small.sh"
path_to_norm_script="/scratch/project/triage_ml/ChrisC/scripts/python/normalise_breadth.py"

#----------------------------------------------------------------------------------------------------------------------
# RTS scripts
path_to_submit_py="/scratch/project/triage_ml/ChrisC/scripts/bash/submit_python_script.sh"
path_to_merge1="/scratch/project/triage_ml/ChrisC/scripts/bash/merge_files.sh"
path_to_final_norm="/scratch/project/triage_ml/ChrisC/scripts/python/final_score_norm.py"

#######################################################################################################################
                                            # Peak calling 5.9.23 #
#######################################################################################################################
# Get a list of files in the current directory
f_list=("$PWD"/*)
j_id_list2+=("$job_id")

# Generate new bed files of board domains and remove the older file
for $input_file in *; do
    j_id=$(sbatch "$path_to_submit_py_small" "input_file" | awk '{print $4}')
    j_id_list2+=("$job_id")
done

# Wait until all peak calling jobs are completed.
for input_j_id in "${j_id_list2[@]}"; do
	while [[ $(squeue -h -j $input_j_id -t PD,R) ]]; do
		sleep 20
		echo $input_j_id not done
	done
	echo "Normalization job $id completed out of ${#j_id_list2[@]}."
done

#######################################################################################################################
                                              # Inital normalisation #
#######################################################################################################################

# Get a list of files in the current directory
file_list=("$PWD"/*)
echo ${#file_list[@]} 'input files'

# Loop through the list of files
for bg_f in "${file_list[@]}"; do
	echo normalising "$bg_f" ...
	job_id=$(sbatch "$path_to_submit_py_small" "$path_to_norm_script" "$bg_f" | awk '{print $4}')
	job_id_list+=("$job_id")
done

# Wait until all normalization jobs are completed.
for id in "${job_id_list[@]}"; do
	while [[ $(squeue -h -j $id -t PD,R) ]]; do
		sleep 20
		echo $id not done
	done
	echo "Normalization job $id completed out of ${#job_id_list[@]}."
done

# Remove the input files and temp files, and only keep _normalised.bedgraph
echo deleting files now
find . -maxdepth 1 -type f ! -name "*_normalised.bedgraph" -delete

#######################################################################################################################
                                               # RTS generation #
#######################################################################################################################

run=0
while true; do
	# Evaluate current resources and update inputs
	num_files=$(ls *.bedgraph | wc -l)
	files_per_batch=3
	num_batches=$(( (num_files + files_per_batch - 1) / files_per_batch ))
	run=$((run + 1))

	# Break loop if completed
	if [[ $num_files -le 1 ]]; then
		echo "Only 1 .bedgraph file left. Stopping loop."
		break
	fi

	echo "$num_files bedgraph files left"

	# Generate a matrix file for each batch
	job1=$(sbatch $path_to_merge1 $num_files $files_per_batch $num_batches $run | awk '{print $4}')
	
	echo submited $job1

	# Wait until job1 has created the directories and generate the merged unique files in all batches
	while [[ $(squeue -h -j $job1 -t PD,R) ]]; do
		sleep 30
	done
	
	echo "All files in this batch run $run has been merged and sent to this directory. Deleting batch* directories now."
	for f in batch*; do rm -r $f; done
done

#######################################################################################################################
                                               # Final processing of the output file #
#######################################################################################################################
# Count the number of .bedgraph files in the current directory

bedgraph_file=$(ls -1 *.bedgraph | head -n 1)
job2=$(sbatch $path_to_submit_py $path_to_final_norm "$bedgraph_file" | awk '{print $4}')

while [[ $(squeue -h -j $job2 -t PD,R) ]]; do
	sleep 30
done

echo "Normalization should completed. End of script."

