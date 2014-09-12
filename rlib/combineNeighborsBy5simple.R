combineNeighborsBy5 <- function(short){
j <- 0
nextConnected <- which(
short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 1 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 2 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 3 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 4 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 5 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 6 == short$seg.start[-c(1:(j+1))]
)
if(length(nextConnected) > 0) short$seg.end[nextConnected] <- short$seg.end[nextConnected+1]
nextConnectedIni <- nextConnected
for(j in 1:min(100,(dim(short)[1]-1))){
#j <- 12
nextConnected <- which(
short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 1 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 2 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 3 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 4 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 5 == short$seg.start[-c(1:(j+1))]
|short$seg.end[-c((dim(short)[1]-j):dim(short)[1])] + 6 == short$seg.start[-c(1:(j+1))]
)
if(length(nextConnected) > 0) short$seg.end[nextConnected] <- short$seg.end[nextConnected+1]
}
if(length(nextConnectedIni) > 0) short <- short[-c(nextConnectedIni + 1),]
short
}

