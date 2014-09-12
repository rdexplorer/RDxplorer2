###################################################formating R-readable file#################################################################
sub formating_R
{
open(input1, "$output.$chr.distri");
while(<input1>)
{
	my @f=split /\s+/, $_;
}

open(output_id_dup, ">$output.$chr.id_dup");
open(output_pr_dup, ">$output.$chr.pr_dup_0");
open(output_id_del, ">$output.$chr.id_del");
open(output_pr_del, ">$output.$chr.pr_del_0");


print output_id_dup "CNV_id,state,length,copy_num,depth,zstat,posStart,posEnd\n";
print output_pr_dup "CNV_id,loc,MQ,matches,PairedMates_chr,PairedMates_loc,PairedMates_MQ,InsertSize\n";
print output_id_del "CNV_id,state,length,copy_num,depth,zstat,posStart,posEnd\n";
print output_pr_del "CNV_id,loc,MQ,matches,PairedMates_chr,PairedMates_loc,PairedMates_MQ,InsertSize\n";

#$no_DUP=-1;
#$no_DEL=-1;
open(input1, "$output.$chr.distri");
while(<input1>)
{

	my @f=split /\s+/, $_;

	if (/^>/)
	{
		 $state=$f[3];
		 $length=$f[4];
		 $copyEst=$f[5];
		 $depth=$f[6];
		 $zstat=$f[7];
		 $st=$f[9];
		 $nd=$f[10];
		 $del_size=$f[4];

		 if (/state/){}
		 elsif($state==1)
		 {
		 	$no_DEL++;
		 	print output_id_del "$no_DEL,$state,$length,$copyEst,$depth,$zstat,$st,$nd\n";
		 }
		 elsif($state==3)
		 {
		 	$no_DUP++;
		 	print output_id_dup "$no_DUP,$state,$length,$copyEst,$depth,$zstat,$st,$nd\n";
		 }
		 
	}
	elsif ((($f[1]=~/r/) or ($f[1]=~/R/)))
	{
		 #if ($f[1]=~/1/)
		 {
			 $loc1=$f[3];
			 $loc2=$f[7];
			############################
			if ($f[1]=~/r/)
			{
				$dist=-$f[8];
	
			}
			if ($f[1]=~/R/)
			{
				$dist=$f[8];
			}
			#if ($dist<0){print;}
			############################
	
			$low_boundary=$st-$pair_insert_size;
			$up_boundary=$nd+$pair_insert_size;
			$MQ2=$MQ_2{"$f[0]-$f[7]"};
			#print "$state	$low_boundary	$up_boundary\n";
			if (($state==1) and ($loc1>$low_boundary) and ($loc2>$low_boundary)  and ($loc1<$up_boundary) and ($loc2<$up_boundary))
			{
	
				print output_pr_del "$no_DEL,$f[3],$f[4],$f[5],$f[6],$f[7],$f[0],$dist\n";
			}
			if ($state==3)
			{
				print output_pr_dup "$no_DUP,$f[3],$f[4],$f[5],$f[6],$f[7],$f[0],$dist\n";
			}
		}
	}
}


}
#####################################################output CNV file with reads pairs in that region###########################################################
sub output_CNV_with_pairs
{

	open(input2, "$output.$chr.rdx_raw.sum");
	open(output, ">$output.$chr.distri");
	while(<input2>)
	{
		my @f=split /\s+/, $_;
		print output ">	$_";
		my $del_size=$f[3];
		if ($f[2]==1)
		{
			for ($i=$f[8]-$pair_insert_size;$i<=$f[9]+$pair_insert_size;$i++)
			{
				if ($hash{"$f[7]-$i"} ne ''){print output $hash{"$f[7]-$i"};}
			}
		}

		if ($f[2]==3)
		{
			#print;
			for ($i=$f[8];$i<=$f[9];$i++)
			{
				if (($hash{"$f[7]-$i"} ne '')){print output $hash{"$f[7]-$i"};}
			}
		}
	}


}
#############################################read the scale of CNV into memory########################################################################
sub scale_of_CNV
{

	open(input2, "$output.$chr.rdx_raw.sum");
	while(<input2>)
	{

		my @f=split /\s+/, $_;
		my $del_size=$f[3];
		if ($f[2]==1)	###for deletion
		{
			for (my $i=$f[8]-$pair_insert_size;$i<=$f[8]+200;$i++)
			{
				$hash_cnv{"$f[7]-$i"}=1;
			}
			
			for (my $i=$f[9]-200;$i<=$f[9]+$pair_insert_size;$i++)
			{
				$hash_cnv{"$f[7]-$i"}=1;
			}
						
		}

		if ($f[2]==3)	###for duplicates
		{
			for (my $i=$f[8];$i<=$f[9];$i++)
			{
				$hash_cnv{"$f[7]-$i"}=1;
			}
		}

	}
}
##############################################collect paris that fall into CNV regions and build background dist###############################################
sub collecting_pairs_and_background_dist
{

		my @f=split /\s+/, $bam_content;	
		if (($f[1]=~/u/) or ($f[1]=~/U/)){}
		else
		{
			$loc_tag="$CHR_num-$f[3]";
			if ($f[6] eq '=')
			{
				$loc_tag_pair="$CHR_num-$f[7]";
			}
			else
			{
				$pair_chr=$f[6];
				$pair_chr=~s/chr//;
				$loc_tag_pair="$pair_chr-$f[7]";
							
			}

			
			if ($hash_cnv{$loc_tag} ne '')
			{
				$hash{$loc_tag}="$hash{$loc_tag}$_";
			}
			elsif ($hash_cnv{$loc_tag_pair} ne '')
			{
				$hash{$loc_tag_pair}="$hash{$loc_tag_pair}$_";
			}
			
			
			elsif (($background<10000) and ($f[4]>200))
			{
				$rand=rand();
				if (($rand<0.001))
				{
					$background++;
					print bg_output "$f[1],$f[2],$f[3],$f[4],$f[5],$f[6],$f[7],$f[8]\n";
				}
			}

		}



}

######################################################main process#########################################################################
sub collecting_paired_end_info
{
	$pos_file=$_[0];	###this bam file should be sorted
	$pair_insert_size=500;

	open(bg_output, ">$output.background_distribution.csv");
	
	
	
	
	
	open(input, $pos_file);


	while(<input>)
	{

		$bam_content=$_;
		@f=split /\s+/, $bam_content;
		if (!($f[2]=~/chr/)){$f[2]="chr$f[2]";}
		if ($f[2] ne $chr)
		{
			print "processing $f[2]\n";
			if ($chr ne '')
			{
				#last;			#####################################################
				&output_CNV_with_pairs;
				&formating_R;

			}
			@f=split /\s+/, $bam_content;
			if (!($f[2]=~/chr/)){$f[2]="chr$f[2]";}
			$chr=$f[2];
			$CHR_num=$chr;
			$CHR_num=~s/chr//;
			undef %hash_cnv;
			undef %hash;
			&scale_of_CNV;
		}
		&collecting_pairs_and_background_dist;

	}

	#$chr='chr1';
	&output_CNV_with_pairs;
	&formating_R;

}

1;
######################################################main process#########################################################################
