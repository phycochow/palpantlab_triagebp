''' An example Python script to calculate the Repressive Tendency Score (RTS) of user-defined genomic regions (or loci) of interest. Written in Python 3.

    The RTS is an average H3K27me3 deposition signal for a defined genomic region of interest extracted from over 100 diverse human tissue and cell types (Roadmap). 

    To run a test analysis on the example input file (example_input.bed) and export the output (example_output.txt), 
    > python3 -i example_input.bed -o example_output.txt

    Note. 

    1. If the user wants to use a different H3K27me3 data, this can be specified with -r option. Default file is 'H3K27me3.bedgraph' which is provided with this code. 

    2. The input bed file should be a tab-delimited BED4 (i.e. chr, start, end, unique ID). See the example_input.bed for an example. 

    Code dependencies
    - bedtools  

    by Woo Jun Shim

'''
import sys
import os
from optparse import OptionParser

def quantify_overlap(merged_bedfile, ref_file, output_file, col):
	''' Extract overlap features between a pair of BED files.

        merged_bedfile = a string variable for an input BED file that includes genomic regions of interest. This BED file should follow the BED4 format (i.e. chr, start, end, identifier/name). The identifier should be unique for each region.  

        ref_file = a string variable for a "reference" H3K27me3 bedgraph file that quantifies strength of H3K27me3 signal genome-wide. This was pre-computed and is provided as a separate file (H3K27me3.bedgraph).

        output_file = a string variable for an output TEXT file. The output file shows RTSs for all genomic regions of interest.

        col = a list of two integers (i.e. [i,j]). These integers indicate where the region identifier (i-th column) and the H3K27me3 signal value (j-th column) are located in Bedtools standard output.        

    '''
	line = 'bedtools intersect -a '+merged_bedfile+' -b '+ref_file+" -wb | awk '{print $"+str(col[0])+'"	"($3-$2)"	"$'+str(col[1])+"}' > "+str(output_file)
	os.system(line)

def calculate_rts(filename, ref_file, col=[0,1,2]):
    ''' Calculate RTSs for genomic regions 

    col[0] = a column index for the identifier of the genomic region
    col[1] = a column index for the breadth of the genomic region
    col[2] = a column index for the H3K27me3 signal 
    
    '''
    score, width = {}, {}
    temp = read_file_as_list(filename)
    qq = read_file_as_list(ref_file)
    for i in qq:
        width[i[3]] = int(i[2]) - int(i[1])
    for i in temp:
        value = float(i[col[1]]) * float(i[col[2]])
        if i[col[0]] not in score:
            score[i[col[0]]] = [0]
        score[i[col[0]]][0] += value
    for g in score:
        score[g][0] = score[g][0] / width[g]
    return score

def read_file_as_list(filename, col=None, numeric_col=None):
    results = []
    temp = open(filename, 'r')
    for i in temp:
        i = i.strip().split()
        if i[0].startswith('#'):
            continue
        else:
            results.append([])
            if col==None:
                for no in range(len(i)):
                    c = i[no]
                    if numeric_col!=None:
                        if no in numeric_col:                       
                            c = float(i[no])
                    results[-1].extend([c])
            else:
                for c in col:
                    if numeric_col!=None:
                        if c in numeric_col:
                            value = float(i[c])
                    else:
                        value = i[c]
                    results[-1].extend(value)
    return results

def write_file(data, filename):
    temp = open(filename, 'w')
    if type(data)==list:
        for i in data:
            if len(i) != 0:
                line = str(i[0])
                for j in i[1:]:
                    line += '\t'+str(j)
                line += '\n'
            temp.write(line)
        temp.close()
    if type(data)==dict:
        for key in data:
            if len(data[key]) != 0:
                line = str(key)
                for j in data[key]:
                    line += '\t'+str(j)
                line += '\n'
            temp.write(line)
        temp.close()

def run_rts(filename, ref_file, output_file):
	''' a main function to calculate the RTS for each genomic region included in the input file, given H3K27me3 signal as a pre-computed bedgraph file(ref_file). Output is a text file showing genomic regions ID/name and their corresponding RTS values.

	'''
	quantify_overlap(filename, ref_file, output_file='temp.txt', col=[4,8])
	results = calculate_rts('temp.txt', filename)
	write_file(results, output_file)
	os.system('rm temp.txt')

if __name__ == '__main__':

    # Command line options   
    parser = OptionParser()
    parser.add_option('-i', '--i', dest='input_file', help='input filename')    
    parser.add_option('-o','--o', dest='output_file', help='output filename')
    parser.add_option('-r', '--r', dest='ref_file', help='reference bedgraph filename', default='H3K27me3.bedgraph') 

    options = parser.parse_args()[0]

    run_rts(filename=options.input_file, ref_file=options.ref_file, output_file=options.output_file)

