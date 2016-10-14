args <- commandArgs(trailingOnly = T)
finit <- args[1]
fA <- args[2]
fout <- args[3]
tfnum <- as.integer(args[4])

init <- as.matrix(read.table(finit, sep="\t"))[1:tfnum,2]

A <- as.matrix(read.table(fA, sep="\t"))
tmp <- eigen(A)
U <- tmp$vectors
invU <- solve(U)
l <- tmp$values

mean <- matrix(nrow=tfnum, ncol=101)

tmpt <- (0:100)*0.01
for(i in 1:length(tmpt)){
	t <- tmpt[i]
	eAt <- Re(U %*% diag(exp(l*t)) %*% invU)
	mean[,i] <- eAt %*% init
}

write.table(rbind(tmpt, mean), fout, sep="\t", col.names=F, row.names=F)
