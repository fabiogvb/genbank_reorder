# genbank_reorder

**NAME:** GenBank Contig Reorder

**SYNOPSIS:**

**Usage:** ./genbank_reorder.sh -r reference_file.gbff -i input_file.gbff -o output_file.gbff -u yes -k yes

**Required parameters:**

	-r Reference file in GenBank format with unique or multiple contigs. It will be used as reference to order the input file.
	-i Input file in GenBank format with multiple contigs. The contigs will be reordered using mauve-aligner and the reference_file.
	-o Output file will be save with this name in this place.

**Optional parameters:**

	-u Union parameter (default: -u no). If (-u yes) is used, it will concatenate all contigs in an unique artificial contig in the additional output file. This artificial chromosome can be viewed with artemis software.
	-k Keep all files (default: -k no). If (-k yes) is used, all files are keeped including the aligments and log files.

**INSTALL INSTRUCTIONS**

Tested on:   
Ubuntu Version: 22.04.5 LTS jammy,
openjdk Version: 11.0.29,
mauve-aligner Version: 2.4.0+4736-4,
xvfb Version: 2:21.1.4-2ubuntu1.7~22.04.16,
libcommons-cli-java Version: 1.4-2,
readseq Version: 1-14,
emboss Version: 6.6.0+dfsg-11ubuntu1,
artemis Version: 18.1.0+dfsg-6,
git Version: 1:2.34.1-1ubuntu1.15,

**Install dependecies in your operation system:**

For Debian or similar use:

	sudo apt-get install git xvfb libcommons-cli-java readseq mauve-aligner emboss artemis
For CentOS or similar use:

	sudo yum install git xvfb libcommons-cli-java  readseq mauve-aligner emboss artemis
For MacOS use:

	brew install git xvfb libcommons-cli-java readseq mauve-aligner emboss artemis

**Install Genbank Contig Reorder:**

	git clone https://github.com/fabiogvb/genbank_reorder
	cd genbank_reorder
	chmod +x genbank_reorder.sh
	./genbank_reorder.sh

**EXAMPLE**

	wget -c 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/455/725/GCF_900455725.1_50477_H01/GCF_900455725.1_50477_H01_genomic.gbff.gz'
	wget -c 'ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/646/655/GCF_001646655.1_ASM164665v1/GCF_001646655.1_ASM164665v1_genomic.gbff.gz'
	gunzip GCF_900455725.1_50477_H01_genomic.gbff.gz GCF_001646655.1_ASM164665v1_genomic.gbff.gz
	./genbank_reorder.sh -r GCF_900455725.1_50477_H01_genomic.gbff -i GCF_001646655.1_ASM164665v1_genomic.gbff -o output.reordered -u yes
	art union.output.reordered.gbff


**AUTHOR:** Fabio Mota

https://github.com/fabiogvb
