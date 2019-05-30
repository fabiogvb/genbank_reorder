# genbank_reorder

NAME: GenBank Contig Reorder

SYNOPSIS:

Usage: ./genbank_reorder.sh -r reference_file.gbff -i input_file.gbff -o output_file.gbff -u yes -k yes

Required parameters:

	-r Reference file in GenBank format with unique or multiple contigs. It will be used as reference to order the input file.
	-i Input file in GenBank format with multiple contigs. The contigs will be reordered using mauve-aligner and the reference_file.
	-o Output file will be save with this name in this place.

Optional parameters:

	-u Union parameter (default: -u no). If (-u yes) is used, it will concatenate all contigs in an unique artificial contig in the additional output file. This artificial chromosome can be viewed with artemis software.
	-k Keep all files (default: -k no). If (-k yes) is used, all files are keeped including the aligments and log files.

INSTALL INSTRUCTIONS

Install dependecies in your operation system:
For Debian or similar
sudo apt-get install readseq mauve-aligner emboss
For CentOS
sudo yum install readseq mauve-aligner emboss
For MacOS
brew install readseq mauve-aligner emboss

Install Genbank Contig Reorder:
git clone https://github.com/fabiogvb/genbank_reorder
cd genbank_reorder
chmod +x genbank_reorder.sh
./genbank_reorder.sh

AUTHOR: Fabio Mota

https://github.com/fabiogvb
