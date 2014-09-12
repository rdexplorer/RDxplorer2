sub paired_mapping_quality
{

	for ($i=1;$i<=24;$i++)
	{
		undef %hash;
		#$i=1;
		$chr=$i;
		if ($i==23){$chr='X'}
    if ($i==24){$chr='Y'}
    print "$chr\n";
		open(input, "$output.chr$chr.pr_dup_0");
		#open(output, ">$output.chr$chr.pr_dup");
		while(<input>)
		{
			
			@f=split /\,/, $_;
			if ($f[4] =~/chr/){$hash_reads_id{"$f[4]-$f[6]"}=1}

		}

		
	}
		$pos_file=$_[0];	###this bam file should be sorted
	open(input, $pos_file);


	while(<input>)
	{

		$bam_content=$_;
		@f=split /\s+/, $bam_content;
		if ($hash_reads_id{"$f[2]-$f[0]"}==1){$hash_reads_id{"$f[2]-$f[0]"}=$f[4];}
		
	}		

	for ($i=1;$i<=24;$i++)
	{
		undef %hash;
		#$i=1;
		$chr=$i;
		if ($i==23){$chr='X'}
    if ($i==24){$chr='Y'}
    print "$chr\n";
		open(input, "$output.chr$chr.pr_dup_0");
		open(output, ">$output.chr$chr.pr_dup");
		while(<input>)
		{
			if (/^CNV_id/){print output;}
			else
			{
			@f=split /\,/, $_;
			if ($f[4] =~/chr/){$MQ2=$hash_reads_id{"$f[4]-$f[6]"};print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]";}
		
			if (($f[4] =~/=/) and ($hash_reads_id{$f[6]} ne ''))
			{
				$MQ2=$hash_reads_id{$f[6]};
				print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$MQ2,$f[7]";
			}
			if (($f[4] =~/=/) and ($hash_reads_id{$f[6]} eq '')){$hash_reads_id{$f[6]}=$f[2]}	
										
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
				
				print output "$f[0],$f[1],$f[2],$f[3],$f[4],$f[5],$hash_reads_tag{$f[6]},$f[7]";	
			}
			#	print output;

		}
		
	}
	undef %hash_id_st;
	undef %hash_id_nd;	
	undef %hash;		
}

1;