# genbank_reorder

NAME: GenBank Contig Reorder

SYNOPSIS:

Usage: ../teste.sh -r reference_file.gbff -i input_file.gbff -o output_file.gbff -u yes -k yes

Required parameters:

	-r Reference file in GenBank format with unique or multiple contigs. It will be used as reference to order the input file.
	-i Input file in GenBank format with multiple contigs. The contigs will be reordered using mauve-aligner and the reference_file.
	-o Output file will be save with this name in this place.

Optional parameters:

	-u Union parameter (default: -u no). If (-u yes) is used, it will concatenate all contigs in an unique artificial contig in the additional output file. This artificial chromosome can be viewed with artemis software.
	-k Keep all files (default: -k no). If (-k yes) is used, all files are keeped including the aligments and log files.

AUTHOR: Fabio Mota

https://github.com/fabiogvb
