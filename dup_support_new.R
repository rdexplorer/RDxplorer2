

########################################
# IMPUTS IN THE PREVIOUS VERSION
# IT IS DESIGNED TO WORK CHROMOSOME BY CHROMOSOME
#args<-commandArgs(TRUE);
#pr_file=args[1];
#id_file=args[2];
#ref_file=args[3];
#chr=args[4];
#out_file=paste(args[5],"txt",sep=".");
#Quality_cut=args[6];
########################################
options(StringsAsFactors=F)

id_file <- "dupEvents.txt" # all dup events created in PART 1
ref_file <- "insDistr.txt" # insert size of random read pairs with perfect mapping score
out_file <- "dup.pr.calls.txt" # output file need to create a name that matches the sample name 
# Quality_cut is unneccesary because we have applied it when selecting read pairs 

dup.events.all <- read.table(id_file)
references <-read.csv(ref_file,header=F) 

# find 99.8 percentile of insert size from perfected mapped random read pairs
references <- references[references[,1]< 5*median(references[,1]),1] #remove outliers
dist.ref <- quantile(abs(references),1-10/5000) 

# work chromosome by chromosome
chr.v <- paste("chr",1:22,sep="")

Result <- c()
for(chr in chr.v){
pr_file <- paste("dups_",chr,".pr",sep="") # files of read pairs for each chromosome
distances <- read.table(pr_file)
distances <- distances[,-c(1,2,11,12)]
events <- dup.events.all[dup.events.all[,2]==chr,]

# 7th and 15th columns are mapping quality scores, 
# 3rd and 11th column are mapped chromosomes, 
# 2nd and 10th columns are direction of the reads, either forward or reverse 


# quality.mapping <- distances[,7] > Quality_cut & distances[,15] > Quality_cut

#distances <- distances[quality.mapping,]

strain.consistent <- as.character(distances[,2])!=as.character(distances[,10])
chr.consistent <- as.character(distances[,3])==as.character(distances[,11])

# we want to detect the signal for tandam duplications
# mapped position of the forward read - mapped position of reverse read
pos.f <- distances[,4]
pos.f[distances[,2]=="r"] <- distances[distances[,2]=="r",12]

pos.r <- distances[,4]
pos.r[distances[,2]=="f"] <- distances[distances[,2]=="f",12]

read.length.r <- distances[,5]
read.length.r[distances[,2]=="f"] <- distances[distances[,2]=="f",13]

neg <- pos.r < pos.f
neg[!(strain.consistent & chr.consistent)] <- NA

#################################

# the greatest read count of off-chromosomes
readcount.off.max <- rep(0,length(events[,1]))

#  reads count that is off the chromosome
readcount.off.total <- rep(0,length(events[,1]))

# count reads that are mapped far away from the events on the same chromosome
dup.g1000 <- rep(0,length(events[,1]))

# read pairs in which reverse reads that are mapped on the left of the forward reads
# indicate tandom duplication
dup.neg <- rep(0,length(events[,1]))

# the off-chromosome with the most mate 
dup.off.chr <- rep("-",length(events[,1]))

dup.pass <- rep("fail",length(events[,1]));



for(i in 1:length(events[,1])){
	pos.mate <- distances[chr.consistent & distances[,1]==events[i,1],12]
	dup.g1000[i] <- sum(pos.mate < events[i,3]-1000 | pos.mate > events[i,4]+1000)
	dup.neg[i] <- sum(neg[distances[,1]==events[i,1] & chr.consistent] & pos.mate > events[i,3]-100 & pos.mate < events[i,4]+100 ,na.rm =T)	
	tt <- table(distances[distances[,1]==events[i,1] & !chr.consistent,11])
	readcount.off.max[i] <- max(tt)
	readcount.off.total[i] <- sum(tt)
        if(readcount.off.max[i] > 5 & readcount.off.max[i]/readcount.off.total[i] > 0.5){
		dup.off.chr[i] <- names(tt)[which.max(tt)]
	}
}

      pass <- (readcount.off.max > 5 & (readcount.off.max/readcount.off.total > 0.5)) | dup.neg> 5 |dup.g1000 > 5

	dup.pass[pass] <- "PASS"

	Result<-rbind(Result,cbind(events[,c(1:4,7:10)],dup.neg,dup.g1000,readcount.off.max,readcount.off.total,dup.off.chr,dup.pass));
}


write.table(Result,out_file, quote=F, row.names=FALSE,sep="\t");

