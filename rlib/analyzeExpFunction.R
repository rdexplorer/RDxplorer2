## exp - double[] numeric data (read depth, ratio, etc)
## lower, upper - thresholds
getGenotypeGenomewideVer3 <- function(exp,lower,upper){
	callOut <- rep(0,length(exp))
        callOut[which(exp >= upper)] <- 1
        callOut[which(exp <= lower)] <- -1
	## returns integer [] of the same length
	callOut
}

##
##
getShortTable <- function(exp,lower,upper,minLength){
	genotype  <- getGenotypeGenomewideVer3(exp,lower,upper)
	rare <- rep(0,length(genotype))
	rare[which(genotype > 0)] <- 1
	rare[which(genotype < 0)] <- -1
	short.place.start <- c(1, (which(rare[-1] - rare[ - length(rare)] != 0) + 1))
	short.place.end   <- c(short.place.start[-1] - 1, length(rare))
	short <- rare[short.place.start]	#
	short.table <- data.frame(seg.start = as.integer(short.place.start), seg.end = 	as.integer(short.place.end), genotype = short)
	short.table$length <- as.integer(short.table$seg.end - short.table$seg.start + 1)
	short.table[which(short.table$seg.end - short.table$seg.start + 1 >= minLength & short.table$genotype != 0),]
}

##
## exp double[] for one chromosome
## popSize = 2
## FPR (false positive rate) conventionally = 0.05

analyzeExpChr <- function(exp,popSize,degree=0.75,FPR=0.05,chrSize=NULL){
	if(length(chrSize)==0) chrSize <- length(exp)
	nVector <- 1:100
	qVector <- rep(NA,100)
	for(n in 1:100) qVector[n] <- (FPR/(chrSize/n))^(1/n)
	qTable <- data.frame(n=nVector,lower=qVector,upper=1-qVector)
	depth 	<- max(which(qTable$lower < degree))
	exp 	<- (exp-1)/(popSize-1)
	genoPositive <- rep(0,length(exp))
	genoNegative <- rep(0,length(exp))
	for(i in depth:2){
		out	<- getShortTable(exp,lower=qTable$lower[i],upper=qTable$upper[i],minLength=qTable$n[i])
		if(dim(out)[1] > 0){
			geno <- rep(0,length(exp))
			shortTable <- out
			for(j in 1:dim(shortTable)[1]){
				if(shortTable$genotype[j]>0) genoPositive[shortTable$seg.start[j]:shortTable$seg.end[j]] <- qTable$upper[i]
				if(shortTable$genotype[j]<0) genoNegative[shortTable$seg.start[j]:shortTable$seg.end[j]] <- qTable$upper[i]
			}
		}
	}
	geno <- rep(0,length(exp))
	geno[which(genoPositive>0)] <- genoPositive[which(genoPositive>0)]
	geno[which(genoNegative>0)] <- (-1)*genoNegative[which(genoNegative>0)]
	short.place.start <- c(1, (which(geno[-1] - geno[ - length(geno)] != 0) + 1))
	short.place.end   <- c(short.place.start[-1] - 1, length(geno))
	short <- geno[short.place.start]
	short.table <- data.frame(seg.start = as.integer(short.place.start),seg.end = as.integer(short.place.end), genotype = short)
	short.table$length <- as.integer(short.table$seg.end - short.table$seg.start + 1)
	##
	short.table
}
