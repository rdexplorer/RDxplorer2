####
sub interface
{

#########default value#######
        $input_validated=1;
        $show_help=0;
#############################

        for ($no_arg=0;$no_arg<10;$no_arg++)
        {


                if ($ARGV_store[$no_arg]=~/In=/){@f=split /\=/, $ARGV_store[$no_arg];$input=$f[1];}
                if ($ARGV_store[$no_arg]=~/Out=/){@f=split /\=/, $ARGV_store[$no_arg];$output=$f[1];}
               
        }
				#print "$input\n$output\n";
        if (($input eq '') or ($output eq ''))
        {

                        print "
Program: RDxplorer2
Version: xxx

Usage: ./rdxplorer_pair.pl In=[sorted bam file] Out=[output_file]

Options:

In=File                 Input file, the sorted bam file. (Required)
Out=File                output file. (Required)
";
                $input_validated=0;
        }
        else
        {

                print "
Program: RDxplorer2
Version: xxx

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
