args <- commandArgs(trailingOnly = T)
fdata <- args[1]
ftime <- args[2]
dir <- args[3]
fout <- args[4]
tfnum <- as.numeric(args[5])
pnum <- as.numeric(args[6])
cnum <- as.numeric(args[7])

X <- as.matrix(read.table(fdata, sep="\t"))[1:tfnum,1:cnum]
W <- as.matrix(read.table(paste(dir,"/W.txt",sep="")))
Z <- matrix(rep(0,pnum*cnum), nrow=pnum, ncol=cnum)
WZ <- matrix(nrow=tfnum, ncol=cnum)
B <- read.table(paste(dir,"/B.txt",sep=""))

pseudotime <- read.table(ftime, sep="\t")[1:cnum,2]
pseudotime <- pseudotime/max(pseudotime)

sample_Z <- function(){
	for(i in 1:pnum){
		for(j in 1:cnum){
			Z[i,j] <<- exp(B[i,i]*pseudotime[j]) + runif(1, min=-0.001, max=0.001)
		}
	}
}

sample_Z()
for(i in 1:tfnum){
	WZ[i,] <- W[i,] %*% Z
}

RSS <- sum((X-WZ)**2)
write.table(RSS, fout, row.names=F, col.names=F, sep="\t")
