#!/usr/bin/perl

#given a set of reads return that set, plus, any reads from the bam file
#who's coordinates match the coordinates of any pair of the
#input set

#usage 
#  ./getSearchSpace.pl tmp_delEventReads_22.txt SSC06293.RG2.chr22.bam | sort -k1 | uniq > tmp_nameSortedSam.txt
#the input file from the pipeline has a first column for the event ID
#once we have all the reads, sort them by name so they can be
#used later on the pipeline

use strict;
use warnings;
use List::MoreUtils qw(uniq);
use Scalar::Util qw(looks_like_number);

#command line arguments
my $readsFile=$ARGV[0];
my $bamFile=$ARGV[1];

my $qualThresh = 37;
if (@ARGV >= 3){
	$qualThresh = $ARGV[2];
}
print STDERR "reads:  $readsFile\n";


#load input into array
#these are the reads that are within the CNV
open(READS, $readsFile);
my @reads = <READS>;
chomp(@reads);
close(READS);

#the coordinates of the mates
#stored as a string "chr pos"
my @searchCoords;

print STDERR "reading event reads...\n";
#process all input reads
for my $read (@reads){

	#find the coord of its mate
	my ($cnv1, $name1, $flag1, $chr1, $pos1, $q1, $cig1, $pchr1, $ppos1, $rest1) = split(/\s+/, $read, 10);

	if ($pchr1 eq "="){ 
		$pchr1 = $chr1;
	}
	#make sure we're using "1" instead of "chr1"
	$pchr1 = chrToNum($pchr1);

	#the current read should be in our search space
	#get rid of the cnvID
	my ($tmp1, $tmp2) = split(/\s+/, $read, 2);
	print "$tmp2\n";


	#print "<".$pchr1." ".$ppos1.">\n";
	#add the coordinate of the read's pair
	#for further processing
	push (@searchCoords, $pchr1." ".$ppos1);
}

print STDERR "done reading event reads\n";

##sort by chromosome then position
##this won't work!  1 11 12 13... 2 21 22 3 4
#@searchCoords = uniq sort @searchCoords;
#for my $coord (@searchCoords[0 .. 10]){
#	print "$coord\n";
#	my ($chr, $pos) = split(' ', $coord);
#	print "\t$chr\t$pos\n";
#}

#schwartian transform.  search by chr then position
#must match sorting procedure of the bam file
#chr must be sorted numerically not as a string
@searchCoords =
    map  $_->[0] =>
    sort { $a->[1] <=> $b->[1] ||
           $a->[2] <=> $b->[2] }
    map  [ $_, split(' ', $_)]
      => @searchCoords;

##print all the search coordinates
#print "\n\n*********************\n\n";
##for my $coord (@searchCoords[0 .. 10]){
#for my $coord (@searchCoords){
#	print "$coord\n";
#	my ($chr, $pos) = split(' ', $coord);
#	print "\t$chr\t$pos\n";
#}

#convert the chromosome to a number.
sub chrToNum{
	my $chr = $_[0];
	if ($chr =~ /chr(.*)/){ $chr = $1;} #strip of the chr if necessary
	if ($chr eq "X") { $chr = "23"; }	
	if ($chr eq "Y") { $chr = "24"; }	
	if (not looks_like_number($chr )) { $chr = "25" };
	return $chr;
}


#get the chromosome and position from a line of a bam
#the chrom and pos will be numeric, with X = 23, Y = 24
#anything else like GL02934 will be a 25
sub getChrPos{
	my $bamLine = $_[0]; #func parameter
	my ($name2, $flag2, $chr2, $pos2, $rest2) = split(/\s+/, $bamLine, 5);
	$chr2 = chrToNum($chr2);
	return ($chr2, $pos2);
}

#go through the bam file printing all the reads matching any of the coord
#TODO:  find flags to get rid of PCR dups and unmapped reads
open SAM, "samtools view -X -q$qualThresh $bamFile |"; 
my $bamLine = <SAM>; #move pointer to the first line of the sam
#chr and position of the sam file
my ($chr2, $pos2) = getChrPos($bamLine);
#for every coordinate (they're already sorted and unique)
for my $coord (@searchCoords){
	#if the entire bam has been read then we're done
	last unless defined $bamLine;

	#get the chr and position of the current coord	
	my ($chr1, $pos1) = split(' ', $coord);

	#if the sam file is past the current coord 
	#then we can't process this coord, 
	#it shouldn't happen if we use the full genome bam
	if (($chr1 < $chr2) or ($chr1 == $chr2 and $pos1 < $pos2)){
		next;
	}

	#print "processing a read\n";
	#print "read:  $chr1\t$pos1\n";
	#print "cursam:  $chr2\t$pos2\n\n";

	#keep reading the sam file while the position is less than current coord
	while (($chr2 < $chr1) or ($chr2 == $chr1 and $pos2 < $pos1)){
		$bamLine = <SAM>;
		last unless defined $bamLine;
		($chr2, $pos2) = getChrPos($bamLine);

		#print "$bamLine";
		#print "$name2\t$flag2\t$chr2\t$pos2\n\n";
		#if ($pos2 % 1000 == 0) {print "$pos2\n";}
	}
	
	#keep printing the sam file while pos == current coord
	while ($chr1 == $chr2 and $pos1 == $pos2){
		print "$bamLine";

		$bamLine = <SAM>;
		last unless defined $bamLine;
		($chr2, $pos2) = getChrPos($bamLine);
	}

}
close SAM;
