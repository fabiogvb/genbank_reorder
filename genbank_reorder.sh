#! /bin/bash
#==============================================================================
#title           :genbank_reorder
#description     :This script will reorder the contigs in GenBank format, including the annotated features, based on an other reference genbank file.
#author		 :Fabio Mota
#source		 :http://github.com/fabiogvb/genbank_reorder
#date            :20190524
#version         :1.0
#usage		 :./genbank_reorder.sh -r reference.genbank -i input.unordered.genbank -o output.reordered.genbank -u yes (default:no OPTIONAL union all output contigs in a unique artifitial contig) -k yes (default:no OPTIONAL keep all unnecessary files and log files)
#notes           :Install readseq, mauve-aligner and emboss packages before use this script.
#bash_version    :4.4.19(1)-release
#==============================================================================


# Checking dependences

if ! type "readseq" > /dev/null 2>/dev/null; then echo "\e[31mThe 'readseq' program is not in PATH or is not installed.\e[0m Try '\e[92msudo apt-get install readseq\e[0m'"; exit; fi
if ! type "mauve" > /dev/null 2>/dev/null; then echo "\e[31mThe 'mauve-aligner' program is not in PATH or is not installed.\e[0m 'Try \e[92msudo apt-get install mauve-aligner\e[0m'";exit; fi
if ! type "seqret" > /dev/null 2>/dev/null; then echo "\e[31mThe 'emboss' program is not in PATH or is not installed.\e[0m Try '\e[92msudo apt-get install emboss\e[0m'";exit; fi
if ! type "union" > /dev/null 2>/dev/null; then echo "\e[31mThe 'emboss' program is not in PATH or is not installed.\e[0m Try '\e[92msudo apt-get install emboss\e[0m'";exit; fi
if ! type "seqretsplit" > /dev/null 2>/dev/null; then echo "\e[31mThe 'emboss' program is not in PATH or is not installed.\e[0m Try '\e[92mudo apt-get install emboss\e[0m'";exit; fi

helpFunction()
{
   echo -e "\e[31mSyntax Error or missing required paramerters.\e[0m"
   echo -e ""
   echo -e "\e[1mNAME: GenBank Contig Reorder\e[0m"
   echo -e ""
   echo -e "\e[1mSYNOPSIS:\e[0m"
   echo -e ""
   echo -e "\e[92mUsage: $0 -r reference_file.gbff -i input_file.gbff -o output_file.gbff \e[32m-u yes -k yes\e[0m"
   echo -e ""
   echo -e "\e[1mRequired parameters:\e[0m"
   echo -e "\t\e[1m-r\e[0m Reference file in GenBank format with unique or multiple contigs. It will be used as reference to order the input file."
   echo -e "\t\e[1m-i\e[0m Input file in GenBank format with multiple contigs. The contigs will be reordered using mauve-aligner and the reference_file."
   echo -e "\t\e[1m-o\e[0m Output file will be save with this name in this place."
   echo -e ""
   echo -e "\e[1mOptional parameters:\e[0m"
   echo -e "\t\e[1m-u\e[0m Union parameter (default: -u no). If (-u yes) is used, it will concatenate all contigs in an unique artificial contig in the additional output file. This artificial chromosome can be viewed with artemis software."
   echo -e "\t\e[1m-k\e[0m Keep all files (default: -k no). If (-k yes) is used, all files are keeped including the aligments and log files."
   echo -e ""
   echo -e "\e[90mAUTHOR: Fabio Mota\e[0m"
   echo -e "\e[90mhttps://github.com/fabiogvb\e[0m"
   exit 1 # Exit script after printing help
}

while getopts "r:i:o:u:k:h" opt
do
   case "$opt" in
      r ) reference_file="$OPTARG" ;;
      i ) input_file="$OPTARG" ;;
      o ) output_file="$OPTARG.gbff" ;;
      u ) union="$OPTARG" ;;
      k ) keep="$OPTARG" ;;
      h ) helpFunction ;; # Print helpFunction
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case required parameters are empty
if [ -z "$reference_file" ] || [ -z "$input_file" ] || [ -z "$output_file" ]
then
   echo -e "\e[31mSome or all of the required parameters are empty!\e[0m";
   helpFunction
fi

#Checking if output file exist and if the current directory is writeable.
if [[ -f $output_file ]]; then
  echo "Error: $output_file already existing! Choose another output file name or delete the file $output_file."
  exit 1
fi
if >> $output_file
then echo -e "\e[1mStart Running GenBank Contig Reorder...\e[0m"
else -e "Error: write permission denied"; exit 1;
fi

# Converting GenBank to fasta files
echo -e "Converting files..."
readseq -a -f8 $reference_file > $reference_file.fasta
echo  -e "$reference_file converted."
readseq -a -f8 $input_file > $input_file.fasta
echo  -e "$input_file converted."
# Splitting Genbank input file
echo -e "Splitting GenBank input file $input_file..."
seqretsplit -auto -sequence $input_file -osformat2 genbank -feature 1> /dev/null 2> seqretsplit.log


# Running Maueve contig aligner
echo -e "\e[1mRunning contig aligner. Please wait some minutes...\e[0m "
java -Xmx500m -cp /usr/share/java/Mauve.jar org.gel.mauve.contigs.ContigOrderer -output results_dir -ref $reference_file.fasta -draft $input_file.fasta > mauve.log &


# Loop to wait the last alignment ("best alignment") of Mauve and the the tabular contig order file $last
counter=1
f="results_dir/alignment${counter}/${input_file}_contigs.tab"
echo -e  "Waiting for the BEST(LAST) alignment:"
while true;
do
  echo  -e "Running alignment $counter, aligning be patient..."
  sleep 5 ;
	if [ -e $f ]; then
	echo  -e "Alignment $counter finished. Let's go to the next alignment..."
	sleep 5 ;
	last="results_dir/alignment$counter/${input_file}_contigs.tab"
	let counter++ ;
	f="results_dir/alignment$counter/${input_file}_contigs.tab"
	if [ ! -d results_dir/alignment$counter ]; then
  let counter-- ;
  echo  -e "Concluded the alignment $counter";
	break;
fi
fi
done
echo  -e "THE BEST(LAST) ALIGNMENT FOUND! ALIGNMENT $counter"


# Discovering the contig order and if contig is in reverse strand based on the last alignment tabular file
#
echo -e "Reordering contigs..."
tabular="$last";
#statements: 0-nontargets lines before ^Ordered contigs, 1-target lines, 2- lines after targets
statements=0
while IFS= read -r line
do
    if [[ "$line" =~ conflicting.* ]] || [[ "$line" =~ ^Ordered.* ]]; then
      statements=$(($statements+1))
    fi
    if [[ "$statements" -eq 1 ]] && [[ "$line" =~ ^contig.* ]]; then
      IFS=$'\t' read -r -a array <<< $line
      if [[ "${array[3]}" == "complement" ]]; then
        contig=$( echo "${array[1]}" | tr -s '[:upper:]'  '[:lower:]')
        seqret -auto -sequence $contig.genbank -outseq $contig.reverse.genbank -sformat1 genbank -osformat2 genbank -feature -sreverse1
        cat $contig.reverse.genbank >> $output_file
        rm $contig.reverse.genbank
      fi
      if [[ "${array[3]}" == "forward" ]]; then
        contig=$( echo "${array[1]}" | tr -s '[:upper:]'  '[:lower:]')
        cat $contig.genbank >> $output_file
        rm $contig.genbank
      fi

      fi
done < "$tabular"
echo -e "\e[1mRESULTS\e[0m"
echo -e "Reordered contigs in GenBank format are in the file: \e[1m$output_file\e[0m "
# Running union to merge all contigs in a unique artificial chromosome that can be view with Artemis software
if [[ "$union" =~ yes.* ]]; then
  union -sequence $output_file -outseq union.$output_file -osformat genbank -feature -auto
  echo  -e "Artificial unique contig GenBank file (can be whole viewed with Artemis): \e[1munion.$output_file\e[0m"
fi

#Cleaning the java zumbie process still running
tokill=$(echo " $(ps aux | grep Mauve | grep $input_file )" | awk '{ print $2 } ')
IFS=' '
read -a processes <<< "$tokill"
for process in "${processes[@]}";
do
kill -9 $process
done

# Cleaning all unnecessary temporary files. Default (-k no)
if [[ "$keep" =~ yes.* ]]; then
  echo  -e "All files were keeped in the current directory or results_dir directory."
else
  rm -rf results_dir/ $reference_file.fasta $input_file.fasta *.genbank mauve.log seqretsplit.log
fi
