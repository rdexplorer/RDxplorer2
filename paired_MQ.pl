sub paired_mapping_quality
{

	
	
	print "		Obtain mapping information of pair-mates...\n";
	for ($i=1;$i<=24;$i++)
	{
		undef %hash;
		#$i=1;
		$chr=$i;
		if ($i==23){$chr='X'}
    if ($i==24){$chr='Y'}
		$hash_chr{$chr}=1;$hash_chr{"chr$chr"}=1;
		
		
		open(input, "$output.chr$chr.pr_dup_0");
		#open(output, ">$output.chr$chr.pr_dup");
		while(<input>)
		{
			chomp;
			@f=split /\,/, $_;
			#if ($f[4] =~/chr/){$hash_reads_id{"$f[4]-$f[6]"}=1}
			$chain=-$f[8]+3;   ##change chain to its comtepart
			$CHR_id=$f[4];
			if ($f[4] eq '='){$CHR_id=$chr;}			
			$hash_reads_id{"$CHR_id-$f[6]-$chain"}=1;
		
		}

		
	}
		$pos_file=$_[0];	###this bam file should be sorted
		
		
	open(input, $pos_file);


	while(<input>)
	{
		
		$bam_content=$_;
		@f=split /\s+/, $bam_content;
		
		if ($f[1]=~/1/){$paired_id=1}elsif ($f[1]=~/2/){$paired_id=2}
		$f[2]=~s/chr//;
		if ($hash_reads_id{"$f[2]-$f[0]-$paired_id"}==1){$hash_reads_store{"$f[2]-$f[0]-$paired_id"}=$_;$hash_reads_MQ{"$f[2]-$f[0]-$paired_id"}=$f[4];if (/D74RYQN1:210:D0AEBACXX:5:1106:19879:120428/){print;}}

	}		

	for ($i=1;$i<=24;$i++)
	{
		undef %hash;
		#$i=1;
		$chr=$i;
		if ($i==23){$chr='X'}
    if ($i==24){$chr='Y'}
    #print "$chr\n";
		open(input, "$output.chr$chr.pr_dup_0");
		open(output, ">$output.chr$chr.pr_dup");

		while(<input>)
		{
			if (/^CNV_id/){print output;}
			else
			{
			@f=split /\,/, $_;
			$CHR_id=$f[4];
			if ($f[4] eq '='){$CHR_id=$chr;}		
			
			$chain=-$f[8]+3;   ##change chain to its comtepart  	

			if ($hash_chr{$f[4]}==1)
			{
				#print "$CHR_id-$f[6]-$chain	$MQ2	$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]\n";	
				$MQ2=$hash_reads_MQ{"$CHR_id-$f[6]-$chain"};
				print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]\n";
				#if (/D74RYQN1:210:D0AEBACXX:5:1106:19879:120428/){print	"$_$CHR_id-$f[6]-$chain\n";}
				#print "\n##############\n$_$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]\n$STOR";
			}
	
				
				
			if (($f[4] =~/=/))
			{
				$chain=-$f[8]+3;   ##change chain to its comtepart  							
				$MQ2=$hash_reads_MQ{"$CHR_id-$f[6]-$chain"};
				print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]\n";
				$STOR=$hash_reads_store{"$CHR_id-$f[6]-$chain"};
				#print "\n##############\n$_$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]\n$STOR";
			}
			#if (($f[4] =~/=/) and ($hash_reads_id{$f[6]} eq '')){$hash_reads_id{$f[6]}=$f[2]}	
										
		}
	}
	
		
	}
	undef %hash_reads_id;
	
}


sub formating_dup
{
	
	open(output, ">$_[2].new");
	open(input, $_[0]);
	while(<input>)
	{
		@f=split /\,/, $_;	
		$hash_id_st{$f[0]}=$f[6];
		$hash_id_nd{$f[0]}=$f[7];		
		$hash{$f[0]}=$_;	
	}
	open(input, $_[1]);
	open(output, ">$_[2].new");
	while(<input>)
	{
		@f=split /\,/, $_;
		if (/=/)
		{
			if (($f[1]<$hash_id_nd{$f[0]}+100)	and ($f[1]>=$hash_id_st{$f[0]}-100))	
			{
				print output;
			}
			else
			{

				#print "$hash{$f[0]}";
			}
		}
		else
		{
				print output;
		}
		
	}
	undef %hash_id_st;
	undef %hash_id_nd;	
	undef %hash;		
}


sub formating_del
{
	
	open(output, ">$_[2]");
	open(input, $_[1]);
	while(<input>)
	{
		
		@f=split /\,/, $_;
		if (/^CNV_id/){print output;}
		if (/=/)
		{

			if ($hash_reads_tag{$f[6]} eq '')
			{
				$hash_reads_tag{$f[6]}=$f[2];
			}
			else
			{
				
				print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$hash_reads_tag{$f[6]},$f[7]\n";	
			}
			#	print output;

		}
		
	}
	undef %hash_id_st;
	undef %hash_id_nd;	
	undef %hash;		
}

1;