getTstat <- function(pop1,pop2){
	n1 <- length(pop1)
	n2 <- length(pop2)

	V1 <- var(pop1)
	V2 <- var(pop2)

	S <- sqrt((V1 * (n1 - 1) + V2 * ( n2 -1 ) )/(n1 + n2 -2))
	pop1Mean <- mean(pop1)
	pop2Mean <- mean(pop2)
	t <- (pop1Mean-pop2Mean)/(S*sqrt(1/n1 + 1/n2))
        (1 - pt(abs(t),n1+n2-2))*2
}
