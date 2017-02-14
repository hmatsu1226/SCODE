args <- commandArgs(trailingOnly = T)
dir <- args[1]
repnum <- as.numeric(args[2])

meanA <- as.matrix(read.table(paste(dir,"/out_1/A.txt",sep="")))
for(i in 2:repnum){
	tmp <- as.matrix(read.table(paste(dir,"/out_",i,"/A.txt",sep="")))
	meanA <- meanA + tmp
}
meanA <- meanA / repnum

write.table(meanA, paste(dir,"/meanA.txt",sep=""), sep="\t", col.names=F, row.names=F)
