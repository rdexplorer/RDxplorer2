event2tristate <- function(ewtShort,chrLength){
	ewtLong <-  rep(0,chrLength)
	for(i in 1:dim(ewtShort)[1]) {
		if(ewtShort[i,3]>0) ewtLong[ewtShort[i,1]:ewtShort[i,2]] <- 1
		if(ewtShort[i,3]<0) ewtLong[ewtShort[i,1]:ewtShort[i,2]] <- -1
	}
	ewtLong
}
