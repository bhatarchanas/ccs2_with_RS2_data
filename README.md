[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) [](#lang-us) ![ruby in bioinformatics ftw](https://img.shields.io/badge/Language-ruby-steelblue.svg)


# CCS2 for RSII data
## Using PacBio microbiome data from RSII to carry out demultiplexing (LIMA) and to run CCS2  

### Introduction:
SMRT tools is a set of command-line tools which come included with SMRT link. These programs together will help in running lima (for demultiplexing) and CCS2 on microbiome data from PacBio's RSII.  

### Installation:
SMRT tools comes installed with the SMRT analysis software suite. No additional installation is required to run this script. 

### Data Prerequisites:
1. Sequencing data from microbiome samples which were pooled and sequenced on the Sequel.
2. Barcodes file with all the barcodes that were used for pooling. File should be in FASTA format. This script only works for symmetric barcodes. 
3. Sample file with information regarding each sample. 

### Convert bax.h5 files to bam - run_bax2bam.rb:
#### Arguments:
  * `SAMPLE_INFO_FILE (-s)` – This is the file which will have a list of all the PacBio jobs whose bax.h5 files are to be converted into bam files. The header has to be "PB_jobid" and "path" and the 2 columns in this file will list a job id which is a unique ID for each pool, and, the path to where the results from the ROI protocol were dumped. The path usually has "Analysis_Results" folder which has the bax.h5 files. The pool ID that you use will be used as the prefix for the name of the bam files that are generated. 
  * `OUTDIR (-o) ` - Path to where you want your result files to be stored.
  
#### Usage:
Run the run_bax2bam.rb script along with the arguments that are required as input.  
`ruby run_bax2bam.rb -s sample_key.txt -o out_dir_name`

### Run LIMA and CCS2 - run_ccs2_and_barcoding_with_rs2data.rb:
#### Arguments:
  * `SAMPLE_INFO_FILE (-s)` – This is the file which will have a list of all the PacBio jobs which are to be demutiplexed and run thorugh CCS2. The header of this file (first row) should have column names corresponding to job_id, path, bc_1, bc_2, and sample. These column names HAVE TO BE exactly as is described here because the program initializes data in each column based on these column names. Data in each column is described as follows:  
      1. job_id – The name of each pool, i.e., all the samples pooled togteher into one set will have the same pool_id.    
      2. path – Path to where the subreadset.xml file is located for this particular pool. This is the path that is listed as "Data path" on SMRT link. 
      3. bc_1 and bc_2 – Name of the barcode used for this sample, can only use symmetirc barcodes at this point. 
      4. sample – This is the name given to each sample. This is the one that is going to be added in the FASTQ sequence header with a tag of “barcodelabel”. So, if you want any information to be kept track of, add it as a sample name. Multiple things can be kept track of in the sample name, separated by a “_”. For example, if I want to keep track of patient ID and sample ID in this location, give it the sample name “Pat123_Samp167” where Pat123 corresponds to the patient ID and Samp167 corresponds to the sample ID. This way all this information will be associated with each sequence and can later be tracked easily.   
  * `BCFILE (-b)` - A FASTA file with all the barcode sequences.
  * `SMRTTOOLS (-p)` - This is the path where smrttools is located. Use full path, avoid relative paths.
  * `CCSPASSES (-n)` - Specify the numer of CCS passes cut-off.
  * `PREDACCU (-a)` - Specify the predicted accuracy cut-off.
  * `OUTDIR (-o) ` - Path to where you want your result files to be stored.
  * `RERUNCCS (-r)` - If CCS and completed running on these samples, when you re-run the script, do you want to re-run CCS2 as well? Answer in "yes" or "no". Default is yes. 

#### Usage:
Run the run_ccs2_and_barcoding_with_rs2data.rb script along with the arguments that are required as input.  
`ruby run_ccs2_and_barcoding_with_rs2data.rb -s sample_key_ccs2_and_lima.txt -b barcode_file.fasta -p xx/bin/smrttools -n 4 -a 0.9 -o out_dir_name`