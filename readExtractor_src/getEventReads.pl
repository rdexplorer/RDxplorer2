#!/usr/bin/perl

#gets all the reads within the events borders
#usage:
#  getEventReads.pl eventFile.txt samFile.bam exten 37> eventReads.txt
#
#eventFile.txt is tab delimited with columns for
#the cnvID, 
#the chr
#the start of event
#the stop of event
#
#samFile.sam should be an indexed bam file
#sorted by chromosome order
#
#exten is a number added to the left and right boundaries
#to increase size of the event.  For deletions
#
#eventReads.txt is the tab separated output, it has columns for
#the cnvID
#the read (a row from the bam file)
#**after this step, eventReads.txt should be sorted by read ID**

use strict;
use warnings;

#TODO:  if two events are right next to each other and the boundary
#extension is large enough, it's possible that the reads
#found from one event might be the same as the reads from the 2nd.
#if this happens, the reads will not be in sorted order!


#TODO:  It might be faster to go through the bamfile
#myself instead of using samtools view chr:start-stop
#if the bam file is indexed it shouldn't be too bad
 
#TODO:  sometimes the bam file has references names like
#chr1, chrX, sometimes just 1, X.
#need a way to deal with both of them

#command line arguments
my $eventsFile=$ARGV[0];
my $bamFile=$ARGV[1];
#the start and stops of the events should be widened by this amount
#my $EVENT_EXTENSION = 500;
my $EVENT_EXTENSION = 0;
if (@ARGV >= 3){
	$EVENT_EXTENSION = $ARGV[2];
}

my $qualThresh = 37;
if (@ARGV >= 4){
	$qualThresh = $ARGV[3];
}

print STDERR "Events:  $eventsFile\n";
print STDERR "bamfile:  $bamFile\n";
print STDERR "event ext:  $EVENT_EXTENSION\n";
print STDERR "quality threshold:  $qualThresh\n";


#load in the events
open(EVENTS, $eventsFile);
my @events = <EVENTS>;
chomp(@events);
close(EVENTS);
#filter out events that don't have at least 4 columns
@events = grep(/.+\s.+\s.+\s./, @events);

#print STDERR "all events\n";
#foreach (@events){
#	print STDERR "$_\n";
#}
#print STDERR "all events end\n\n";


#find the type of the bamfile
#type1 if the reads wre mapped to "chrX"
#type2 if mapped to "X"
my $type = "";
my @testReads = `samtools view $bamFile | head -10 | cut -f3`;
if ($testReads[0] =~ /chr/){
	$type = "type1";
}
else{
	$type = "type2";
}

#process the events one by one
for my $event (@events){
	#get the event information
	my ($cnv, $chr, $start, $stop, $rest) = split ' ', $event;

	if ($type eq "type2"){
		$chr = substr $chr, 3;
	}
	#if we need to extend the boundaries(for large deletions)
	#then we don't need the reads in the middle
	#just get the stuff around the start and stop of the regions
	if (($EVENT_EXTENSION != 0) & ($stop-$start > 2*$EVENT_EXTENSION)){
		
		#the start of the event boundary
		my $a = $start - $EVENT_EXTENSION;
		$a = ($a < 0 ? 0 : $a);
		my $b = $start + $EVENT_EXTENSION;
		#print the reads that fall within 
		chomp (my @reads1 = `samtools view -X -q$qualThresh $bamFile $chr:$a-$b`);
		for my $r (@reads1){
			print "$cnv\t$r\n";	
		}

		#end of the event boundary
		$a = $stop - $EVENT_EXTENSION;
		$b = $stop + $EVENT_EXTENSION;
		chomp (my @reads2 = `samtools view -X -q$qualThresh $bamFile $chr:$a-$b`);
		for my $r (@reads2){
			print "$cnv\t$r\n";	
		}
	}
	#otherwise process the entire event
	#(duplications and small deletions)
	else{
		#extend the event boundaries
		$start = $start - $EVENT_EXTENSION;
		$start = ($start < 0 ? 0 : $start);
		$stop = $stop + $EVENT_EXTENSION;

		#print STDERR "\n<$event>\n";
		#print STDERR "\t<$cnv>\n";
		#print STDERR "\t<$chr>\n";
		#print STDERR "\t<$start>\n";
		#print STDERR "\t<$stop>\n";

		#find all the reads that fall within event bounds
		#print STDERR "samtools view -X $bamFile $chr:$start-$stop\n";
		chomp (my @reads = `samtools view -X -q$qualThresh $bamFile $chr:$start-$stop`);
		for my $r (@reads){
			print "$cnv\t$r\n";	
		}
	}
}



