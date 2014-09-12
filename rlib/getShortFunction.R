getShort <- function(rare){
	short.place.start <- c(1, (which(rare[-1] - rare[ - length(rare)] != 0) + 1))
	short.place.end <- c(short.place.start[-1] - 1, length(rare))
	data.frame(seg.start = as.integer(short.place.start),
		seg.end = as.integer(short.place.end), state = rare[
		short.place.start])
}
