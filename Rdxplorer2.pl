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

$temp_remove=0;
print "$R_RDXPloprer_package\n";



#$temp_remove=1;
&interface;

my $dirname = dirname($output);

if ((($PROC==1) or ($PROC==-1)) and ($INOUT_valid==1))
{
	print "$input	$output\n";
	print "	obtaining information from Bam file...\n";

	print "	Binning...\n";
	#work on an open file handle instead of creating a temporary file
	&binning("samtools view -F 0x400 $input | cut -f 1-5 |");

	print "	RDXplorering...\n";
	system "Rscript RBatch.R $R_RDXPloprer_package $output";
	print "	Paired end info collecting...\n";
	#clean up all the unecessary stuff
	chdir($dirname);
	#system("rm *.pos");
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
