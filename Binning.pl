

sub binning
{
#assume input is already opened
open(input, $_[0]);
 #print "file: $_[0]\n";
while(<input>)
{
	#print;
	@f=split /\t/, $_;

$chr=$f[2];
$chr=~s/chr//;
if ($f[4]>=20) 
{
	$bin= int($f[3]/100)+1;
  $num{"$chr-$bin"}++;
}
	if ($chr ne $chr_last){print "obtaining window counts for Chromosome $chr\n";}
	$chr_last=$chr;
}

for ($chrom=1;$chrom<=24;$chrom++)
{
	$chr=$chrom;
	if ($chrom==23){$chr='X'}
	if ($chrom==24){$chr='Y'}
	if ($chrom==1){$end_last=int(249250621/100);}
	if ($chrom==2){$end_last=int(243199373/100);}
	if ($chrom==3){$end_last=int(198022430/100);}
	if ($chrom==4){$end_last=int(191154276/100);}
	if ($chrom==5){$end_last=int(180915260/100);}
	if ($chrom==6){$end_last=int(171115067/100);}
	if ($chrom==7){$end_last=int(159138663/100);}
	if ($chrom==8){$end_last=int(146364022/100);}								
	if ($chrom==9){$end_last=int(141213431/100);}		
	if ($chrom==10){$end_last=int(135534747/100);}	
	if ($chrom==11){$end_last=int(135006516/100);}	
	if ($chrom==12){$end_last=int(133851895/100);}	
	if ($chrom==13){$end_last=int(115169878/100);}	
	if ($chrom==14){$end_last=int(107349540/100);}						
	if ($chrom==15){$end_last=int(102531392/100);}	
	if ($chrom==16){$end_last=int(90354753/100);}		
	if ($chrom==17){$end_last=int(81195210/100);}		
	if ($chrom==18){$end_last=int(78077248/100);}		
	if ($chrom==19){$end_last=int(59128983/100);}		
	if ($chrom==20){$end_last=int(63025520/100);}	
	if ($chrom==21){$end_last=int(48129895/100);}	
	if ($chrom==22){$end_last=int(51304566/100);}		
	if ($chrom==23){$end_last=int(155270560/100);}		
	if ($chrom==24){$end_last=int(59373566/100);}		

	if ($output eq ""){
		$output = "rdxp";
	}
	open(output, ">$output.chr$chr.window100.count");
	
	for ($i=1;$i<=$end_last;$i++)
  {
  	$NUM=$num{"$chr-$i"};
  	print output "$i $NUM\n";
  }
	
}

	
}

1;

