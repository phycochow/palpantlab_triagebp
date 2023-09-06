"""The purpose of this script is to calculate the breath of each read entry and to normalise the values for the inital
steps of the generation of RTS values by bp to avoid bias. This is a test script to see how this compares against the
existing method.
"""

import sys
import pandas as pd
import os


def normalise_breadth(input_file):
    # Load the input bedgraph file into a DataFrame
    with open(input_file, 'r') as in_f:
        line = in_f.readline().strip()
        num_columns = len(line.split('\t'))
        # Read bedgraph
        if num_columns == 4:
            column_names = ['chromosome', 'start', 'end', 'score']
            data = pd.read_csv(in_f, sep='\t', header=None, names=column_names)
        # Read bed
        elif num_columns == 3:
            column_names = ['chromosome', 'start', 'end']
            data = pd.read_csv(in_f, sep='\t', header=None, names=column_names)

        # Calculate the breadth for each entry
        data['temp_breadth'] = data['end'] - data['start']

        # Calculate min and max values
        min_value = data['temp_breadth'].min()
        max_value = data['temp_breadth'].max()

        # Apply min-max normalization & get bp score
        data['bp_score'] = ((data['temp_breadth'] - min_value) / (max_value - min_value)) / data['temp_breadth']

        # Create the output file path
        output_file = f"{input_file[:-9]}_normalised.bedgraph"

        # Save the modified data to a new bedgraph file
        with open(output_file, 'w') as out_f:
            data.to_csv(out_f, sep='\t', header=False, index=False,
                        columns=['chromosome', 'start', 'end', 'bp_score'], float_format='%.4e')

        print("Processing completed. Modified data saved to", output_file)


def sort_bedgraph(input_file):
    # Create the output file path
    sorted_temp_file = f"{input_file[:-9]}_sorted.bedgraph"

    with open(input_file, 'r') as f_in:
        lines = f_in.readlines()
    sorted_lines = sorted(lines, key=lambda line: (line.split()[0], int(line.split()[1]), int(line.split()[2])))

    with open(sorted_temp_file, 'w') as f_out:
        for line in sorted_lines:
            f_out.write(line)

    print("Sorting completed. Modified data saved to", sorted_temp_file)
    return sorted_temp_file


def main():
    if len(sys.argv) != 2:
        print("Usage: python script_name.py input.bedgraph")
        sys.exit(1)

    input_file_path = sys.argv[1]

    if not os.path.isfile(input_file_path):
        print(f"Error: Input file {input_file_path} does not exist.")
        sys.exit(1)

    sorted_file = sort_bedgraph(input_file_path)
    normalise_breadth(sorted_file)


if __name__ == "__main__":
    main()

