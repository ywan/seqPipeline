#! usr/bin/Rscript
args<-commandArgs(TRUE)
input=args[1]
output=args[2]

genes<-read.table(input,header=T)
rownames(genes)<-genes[,1]
genes<-genes[,-1]
log2Counts<-log((genes+1)/(genes[,1]+1))
log2Counts<-round(log2Counts,digits=2)
write.table(log2Counts,file=output,quote=F, sep="\t",col.names=NA)
