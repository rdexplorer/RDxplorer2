args<-commandArgs(TRUE);


pr_file=args[1];
id_file=args[2];
ref_file=args[3];
chr=args[4];
out_file=paste(args[5],"txt",sep=".");
Quality_cut=args[6];


###############
#pr_file="LP6005162-DNA_B01.rdxp.chr1.pr_dup.new";
#id_file="LP6005162-DNA_B01.rdxp.chr1.id_dup";
#ref_file="LP6005162-DNA_B01.rdxp.background_distribution.csv";
#out_file="LP6005162-DNA_B01.rdxp.chr1.id_dup.csv";
#chr="chr1";




distances.dup<-read.csv(pr_file);
dup.events<-read.csv(id_file);

valid.pair.dup <- distances.dup[,3] > Quality_cut & distances.dup[,7] > Quality_cut 


readcount.off.max <- rep(0,length(dup.events[,1]))
readcount.off.total <- rep(0,length(dup.events[,1]))
dup.g1000 <- rep(0,length(dup.events[,1]))
dup.neg <- rep(0,length(dup.events[,1]))
dup.off.chr <- rep("-",length(dup.events[,1]))
chrom <- rep(chr,length(dup.events[,1]));
dup.pass <- rep("fail",length(dup.events[,1]));



for(i in 1:length(dup.events[,1])){
	dist <- distances.dup[distances.dup[,1]==dup.events[i,1] & valid.pair.dup & distances.dup[,5]=="=",8]
	dupsize <- dup.events[i,3]*100
	dup.g1000[i] <- sum(abs(dist)> max(1000,dupsize))
	dup.neg[i] <- sum(dist > -dupsize & dist < 0)	
	tt <- table(distances.dup[distances.dup[,1]==dup.events[i,1] & valid.pair.dup & distances.dup[,5]!="=",5])
	readcount.off.max[i] <- max(tt)
	readcount.off.total[i] <- sum(tt)
}

for(i in which(readcount.off.max > 5 & readcount.off.max/readcount.off.total > 0.5 & dup.events[,4]<10))
{
	tt <- table(distances.dup[distances.dup[,1]==dup.events[i,1] & valid.pair.dup & distances.dup[,5]!="=",5])
	dup.off.chr[i]=names(tt)[which.max(tt)];
	#print(list(i,names(tt)[which.max(tt)],readcount.off.max[i],readcount.off.total[i]))
}

for(i in 1:length(dup.events[,1]))
{
	if (readcount.off.max[i] > 5 & readcount.off.max[i]/readcount.off.total[i] > 0.5 & dup.events[i,4]<10)
	{dup.pass[i]="pass"}
	
	if (dup.neg[i] > 5 & dup.events[i,4] < 10)
	{dup.pass[i]="pass"}
	
	if (dup.g1000[i] > 5 & dup.events[i,4] < 10)
	{dup.pass[i]="pass"}
	
}
Result<-1;
Result<-data.frame(dup.neg,dup.g1000,readcount.off.max,dup.off.chr,readcount.off.total);
Result<-data.frame(chrom,dup.events,Result,dup.pass);


write.table(Result,out_file, row.names=FALSE,sep="\t");
