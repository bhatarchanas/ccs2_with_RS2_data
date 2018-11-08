require 'trollop'
require 'bio'
require 'fileutils'

# USAGE: ruby ../run_ccs2_by_strand.rb -s sample_***.txt -p /opt/pacbio/smrtlink/smrtcmds/bin/ -n 5 -a 0.9 -o /scratch/archana/******

##### Input 
opts = Trollop::options do
	opt :samplefile, "File with all the sample information", :type => :string, :short => "-s"
	opt :smrttools, "Path for smrttools location", :type => :string, :short => "-p"
	opt :ccspases, "Threshold for the number of CCS passes", :type => :string, :short => "-n"
	opt :predaccu, "Threshold for the predicted accuracy", :type => :string, :short => "-a"
	opt :outdir, "Path to the directory where resultant data files should be dumped", :type => :string, :short => "-o"
	opt :rerunccs, "If ccs.bam files already exist, do you want to re-run ccs or use the already available files?", :type => :string, :short => "-r", :default => "yes"
end 

##### Assigning variables to the input and making sure we got all the inputs
opts[:samplefile].nil? ==false  ? sample_file     = File.open(opts[:samplefile]) : abort("Must supply a 'sample file' which is a tab delimited file of sample information with '-s'")
opts[:smrttools].nil?  ==false  ? smrt_tools_path = opts[:smrttools]             : abort("Must supply a path where smrttools resides with '-p'")
opts[:ccspases].nil?   ==false  ? ccs_passes      = opts[:ccspases]              : abort("Must supply a threshold for the number of CCS passes with '-n'")
opts[:predaccu].nil?   ==false  ? pred_accu       = opts[:predaccu]              : abort("Must supply a threshold for predicted accuracy with '-a'")
opts[:outdir].nil?     ==false  ? out_dir         = opts[:outdir]                : abort("Provide the path to the output directory to dump resultant files with '-o'")
opts[:rerunccs].nil?   ==false  ? re_run_ccs      = opts[:rerunccs]              : abort("Must say yes or no for re-running ccs with '-r'")


# Create the directory to dump output files
unless File.directory?(out_dir)
  FileUtils.mkdir_p(out_dir)
end

# Creating dicts to run ccs
ccs_hash = {}
sample_file.each_with_index do |line, index|
	if index == 0
		next
	else
		#puts line
		line_split = line.split("\t")
		job_id = line_split[0]
		path = line_split[1]
		barcode_1 = line_split[2]
		barcode_2 = line_split[3]
		sample = line_split[4].chomp

		ccs_hash[sample] = [barcode_1, barcode_2, job_id, path]
	end
end

# Running ccs and bam2fastq
ccs_hash.each do |key2, value2|

	correct_bc1_index = value2[0].to_i - 1
	correct_bc2_index = value2[1].to_i - 1

	puts correct_bc1_index, correct_bc2_index
	puts "#{out_dir}/#{value2[2]}.barcoded.#{correct_bc1_index}--#{correct_bc2_index}.bam"
	
	if File.file?("#{value2[3]}/#{value2[2]}.barcoded.#{correct_bc1_index}--#{correct_bc2_index}.bam")
		file_to_process = "#{value2[3]}/#{value2[2]}.barcoded.#{correct_bc1_index}--#{correct_bc2_index}.bam"
		
		if File.exists?("#{out_dir}/#{key2}.ccs.bam")
			if re_run_ccs == "yes"
				`rm -rf #{out_dir}/#{key2}.ccs.bam`

				puts "#{smrt_tools_path}ccs #{file_to_process} #{out_dir}/#{key2}.ccs.bam --byStrand --numThreads 32 --minPasses #{ccs_passes} --minPredictedAccuracy #{pred_accu}"
				`#{smrt_tools_path}ccs #{file_to_process} #{out_dir}/#{key2}.ccs.bam --byStrand --numThreads 32 --minPasses #{ccs_passes} --minPredictedAccuracy #{pred_accu}`

				puts "#{smrt_tools_path}bam2fastq -u -o #{out_dir}/#{key2} #{out_dir}/#{key2}.ccs.bam"
				`#{smrt_tools_path}bam2fastq -u -o #{out_dir}/#{key2} #{out_dir}/#{key2}.ccs.bam`
			end
		else
			puts "#{smrt_tools_path}ccs #{file_to_process} #{out_dir}/#{key2}.ccs.bam --byStrand --numThreads 32 --minPasses #{ccs_passes} --minPredictedAccuracy #{pred_accu}"
			`#{smrt_tools_path}ccs #{file_to_process} #{out_dir}/#{key2}.ccs.bam --byStrand --numThreads 32 --minPasses #{ccs_passes} --minPredictedAccuracy #{pred_accu}`

			puts "#{smrt_tools_path}bam2fastq -u -o #{out_dir}/#{key2} #{out_dir}/#{key2}.ccs.bam"
			`#{smrt_tools_path}bam2fastq -u -o #{out_dir}/#{key2} #{out_dir}/#{key2}.ccs.bam`
		end

		`samtools view #{out_dir}/#{key2}.ccs.bam | cut -f1,15 > #{out_dir}/#{key2}.ccs.bam.np`

		if File.zero?("#{out_dir}/#{key2}.ccs.bam.np")
			puts "NP file empty!!"
			next
		else
			np_file = File.open("#{out_dir}/#{key2}.ccs.bam.np")
			np_hash = {}
			np_file.each do |line|
				line_split = line.split("\t")
				record = line_split[0]
				np = line_split[1].chomp.split(":")[2]
				#puts record, np
				np_hash[record] = np
			end
		end	

		if File.zero?("#{out_dir}/#{key2}.fastq")
			puts "FASTQ file #{key2}.fastq is empty!!"
			next
		else
			fq_file = Bio::FlatFile.auto("#{out_dir}/#{key2}.fastq")
			fq_out_file = File.open("#{out_dir}/#{key2}_mod_headers.fastq", "w")
			fq_file.each do |entry|
				fq_out_file.puts("@#{entry.definition};barcodelabel=#{key2};ccs=#{np_hash[entry.definition]};")
				fq_out_file.puts(entry.naseq.upcase)
				fq_out_file.puts("+")
				fq_out_file.puts(entry.quality_string)
			end
		end
	end
end
