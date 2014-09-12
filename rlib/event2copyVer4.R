
event2copy <- function(apphome, ewtShort,nzd,popMean,popVariance,baseCopy=2){
  source(paste (apphome, "/rlib/getShortFunction.R", sep=''))
  ewtDup <- ewtShort[which(ewtShort[,3]>0),]
  ewtDel <- ewtShort[which(ewtShort[,3]<0),]
  if(dim(ewtDup)[1]>0){
    ewtDupLong <- rep(baseCopy,length(nzd))
    for(i in 1:dim(ewtDup)[1]) ewtDupLong[ewtDup[i,1]:ewtDup[i,2]] <- as.integer(round(median(nzd[ewtDup[i,1]:ewtDup[i,2]])))
    ewtDupShort <- getShort(ewtDupLong)
    ewt3Short <- ewtDupShort[which(ewtDupShort[,3]==baseCopy+1),]
    ewtHighShort <- ewtDupShort[which(ewtDupShort[,3]>=baseCopy+2),]
  }else{
    ewt3Short <- NULL
    ewtHighShort <- NULL
  }
  if(dim(ewtDel)[1]>0){
    ewtDelLong <- rep(baseCopy,length(nzd))
    for(i in 1:dim(ewtDel)[1]) ewtDelLong[ewtDel[i,1]:ewtDel[i,2]] <- as.integer(round(median(nzd[ewtDel[i,1]:ewtDel[i,2]])))
    ewtDelShort <- getShort(ewtDelLong)
    ewt1Short <- ewtDelShort[which(ewtDelShort[,3]==baseCopy-1),]
    ewt0Short <- ewtDelShort[which(ewtDelShort[,3]==baseCopy-2),]
  }else{
    ewt1Short <- NULL
    ewt0Short <- NULL
  }
  ewtLong <-  rep(baseCopy,length(nzd))
  if(length(ewt3Short)>0) if(dim(ewt3Short)[1]>0)
    for(i in 1:dim(ewt3Short)[1]) ewtLong[ewt3Short[i,1]:ewt3Short[i,2]] <- baseCopy+1
  if(length(ewtHighShort)>0) if(dim(ewtHighShort)[1]>0)
    for(i in 1:dim(ewtHighShort)[1]) ewtLong[ewtHighShort[i,1]:ewtHighShort[i,2]] <- as.integer(round(median(nzd[ewtHighShort[i,1]:ewtHighShort[i,2]])))
  if(length(ewt1Short)>0) if(dim(ewt1Short)[1]>0)
    for(i in 1:dim(ewt1Short)[1]){
      seg    <- ewt1Short[i,1]:ewt1Short[i,2]
      dupSeg <- seg[which(ewtLong[seg] > baseCopy)]
      ewtLong[setdiff(seg,dupSeg)] <- baseCopy-1
    }
  if(length(ewt0Short)>0) if(dim(ewt0Short)[1]>0)
    for(i in 1:dim(ewt0Short)[1]){
      seg    <- ewt0Short[i,1]:ewt0Short[i,2]
      dupSeg <- seg[which(ewtLong[seg] > baseCopy)]
      ewtLong[setdiff(seg,dupSeg)] <- baseCopy-2
    }
  ewtShort <- getShort(ewtLong)
  zstat    <- rep(0,length(nzd))
  copy <- rep(baseCopy,length(nzd))
  for(i in 1:dim(ewtShort)[1]){
    seg <- ewtShort[i,1]:ewtShort[i,2]
    zstat[seg] <- (mean(nzd[seg])-popMean)/sqrt(popVariance/(ewtShort[i,2]-ewtShort[i,1]+1))
    copy[seg] <- ewtShort[i,3]
  }
  data.frame(copy=copy,zstat=zstat)
}
