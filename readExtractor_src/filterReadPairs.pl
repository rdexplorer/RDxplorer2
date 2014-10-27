#!/usr/bin/perl
#takes a sorted results from getPairs
#and filters away the bad stuff
#1st parameter is the quality score threshold
#usage
#  sort -k 1 readPairs.txt | ./filterReadPairs.pl 37 > filteredReadPairs.txt


use strict;
use warnings;

my $qualThresh;
if (@ARGV == 0){
	$qualThresh = 37;
}
else{
	$qualThresh = $ARGV[0]
}
print STDERR "qual score thresh: $qualThresh\n";

my $line1; 
my $line2;

#read from standard input line by line
#matching pairs along the way
$line1 = <STDIN>;  
while (defined $line1){
	$line2 = <STDIN>;

	#check if we're done
	last unless defined $line2;

	#see if the 2nd line matches the first
	my ($cnv1, $name1, $flag1, $chr1, $pos1, $q1, $cig1, $pchr1, $ppos1, $tlen1, $read1, $rest1) = split(/\s+/, $line1, 12);
	my ($cnv2, $name2, $flag2, $chr2, $pos2, $q2, $cig2, $pchr2, $ppos2, $tlen2, $read2, $rest2) = split(/\s+/, $line2, 12);
	
	#only work on pairs
	if ($name1 eq $name2){
		#tells us if we should use this pair
		my $isGood = 1;

		#both must be mapped with high quality
		if ($q1 < $qualThresh) { $isGood = 0; }
		if ($q2 < $qualThresh) { $isGood = 0; }

		#TODO: take this out
		#both must be mapped to the same chromosome
		#if ($chr1 ne $chr2) { $isGood = 0; }

		#samtools flag info
		#p=0x1   paired in sequencing
		#P=0x2   properly paired
		#u=0x4   unmapped
		#U=0x8   mate unmapped
		#r=0x10  reverse
		#R=0x20  mate reverse
		#1=0x40  first read in the pair
		#2=0x80  second in the pair
		#s=0x100 secondary alignment
		#f=0x200 QC failure
		#d=0x400 duplicates
		#*       no flag set

		#ignore if both are mapped to the reverse
		#if ($flag1 =~ /rR/) { $isGood = 0; } 
		#if ($flag1 =~ /Rr/) { $isGood = 0; } 
		if ($flag1 & hex("0x10") and ($flag2 & hex("0x10") )){
			$isGood = 0; 
		}

		#ignore if both are not mapped to the reversed
		#if ((not $flag1 =~ /r/) and (not $flag2 =~ /r/)) { $isGood = 0; }
		if (not $flag1 & hex("0x10") and (not $flag2 & hex("0x10") )){
			$isGood = 0; 
		}

		#orientation, forward/reverse
		#my $ori1 = ($flag1 =~ /r/ ? "r" : "f");
		#my $ori2 = ($flag2 =~ /r/ ? "r" : "f");		
		my $ori1 = ($flag1 & hex("0x10") ? "r" : "f");
		my $ori2 = ($flag2 & hex("0x10") ? "r" : "f");

		#is it the first or 2nd read
		#my $pair1 = ($flag1 =~ /1/ ? "1" : "2");
		#my $pair2 = ($flag2 =~ /1/ ? "1" : "2");
		my $pair1 = ($flag1 & hex("0x40") ? "1" : "2");
		my $pair2 = ($flag2 & hex("0x40") ? "1" : "2");

		if ($isGood){
			#print the first pair first
			if ($pair1 eq "1"){
				print "$name1\t$flag1\t$cnv1\t$ori1\t$chr1\t$pos1\t".length($read1)."\t$pair1\t$q1\t$tlen1\n";	
				print "$name2\t$flag2\t$cnv2\t$ori2\t$chr2\t$pos2\t".length($read2)."\t$pair2\t$q2\t$tlen2\n";	
			}
			else{
				print "$name2\t$flag2\t$cnv2\t$ori2\t$chr2\t$pos2\t".length($read2)."\t$pair2\t$q2\t$tlen2\n";	
				print "$name1\t$flag1\t$cnv1\t$ori1\t$chr1\t$pos1\t".length($read1)."\t$pair1\t$q1\t$tlen1\n";	
			}
		}
	}
	#ignore single reads
	else{
		#prepare for processing the next line
		$line1 = $line2;
	}

}
