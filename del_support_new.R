######################################
# OLD INPUT FILES FROM PREVIOUS VERSION 
#args<-commandArgs(TRUE);
#pr_file=args[1];
#id_file=args[2];
#ref_file=args[3];
#chr=args[4];
#out_file=paste(args[5],"txt",sep=".");
#Quality_cut=args[6];
###############



id_file <- "delEvents.txt"
ref_file <- "insDistr.txt"
output_file <- "del.pr.calls.txt" # output file, need add prefix for sample id


del.events.all <- read.table(id_file)

# references are distances between 50000 random pairs of reads with perfect mapping scores 
references <-read.csv(ref_file,header=F)

references <- references[references[,1]< 5*median(references[,1]),1] 

chr.v <- paste("chr",1:22,sep="")

Results <- c()
for(chr in chr.v){
pr_file <- paste("dels_",chr,".pr",sep="")
if (file.info(pr_file)$size <= 0){
	next
}
distances <- read.table(pr_file)
distances <- distances[,-c(1,2,11,12)]
events <- del.events.all[del.events.all[,2]==chr,]

# print(paste("Quality Cutoff score is set at",Quality_cut))

# 7th and 15th columns are mapping quality scores, 
# 3rd and 11th column are mapped chromosomes, 
# 2nd and 10th columns are direction of the reads, either forward or reverse 


# quality.mapping <- distances[,7] > Quality_cut & distances[,15] > Quality_cut
# Quality_cut unnecessary as we incorporate it earlier when extracting read-pairs

strain.consist <- as.character(distances[,2])!=as.character(distances[,10])
chr.consist <- as.character(distances[,3])==as.character(distances[,11])

distances <- distances[strain.consist & chr.consist,]


# the insert size is computed as 
# mapped position of the forward read - mapped position of reverse read + length of reverse read
pos.f <- distances[,4]
pos.f[distances[,2]=="r"] <- distances[distances[,2]=="r",12]

pos.r <- distances[,4]
pos.r[distances[,2]=="f"] <- distances[distances[,2]=="f",12]

read.length.r <- distances[,5]
read.length.r[distances[,2]=="f"] <- distances[distances[,2]=="f",13]

DIST <- pos.r-pos.f+read.length.r

#################################


del.support <- rep(0,length(events[,1]))
del.support2 <- rep(0,length(events[,1]))
nread <- rep(0,length(events[,1]))
p.value <- rep(0,length(events[,1]))

del.pass <- rep("fail",length(events[,1]));

# obtain 0.998 quantile
dist.ref<-quantile(abs(references),1-10/5000) # need change after new reference file 

for(i in 1:length(events[,1]))
{

        
        dist <- DIST[distances[,1]==events[i,1]]
        dist<-dist[!(is.na(dist))]
        nread[i] <- length(dist)
# del.support count the number of read-pairs that matches the size of the deletion
        del.support[i] <- sum(dist > max(dist.ref,(events[i,8]-1)*100) & dist < 
(events[i,8]+1)*100+dist.ref) 
# del.support2 count the number of read-pairs whose distance is unusally long
        del.support2[i] <- sum(dist > dist.ref & dist < (events[i,8]+1)*100+dist.ref)
        p.value[i] <- 1-pbinom(del.support2[i]-1,nread[i],10/5000)
        if ((p.value[i]<0.0001 & events[i,8]<6)  | (del.support[i]>1))
        {
        del.pass[i] <- "PASS";
        }

}

Results <-rbind(Results,cbind(events[,c(1:4,8:11)],del.support,del.support2,p.value,del.pass));
}
write.table(Results,output_file,quote=F,row.names=F, sep="\t")
