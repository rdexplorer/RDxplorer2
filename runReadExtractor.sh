#!/bin/bash
#collects read pairs from event regions
#
#input is a folder containing summary files describing
#the copy number event.  The .sum files are written in the first
#part of Rdexplorer
#
#output is a list of filtered read pairs from each event
#  {del,dup}Events.txt:  the list of events from the summary folder
#  {dels,dups}_chr{1..22,X,Y}chr.pr: the paired reads with event id
#  insDistr.txt:  the distribution of insert template lens taken
#  				from a sample of high quality reads
#  everything is writen to the newly created pairedReads folder
#  placed in the current directory
#
#usage:
#	./runReadExtractor.sh A01.bwa.bam /data/results/sumfolder 37 60

#get the directory that the code is stored in
codepath="$(dirname $BASH_SOURCE)/readExtractor_src"
#codepath="./readExtractor_src"

bam=A01.bwa.small.bam
#the output from the first part of rdexploer
sumfolder=/mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/data3/summaries
#sumfolder=/data/safe/kpradhan/projects/kenny/rdexplorer/data1/testSummaries/summaries/trunc
qthresh=37
maxqthresh=60

bam=$1
sumfolder=$2
qthresh=$3
maxqthresh=$4

echo "bamfile: $bam"
echo "summary folder: $sumfolder"
echo "quality thresh: $qthresh"
echo "maxquality thresh: $maxqthresh"

#step 1.  make the event files with entries for
#	cnvID chr start stop
#assume the events in rdx_raw.sum are already in chromosomal order
$codepath/getEvents.pl $sumfolder


#get all the reads that are in any of the events
#assumes the events are non overlapping within dels/dups
#keep the original bam index order
$codepath/getEventReads.pl delEvents.txt $bam 500 $qthresh >| tmp_delEventReads.txt
$codepath/getEventReads.pl dupEvents.txt $bam 0 $qthresh >| tmp_dupEventReads.txt
#sort the reads by the event ID which is already in chromosomal order
#not necessary if splitting into dels/dups
#sort -k1n delEventReads.txt -o tmp_delEventReads.txt
#sort -k1n dupEventReads.txt -o tmp_dupEventReads.txt

#rather than looking into the entire bam file, we can restrict the search space
#only look at reads that are in the event regions, or who's coordinates
#match the mates of those in the regions. 
#takes about 2.5 hours to run on a 130gb bam
#eventReads must be sorted in chromosomal order
#after getting the subset, sort by name and only keep unique reads
#sort param "-k 1 --buffer-size=75%"
$codepath/getSearchSpace.pl tmp_delEventReads.txt $bam | sort -k 1 | uniq >| tmp_delNameSortedSubsetSam.txt
$codepath/getSearchSpace.pl tmp_dupEventReads.txt $bam | sort -k 1 | uniq >| tmp_dupNameSortedSubsetSam.txt 

#sort the eventReads by name
sort -k 2 tmp_delEventReads.txt -o tmp_delNameSortedEventReads.txt
sort -k 2 tmp_dupEventReads.txt -o tmp_dupNameSortedEventReads.txt

#look in the name sorted sam for all the matching read names,
#filter out the bad ones, 
#and output as a table sorted by cnvid
#eventReads must be sorted in read name order
$codepath/getPairs.pl tmp_delNameSortedEventReads.txt tmp_delNameSortedSubsetSam.txt | sort -k 1 | $codepath/filterReadPairs.pl $qthresh | sort -k3 -n >| tmp_delFilteredReadPairs.txt
$codepath/getPairs.pl tmp_dupNameSortedEventReads.txt tmp_dupNameSortedSubsetSam.txt | sort -k 1 | $codepath/filterReadPairs.pl $qthresh | sort -k3 -n >| tmp_dupFilteredReadPairs.txt


#break the results up by chromosome
$codepath/formatResults.pl delEvents.txt tmp_delFilteredReadPairs.txt dels
$codepath/formatResults.pl dupEvents.txt tmp_dupFilteredReadPairs.txt dups


#create the insert length distribuion file
#takes about 30 minutes on a 130 bam file
#./getTemplateDistr.pl $bam 25000 60 >| insDistr_1.txt
$codepath/getTemplateDistr.sh $bam 50000 $maxqthresh insDistr.txt


#move results into a folder
mkdir -p pairedReads
mv {del,dup}Events.txt pairedReads
mv dels*pr pairedReads
mv dups*pr pairedReads
mv insDistr.txt pairedReads

#clean up the temporary files
#ls tmp_*
rm tmp_*


