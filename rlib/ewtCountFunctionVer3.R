# output: a short table

ewt <- function(apphome, count,gapProbes=NULL,FPRInput=0.05,degreeInput=0.5){
  source(paste (apphome, "/rlib/analyzeExpFunction.R", sep=''))
  if(length(gapProbes)>0){
    countNoGap <- count[-gapProbes]
    ftd <- countNoGap[which(countNoGap<2*median(countNoGap))]
    m <- mean(ftd); sd <- sqrt(var(ftd))
  }else{
    ftd <- count[which(count<2*median(count))]
    m <- mean(ftd); sd <- sqrt(var(ftd))
  }
  zscore <- (count-m)/sd
  subChrOut <- analyzeExpChr(exp=pnorm(zscore)+1,popSize=2,degree=degreeInput,FPR=FPRInput)
  subChrOut
}
