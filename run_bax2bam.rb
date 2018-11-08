require 'trollop'
require 'bio'
require 'fileutils'

##### Input 
opts = Trollop::options do
	opt :samplefile, "File with all the sample information", :type => :string, :short => "-s"
	opt :outdir, "Path to the directory where resultant data files should be dumped", :type => :string, :short => "-o"
end 

##### Assigning variables to the input and making sure we got all the inputs
opts[:samplefile].nil? ==false  ? sample_file     = File.open(opts[:samplefile]) : abort("Must supply a 'sample file' which is a tab delimited file of sample information with '-s'")
opts[:outdir].nil?     ==false  ? out_dir         = opts[:outdir]                : abort("Provide the path to the output directory to dump resultant files with '-o'")

# Create the directory to dump output files
unless File.directory?(out_dir)
  FileUtils.mkdir_p(out_dir)
end

sample_file.each_with_index do |line, index|
	if index == 0
		next
	else
		line_split = line.split("\t")
		job_id = line_split[0]
		path = line_split[1].chomp

		puts "/opt/pacbio/smrtlink/smrtcmds/bin/bax2bam -o #{job_id} #{path}*.bax.h5"
		`/opt/pacbio/smrtlink/smrtcmds/bin/bax2bam -o #{job_id} #{path}*.bax.h5`
	end
end