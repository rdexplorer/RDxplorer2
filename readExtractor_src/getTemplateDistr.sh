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


bam=/Volumes/HD3/CEUTrio/NA12878.mapped.ILLUMINA.bwa.CEU.high_coverage_pcr_free.20130906.bam
 bam=$1
nSamps=50000
 nSamps=$2
maxQual=60
 maxQual=$3
outFile=insDistr.txt
 outFile=$4

#get the total number of mapped reads
samtools idxstats $bam | cut -f3 > temp0
nReads=`paste -sd+ temp0| bc`
rm temp0

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


#1. sort by read names

samtools sort -n tmp_small.bam tmp_small.sort

#2. add a column to the sam file so that it fits the requirement of filterReadPairs.pl
 
samtools view -F 256 tmp_small.sort.bam | $codepath/addColumn.pl >| tmp_small.sort.txt
#samtools view -X -F 256 tmp_small.sort.bam | $codepath/addColumn.pl >| tmp_small.sort.txt

#3. filter pairs that are mapped to different chromosomes or with inconsistent directions

awk '$8 == "="' tmp_small.sort.txt | $codepath/filterReadPairs.pl $maxQual >| tmp_distrFilteredReadPairs.txt

#4.  report insert size
#	save it to insDistr.txt
cut -f10 tmp_distrFilteredReadPairs.txt | grep -v -e "-" >| $outFile

#TODO: do reservoir sampling here if necessary. 


#head insDistr.txt 
#tail insDistr.txt 

#make sure there are no 0's
#this should print a blank line
#cat tmp_distrFilteredReadPairs.txt | awk '$10 == 0'

