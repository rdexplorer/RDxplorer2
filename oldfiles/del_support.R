args<-commandArgs(TRUE);


pr_file=args[1];
id_file=args[2];
ref_file=args[3];
chr=args[4];
out_file=paste(args[5],"txt",sep=".");
#cat(pr_file);
###############
#pr_file="LP6005162-DNA_B01.rdxp.chr12.pr_del";
#id_file="LP6005162-DNA_B01.rdxp.chr12.id_del";
#ref_file="LP6005162-DNA_B01.rdxp.background_distribution.csv";
#out_file="LP6005162-DNA_B01.rdxp.chr12.id_del.csv";
#chr="chr12";
###############
distances<-read.csv(pr_file,header=T);
events<-read.csv(id_file,header=T);


valid.pair <- distances[,3]> 200 & distances[,7]>200 & distances[,5] == "="
reference<-read.csv(ref_file,header=F)
#################################


del.support <- rep(0,length(events[,1]))
del.support2 <- rep(0,length(events[,1]))
nread <- rep(0,length(events[,1]))
p.value <- rep(0,length(events[,1]))
chrom <- rep(chr,length(events[,1]))

del.pass <- rep("fail",length(events[,1]));

dist_ref<-quantile(abs(reference[,8]),1-10/5000)

for(i in 1:length(events[,1]))
{
  #i=1;
	dist <- distances[distances[,1]==events[i,1] & valid.pair,8]
	dist<-dist[!(is.na(dist))]#######################################################################
	nread[i] <- length(dist)
	del.support[i] <- sum(dist > max(600,(events[i,3]-1)*100) & dist < events[i,3]*100+700) 
	del.support2[i] <- sum(dist > dist_ref & dist < events[i,3]*100+700)
	p.value[i] <- 1-pbinom(del.support2[i]-1,nread[i],10/5000)
	if ((p.value[i]<0.0001) | (del.support[i]>3))
	{
	del.pass[i]="PASS";
	}

}

Result<-1;
Result<-cbind(chrom,events,del.support,del.support2,p.value,del.pass);
write.table(Result,out_file, row.names=FALSE,sep="\t");
