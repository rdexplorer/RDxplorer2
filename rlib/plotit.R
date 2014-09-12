
plotit<-function(wrkgdir, nzd, summary, chr, filter=0, dirsep='/'){
copy <- rep(2,length(nzd))
for(i in 1:dim(summary)[1]) {
    copy[summary$segStart[i]:summary$segEnd[i]] <- summary$segMedian[i]
}

nhd <- 50

## if user provides no filter, use default, which is 10
if (filter < 1){
    filter = 10
}
summary <- summary[which(summary$length>=filter),]

plotname<-paste(wrkgdir, dirsep, chr,".pdf",sep="")
pdf(plotname)
#rows <- c(2,11,21,32,35,41)
rows<-c(1)
if(dim(summary)[1]>6) {
    rows <- sort(sample(dim(summary)[1],6))
}
else {
    rows <- sort(sample(dim(summary)[1],6,replace=T))
}

par(mfrow=c(3,2))
for(i in 1:6){
    cat(i," ")
  seg <- (summary$segStart[rows[i]]-nhd):(summary$segEnd[rows[i]]+nhd)
  plot(seg*100,nzd[seg],xlab="chrom pos",ylab="normalized RD",ylim=c(0,15))
  points(seg*100-99,copy[seg],type="l",col="green")
  abline(2,0)
}
dev.off()
}
