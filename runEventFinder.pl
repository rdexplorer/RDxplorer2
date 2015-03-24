#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use Cwd;
use Cwd 'abs_path';

#get the folder where the script is kept.
abs_path($0) =~ /(.*)\/runEventFinder\.pl/;
my $codepath = $1;

require "$codepath/Binning.pl";


#get the first input argument
my $bamFile = $ARGV[0];
#my($filename, $dirs, $suffix) = fileparse($bamFile);
print "bam file: $bamFile\n";
#print "f: $filename, d: $dirs, s: $suffix\n";


#first step is to make a symbolic link of the bamfile in the current directory
#system("ln -s $bamFile $filename");
#system("ln -s $bamFile.bai $filename.bai");

#compute bins
&binning("samtools view -F 0x400 $bamFile | cut -f 1-5 |");

#find events
print "	RDXploring...\n";
#*tricky*...the 2nd argument is NOT the working directory
#it's the working dir AND the prefix of the result files.
#print ("Rscript $codepath/RBatch.R $codepath ./rdxp");
system "Rscript $codepath/RBatch.R $codepath ./rdxp";

