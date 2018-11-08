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
  * `SAMPLE_INFO_FILE (-s)` – This is the file which will have a list of all the PacBio jobs which are to be demutiplexed and run thorugh CCS2. The header of this file (first row) should have column names corresponding to job_id, path, bc_1, bc_2, and sample. These column names HAVE TO BE exactly as is described here because the program initializes data in each column based on these column names. Data in each column is described as follows:  
      1. job_id – The name of each pool, i.e., all the samples pooled togteher into one set will have the same pool_id.    
      2. path_for_lima – Path to where the subreadset.xml file is located for this particular pool. This is the path that is listed as "Data path" on SMRT link. 
      3. barcode – Name of the barcode used for this sample, can only use symmetirc barcodes at this point. 
      4. sample – This is the name given to each sample. This is the one that is going to be added in the FASTQ sequence header with a tag of “barcodelabel”. So, if you want any information to be kept track of, add it as a sample name. Multiple things can be kept track of in the sample name, separated by a “_”. For example, if I want to keep track of patient ID and sample ID in this location, give it the sample name “Pat123_Samp167” where Pat123 corresponds to the patient ID and Samp167 corresponds to the sample ID. This way all this information will be associated with each sequence and can later be tracked easily.   
  * `BARCODE_FILE (-b)` - A FASTA file with all the barcode sequences.
  * `OUTDIR (-o) ` - Path to where you want your intermediate (LIMA and CCS2) result files to be stored.


samplefile, "File with all the sample information", :type => :string, :short => "-s"
bcfile, "File with the barcodes information, in FASTA format", :type => :string, :short => "-b"
smrttools, "Path for smrttools location", :type => :string, :short => "-p"
ccspases, "Threshold for the number of CCS passes", :type => :string, :short => "-n"
predaccu, "Threshold for the predicted accuracy", :type => :string, :short => "-a"
outdir, "Path to the directory where resultant data files should be dumped", :type => :string, :short => "-o"
rerunccs, "If ccs.bam files already exist, do you want to re-run ccs or use the already available files?", :type => :string, :short => "-r", :default => "yes"