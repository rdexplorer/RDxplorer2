####
sub interface
{

#########default value#######
        $input_validated=1;
        $show_help=0;
#############################

        for ($no_arg=0;$no_arg<10;$no_arg++)
        {

			if ($ARGV[$no_arg]=~/In=/){@f=split /\=/, $ARGV[$no_arg];$input=$f[1];}
			if ($ARGV[$no_arg]=~/Out=/){@f=split /\=/, $ARGV[$no_arg];$output=$f[1];}
			if ($ARGV[$no_arg]=~/MQValid=/){@f=split /\=/, $ARGV[$no_arg];$MQValid=$f[1];}
			if ($ARGV[$no_arg]=~/qualThresh=/){@f=split /\=/, $ARGV[$no_arg];$qualThresh=$f[1];}
			if ($ARGV[$no_arg]=~/maxQualThresh=/){@f=split /\=/, $ARGV[$no_arg];$maxQualThresh=$f[1];}
                                
			if ($ARGV[$no_arg] eq '-Depth'){$PROC=1}
			if ($ARGV[$no_arg] eq '-PairCollect'){$PROC=2}
			if ($ARGV[$no_arg] eq '-PairValid'){$PROC=3}
			if ($ARGV[$no_arg] eq '-All'){$PROC=-1}

			#TODO:  put in a check for quality thresholds when doing part 2

			if (!($PROC==0) and (-e $input) and ($output ne '')){$INOUT_valid=1}

			if (($PROC>0) and (!(-e $input))) {$INOUT_valid=-10;$Error_info="The input file is not exist";}
			if (($PROC>0) and ($output eq '')) {$INOUT_valid=-11;$Error_info="output file";}
        }

        if ($INOUT_valid<0)
        {
                        print "
Program: Rdxplorer 2
Version: 1.0.1

Usage: ./rdxplorer_pair.pl -Depth/-PairCollect/-PairValid/-All In=[sorted bam file] Out=[output_file]


#######################
##	Error: $Error_info
#######################
";
                $input_validated=0;
        }
	elsif ($INOUT_valid==0)
        {

                        print "
Program: Rdxplorer 2
Version: 1.0.1

Usage: ./rdxplorer_pair.pl -Depth/-PairCollect/-PairValid/-All In=[sorted bam file] Out=[output_file] qualThresh=37 maxQualThresh=60

Options:

In=File                 Input file, the sorted bam file. (Required)
Out=File                output file. (Required)
qualThresh	k		quality threshhold of k for extracting paired reads
maxQualThresh m		maximum quality threshold of m for determining template length distribution
-Depth			Process the original Rdxplorer
-PairCollect		Botain paired-end information
-PairValid		Integrate paired-end information final result
-All			Process the steps altogether



";
                $input_validated=0;
        }
        else
        {

                print "
Program: Rdxplorer 2
Version: 1.0.1


";

        }


#print
#"
#ALL=$ALL
#ValidatorOnly=$ValidatorOnly
#CandetOnly=$candetOnly
#F1=$fastq1
#F2=$fastq2
#Bowtie_ref=$BT_reference
#output=$output
#
#Max_indel_size=$MAX_size_indel
#Num_mis=$Num_Missmatch
#
#";




}



1;
