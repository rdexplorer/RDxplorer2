#!/usr/bin/perl
@ARGV_store=@ARGV;
use Cwd;
use File::Basename;
my $cwd;
if ($0 =~ m{^/})
{
  $cwd = dirname($0);
} else
{
  $cwd = dirname(getcwd()."/$0");
}
$R_RDXPloprer_package=$cwd;


require "$R_RDXPloprer_package/Binning.pl";
require "$R_RDXPloprer_package/interface.pl";
require "$R_RDXPloprer_package/collect_paired_info.pl";
require "$R_RDXPloprer_package/paired_MQ.pl";

$temp_remove=0;
print "$R_RDXPloprer_package\n";



#$temp_remove=1;
&interface;

my $dirname = dirname($output);

if ((($PROC==1) or ($PROC==-1)) and ($INOUT_valid==1))
{
	print "$input	$output\n";
	print "	obtaining information from Bam file...\n";
	system "samtools view -X -F 0x400 $input | cut -f 1-5 > $output.pos";
	print "	Binning...\n";
	&binning("$output.pos");
	print "	RDXplorering...\n";
	system "Rscript RBatch.R $R_RDXPloprer_package $output";
	print "	Paired end info collecting...\n";
	#TODO:  clean up all the stuff that's no longer needed
	#either remove it here, or just don't generate it
	chdir($dirname);
	system("rm *.pos");
	system("rm *.count");
}


if ((($PROC==2) or ($PROC==-1)) and ($INOUT_valid==1))
{
	
	print "Extracting read pairs...\n";
	chdir($dirname);
	system ("$R_RDXPloprer_package/runReadExtractor.sh $input $dirname $qualThresh $maxQualThresh") 	
}


if ((($PROC==3) or ($PROC==-1)) and ($INOUT_valid==1))
{
	print "	===calculating support and p-value\n";
	chdir($dirname);
	chdir("pairedReads");
	system("Rscript $R_RDXPloprer_package/dup_support_new.R");
	system("Rscript $R_RDXPloprer_package/del_support_new.R");
}
