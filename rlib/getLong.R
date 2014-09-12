getLong <- function(short,size,default=NA){
	long <- rep(default,size)
	for(i in 1:dim(short)[1]) long[short[i,1]:short[i,2]] <- short[i,3]
	long
}

