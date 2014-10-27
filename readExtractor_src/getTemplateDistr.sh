#!/bin/bash
#reads a bam file and saves the insert template sizes
#of the reads passing a set of criteria:
#	both read pairs must have quality score > thresh
#	both read pairs must be mapped to the same chr
#	both read pairs must not map to same strand
#usage:
#read qual > 60
#try to sample  ~50k reads
#save the distribution to insDistr.txt
#  ./getInsDistr.sh A01.bwa.small.bam 50000 60 insDistr.txt

codepath=$(dirname $BASH_SOURCE)


bam=A01.bwa.small.bam
bam=$1
nSamps=50000
nSamps=$2
maxQual=60
maxQual=$3
outFile=insDistr.txt
outFile=$4

#get the total number of mapped reads
nReads=`samtools idxstats $bam | cut -f3 | paste -sd+ | bc`

#if necessary, create a smaller bam file
if   [ $nReads -le 200000 ]; then
	samtools view -hb -q$maxQual -o tmp_small.bam $bam 
elif [ $nReads -le 2000000 ]; then
	samtools view -s 0.1 -hb -q$maxQual -o tmp_small.bam $bam 
elif [ $nReads -le 20000000 ]; then
	samtools view -s 0.01 -hb -q$maxQual -o tmp_small.bam $bam
elif [ $nReads -le 200000000 ]; then
	samtools view -s 0.001 -hb -q$maxQual -o tmp_small.bam $bam
else 
	samtools view -s 0.0001 -hb -q$maxQual -o tmp_small.bam $bam 
fi

#create the index for the small bam 
#assume it's already sorted
samtools index tmp_small.bam 


#1.  get a random sample of reads
#	start with the bam's header
samtools view -H tmp_small.bam >| tmp_distrReads.txt
#	then append a random selection of reads
#		from those with a mate mapping to same chr
#		and meet the quality threshold
samtools view -F 1024 -q$maxQual tmp_small.bam | awk '$7 == "="'| $codepath/reservoirSample.pl $nSamps >> tmp_distrReads.txt
#need to sort the reads by coordinates 
#	a. first turn it into a bam
samtools view -Sb tmp_distrReads.txt >| tmp_distrReads.bam
#	b. then sort
samtools sort tmp_distrReads.bam tmp_distrReads_sorted
#	c. then turn it back to a txt file
#		#needs human readable bam flags!
#	while appending a dummy event ID
samtools view -X tmp_distrReads_sorted.bam | $codepath/addColumn.pl >| tmp_distrReads.txt

#2.  get search space for those random reads
$codepath/getSearchSpace.pl tmp_distrReads.txt tmp_small.bam | sort -k 1 | uniq >| tmp_distrNameSortedSubsetSam.txt 
#

#3a. the event reads must first be sorted by name
sort -k 2 tmp_distrReads.txt -o tmp_NameSortedDistrReads.txt
#3b.  get read pairs
#	  and filter them
$codepath/getPairs.pl tmp_NameSortedDistrReads.txt tmp_distrNameSortedSubsetSam.txt | sort -k 1 | $codepath/filterReadPairs.pl $maxQual | sort -k3 -n >| tmp_distrFilteredReadPairs.txt


#4.  report insert size
#	save it to insDistr.txt
cut -f10 tmp_distrFilteredReadPairs.txt | grep -v -e "-" >| $outFile
head insDistr.txt 
tail insDistr.txt 

#make sure there are no 0's
#this should print a blank line
cat tmp_distrFilteredReadPairs.txt | awk '$10 == 0'

