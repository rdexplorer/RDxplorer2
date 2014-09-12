getGapProbes <- function(apphome, chr, hg, win){
    gap <- read.table(paste(apphome, "/rlib/gap","_", hg,"/",chr,"_gap.txt",sep=""),as.is=T,header=F)[,3:4]
    gap[,1] <- as.integer((gap[,1]-1)/win)+1
    gap[,2] <- as.integer((gap[,2]-1)/win)+1
    gapProbes <- NULL
    for(i in 1:dim(gap)[1]) gapProbes <- c(gapProbes,c(gap[i,1]:gap[i,2]))
    gapProbes
}
