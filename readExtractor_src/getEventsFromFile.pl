#!/usr/bin/perl
#creates two event files for the dels and dups in current dir
#input is a single file containing at least these columns
#chrom, posStart, posEnd, state
#The input event list must have it's events sorted in chromosomal order.
#result event files have:
#	event number
#	chr
#	start
#	stop
#   ... everything else
#usage:
#	./getEvents.pl /mnt/wigclust17/data/unsafe/kpradhan/projects/kenny/rdexplorer/A01/cassava_eventInput/ 


use strict;
use warnings;

#command line arguments
my $sumFile = $ARGV[0];
print "summary file:  $sumFile\n";

#to be filled from the the summary file
my @events;  

open my $sfh, "<", $sumFile; 

	#read first line to find out which columns belong to
	#	state chrom posStart posEnd
	my @headers = split ' ', <$sfh>;
	my ($stateIx, $chromIx, $startIx, $stopIx);
	for my $i (0 .. $#headers) {
		print "$i: $headers[$i]\n";
		if ($headers[$i] eq "state"){
			$stateIx = $i;
		}
		if ($headers[$i] eq "chrom"){
			$chromIx = $i;
		}
		if ($headers[$i] eq "posStart"){
			$startIx = $i;
		}
		if ($headers[$i] eq "posEnd"){
			$stopIx = $i;
		}
	}

	#process summary file line by line
	while(my $line = <$sfh>){
		chomp($line);
		my @fields = split ' ', $line;
		my $state = $fields[$stateIx];
		my $chrom = $fields[$chromIx];
		#make sure the chrom starts with a "chr"
		if ($chrom !~ /^chr/){
			$chrom = "chr".$chrom;
		}
		my $start = $fields[$startIx];
		my $stop = $fields[$stopIx];
		
		#retain  the columns for state, chr, start, stop
		#add a "chr" to the chr field
		#print "$state\tchr$chrom\t$start\t$stop\n";
		push @events, "$state\t$chrom\t$start\t$stop\t$line";

	}

close $sfh;


#for my $event (@events){
#	print "$event\n";
#}

#TODO:  make sure events are sorted by chromosomal order
#


#now that the events are read in
#write them to two separate files for dels and dups
#include an id for the events as the first column
open my $delfh, ">", "delEvents.txt";
open my $dupfh, ">", "dupEvents.txt";

	my $enum = 1;
	for my $event (@events){
		my ($state, $rest) = split ' ', $event, 2;
		#state 1 are deletions
		if ($state eq "del" or $state eq "-" or $state eq "1"){
			print $delfh "$enum\t$rest\n";
		}
		#state 1 are duplications
		if ($state eq "dup" or $state eq "+" or $state eq "3"){
			print $dupfh "$enum\t$rest\n";
		}
		$enum++;
	}

close $delfh;
close $dupfh;



