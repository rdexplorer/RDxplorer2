#!/usr/bin/perl
#format the results of the filtered read pairs
#input are two files and a descrip prefix
#the first file is describing the events
#the 2nd file is the filtered read pair file
#both are sorted by event ID
#the prefix is the name of the output files
#writes both reads to one line, and separates into files by chrom
#usage:
#  ./formatResults dupEvents.txt dupFilteredReads.txt dups


use strict;
use warnings;

#get command line arguments
my $eventsFile = $ARGV[0];
my $pairFile = $ARGV[1];
my $outputPrefix = $ARGV[2];
print "$eventsFile\n";
print "$pairFile\n";
print "$outputPrefix\n";


#load the events file into mem
open(EVENTS, "<", $eventsFile);
my @events = <EVENTS>;
chomp(@events);
close(EVENTS);

#use a hash to find which event goes to which chrom
#also, the starts and stops
my %id2Chr;
my %id2Start;
my %id2Stop;
for my $event (@events){
	my ($cnv, $chr, $start, $stop) = split ' ', $event;
	$id2Chr{$cnv} = $chr;
	$id2Start{$cnv} = $start;
	$id2Stop{$cnv} = $stop;
}


#open a file for each chromosome(24)
my @chrs = map {"chr" . $_} (1..22,"X","Y");
#save the filehandles to the open files in a hash, with chr as key
my %fileHandles;  
for my $chr (@chrs){
	my $fileName = "".$outputPrefix."_".$chr.".pr";	
	open (my $FH, ">", $fileName);
	$fileHandles{$chr} = $FH;
	print "<$fileName>\n";
}


#for my $FH (values %fileHandles){
#	print $FH "test";
#}

#open up the pairs file
#assume it's already filtered
#and every 2 lines are already matched
open(PAIRS, "<", $pairFile);
my $pair1;
my $pair2;
while ($pair1 = <PAIRS>){
	$pair2 = <PAIRS>;
	chomp($pair1);
	chomp($pair2);

	#the fields of the filtered pair file
	my ($name1, $flag1, $cnv1, $ori1, $chr1, $pos1, $len1, $ptype1, $q1, $tlen1) = split(' ', $pair1, 10);
	my ($name2, $flag2, $cnv2, $ori2, $chr2, $pos2, $len2, $ptype2, $q2, $tlen2) = split(' ', $pair2, 10);

	#find out which chromosome the event is on
	#print "currentCNV:  <$cnv1>\n";
	my $curChrom = $id2Chr{$cnv1};
	my $curStart = $id2Start{$cnv1};
	my $curStop = $id2Stop{$cnv1};
	#print "currentChrom:  <$curChrom>\n";
	#determine which file to write to
	my $FH = $fileHandles{$curChrom}; 


	#write the two pairs to their proper output file
	#make sure the read from the event's region is written first
	if (($chr1 eq $curChrom) & ($pos1 >= $curStart) & ($pos1 <= $curStop)){
		print $FH "$pair1\t";
		print $FH "$pair2\n";
	}
	else{
		print $FH "$pair2\t";
		print $FH "$pair1\n";
	}
	
	#Something went wrong.  The input file is not paired correctly
	if ($name1 ne $name2){
		print "wierd";
		print "$name1\n";
		print "$name2\n\n";
		die;
	}

}
close(PAIRS);


#close all the open files
for my $FH (values %fileHandles){
	close($FH);	
}



