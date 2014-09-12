#!/usr/bin/perl
#look in the sorted sam file for paired reads
#matching the names of the sorted input
#
#usage:
#	./getPairs.pl reads_nameSorted.txt sam_nameSorted.txt > readPairs.txt
#	reads_nameSorted.txt are the reads you want the pairs for
#		first column is cnv ID
#		2nd column is the read
#	sam_nameSorted.txt is the sorted sam file you want to check
#	readPairs.txt are the read pairs
#		first column is cnv ID
#		2nd column is the read
#	assumes the files are sorted by name using unix sort
#** result file should be STABLE sorted by cnvID ** 

use strict;
use warnings;

#command line arguments
my $readsFile=$ARGV[0];
my $samFile=$ARGV[1];
print STDERR "Reads:  $readsFile\n";
print STDERR "samfile:  $samFile\n";


#the basic idea is to
#start with a pointer to the begining of the reads
#and a pointer at the begining of the sam file
#repeat till all the reads have been processed
#	move the sam pointer till it matches the read pointer
#	print out the matching reads
#	move the read pointer up by one.

#initialize the pointers
open(READS, $readsFile);
chomp(my $rline = <READS>); #read pointer
open(SAM, $samFile);
chomp(my $sline = <SAM>); #sam pointer

#while there are still reads to process
while((defined $rline) and (defined $sline)){	

	#breakup the readline into cnvID and read
	my($cnv, $rRead, $rRest) = split (/\s+/, $rline, 3);
	#print "<$cnv>\n";
	#print "<$rRead>\n";

	#print "read:  $rRead\n";
	#move the sam pointer till it matches the read
	while (defined $sline and $sline lt $rRead){
		#print "nomatch $samread\n";
		defined($sline = <SAM>) and chomp($sline);
	}

	#print out the matching reads along with their cnv IDs
	#should compare the read names, not the entire line
	last unless defined($sline); #stop if we've run out of sam
	my ($sRead, $sRest) = split(/\s+/, $sline, 2);
	while (defined $sline and $sRead eq $rRead){
		#print "match:  ";
		print "$cnv\t$sline\n";
		if (defined($sline = <SAM>) and chomp($sline)){
			($sRead, $sRest) = split(/\s+/, $sline, 2);
		}
	}

	#move the read pointer up by one
	defined ($rline = <READS>) and chomp($rline);
}

close(SAM);
close(READS);




