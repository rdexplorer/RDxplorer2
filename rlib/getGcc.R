getGcc <- function(count,gc,gapProbes){
  noGapProbes <- c(1:length(count))[-gapProbes]
  cat(paste("noGapProbes", noGapProbes[1:10], '\n'))

 
  gcNoGap <- gc[-gapProbes]
  gcRange <- sort(unique(gcNoGap))
  cat(paste("gcNoGap", gcNoGap[1:10], '\n'))

  countNoGap <- count[-gapProbes]
  cat(paste("countNoGap", countNoGap[1:10], '\n'))
  mediansByGc <- rep(NA,length(gcRange))
  countMedian <- median(countNoGap)
  cat(paste("countMedian", countMedian, '\n'))
  countNoGapGCC <- countNoGap
  cat(paste("countNoGapGCC", countNoGapGCC[1:10], '\n'))

  for(i in 1:length(gcRange)){
    probes <- which(gcNoGap==gcRange[i])
    cat(paste("gcRange[i]", gcRange[i], '\n'))
    cat(paste("probes", probes[1:10], '\n'))
    counts <- countNoGap[probes]
    cat(paste("counts", counts[1:10], '\n'))
    m <- median(counts)
    #cat(paste("m ", m, '\n'))

    if(m==0) m <- 1
    countNoGapGCC[probes] <- counts/m*countMedian
  }
  countGcc <- count
  countGcc[noGapProbes] <- countNoGapGCC
  countGcc
}
