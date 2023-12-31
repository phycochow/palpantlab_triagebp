# Palpant's lab TRIAGEbp Project for Drug Discovery
These scripts quantify epigenetic information in context of disease and development. TRIAGEbp uses an improved Repressive Tendency Score (RTS) at a nucleotide level resolution compared to the gene level resolution by its precursor TRIAGE, and emphasises on its unique strengths in pinpointing cell identity genes compared to highly adopted CADD deleterious scores and PhyloP conservation scores. This repository contains the scripts to generate the RTS file with 1 single command line.

This is an unpublished study under review, with a final submission date in October 2023, and hopefully Nature Genetics or Nuclear Acids Research :)

This project is being conducted in collaboration with esteemed researchers at the Institute of Molecular Bioscience, University of Queensland, including Chris - Dr Woo Jun Shim, Dr Enakshi Sinniah (who was an esteemed attendee at the 2023 Nobel Prize Summit!), and the grant-writing, busy cardiologist A/Prof Nathan Palpant.

## Installation
```bash
git install https://github.com/phycochow/palpantlab_triagebp.git
```

## Usage
Prepare a new directory with the input bedgraph files for the generation of RTS. According to the original TRIAGE paper, ~100 diverse ChIP-seq datasets are required.
```
sbatch generate_TRIAGEbp_RTS.sh
```

## Contributing
