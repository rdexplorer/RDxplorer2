args<-commandArgs(TRUE);

apphome <- args[1]
wrkgdir <- args[2]
print (wrkgdir);
chromosomes <- paste("chr",c(1:22,"X","Y"),sep="")
source(paste(apphome,"/rlib/ewtMain.R",sep=""))

######

for(chr in chromosomes)
#chr="chr1";
{
	filename.0 <- paste(wrkgdir,".",chr,".window100.count",sep="")
	outputfile <- paste(wrkgdir,".",chr,".rdx_raw",sep="")
	#filename.2 <- paste(wrkgdir,".",chr,".window.100",sep="")
#	temp <- read.table(filename.0,sep=" ")
#	temp[is.na(temp[,2]),2] <- 0
	#write(temp[,2],filename.2)

	runEwtMain(apphome, outputfile,filename.0,chr,"hg19",100)
}
