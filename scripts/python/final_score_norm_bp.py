"""The purpose of this script is to do the final calculations for the generation of RTS values, including the product
of bp score and bp for each unique domain, and min max normalisation of the final results.
"""

import sys
import pandas as pd
import os


def normalise_breadth(input_file):
    # Load the input bedgraph file into a DataFrame
    with open(input_file, 'r') as in_f:
        column_names = ['chromosome', 'start', 'end', 'summed_bp_score']
        data = pd.read_csv(in_f, sep='\t', header=None, names=column_names)

        data['summed_score'] = data['summed_bp_score'] * (data['end'] - data['start'])

        # Calculate min and max values
        min_value = data['summed_score'].min()
        max_value = data['summed_score'].max()

        # Obtain the normalise true score via min-mas
        data['normalised_true_score'] = (data['summed_score'] - min_value) / (max_value - min_value)

        # Create the output file path
        output_file = f"{input_file[:-9]}_normalised.bedgraph"

        # Save the modified data to a new bedgraph file
        with open(output_file, 'w') as out_f:
            data.to_csv(out_f, sep='\t', header=False, index=False,
                        columns=['chromosome', 'start', 'end', 'normalised_true_score'], float_format='%.4e')

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
        print("Error: Input file does not exist.")
        sys.exit(1)

    normalise_breadth(input_file_path)


if __name__ == "__main__":
    main()

