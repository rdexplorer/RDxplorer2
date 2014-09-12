
getSummary <- function(apphome, nzd,copy2nzd,copyLong,chr,baseCopy=2){

  source(paste (apphome, "/rlib/getShortFunction.R", sep=''))
  source(paste (apphome, "/rlib/combineNeighborsBy5simple.R", sep=''))

  if(length(which(copyLong>baseCopy)>0)){
    dupLong <- rep(baseCopy,length(copyLong))
    dupLong[which(copyLong>baseCopy)] <- baseCopy+1
    dupShort <- getShort(dupLong)
    dupShort <- dupShort[which(dupShort$state>baseCopy),]
    dupShort <- combineNeighborsBy5(dupShort)
  }else{
    dupShort <- NULL
  }
  if(length(which(copyLong<baseCopy)>0)){
    delLong <- rep(baseCopy,length(copyLong))
    delLong[which(copyLong<baseCopy)] <- baseCopy-1
    delShort <- getShort(delLong)
    delShort <- delShort[which(delShort$state<baseCopy),]
    delShort <- combineNeighborsBy5(delShort)
  }else{
    delShort <- NULL
  }
  stateLong <- rep(baseCopy,length(copyLong))
  if(length(dupShort)>0) for(i in 1:dim(dupShort)[1]) stateLong[dupShort$seg.start[i]:dupShort$seg.end[i]] <- baseCopy+1
  if(length(delShort)>0) for(i in 1:dim(delShort)[1]) stateLong[delShort$seg.start[i]:delShort$seg.end[i]] <- baseCopy-1
  stateShort <- getShort(stateLong)
  if(dim(stateShort)[1]>1){
    stateShort <- stateShort[which(stateShort$state!=baseCopy),]
    stateShort$length <- stateShort$seg.end-stateShort$seg.start+1

    popMean <- mean(copy2nzd); popVariance <- var(copy2nzd)
    copyEst <- rep(NA,dim(stateShort)[1]); seg.median <- rep(NA,dim(stateShort)[1]); zstat <- rep(NA,dim(stateShort)[1])
    for(i in 1:dim(stateShort)[1]){
      nzdSeg <- nzd[stateShort$seg.start[i]:stateShort$seg.end[i]]
      copyEst[i] <- round(median(nzdSeg))
      seg.median[i] <- median(nzdSeg)
      zstat[i] <- (mean(nzdSeg)-popMean)/sqrt(popVariance/length(nzdSeg))
    }
    stateShort$copyEst <- copyEst; stateShort$seg.median <- seg.median; stateShort$zstat <- zstat

    #stateShort$chrom <- rep(as.integer(chr),dim(stateShort)[1])
    stateShort$chrom <- rep(chr,dim(stateShort)[1])
    stateShort$chrom.pos.start <- stateShort$seg.start*100-99
    stateShort$chrom.pos.end   <- stateShort$seg.end*100
    stateShort <- stateShort[which(abs(stateShort$zstat)>-qnorm(0.05) & stateShort$copyEst!=baseCopy),]
  }
  stateShort
}
