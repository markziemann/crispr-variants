library(plyr)
library(gplots)


# R1A: gRNA1
# R2A: No gRNA control
# R2B: gRNA2
# WT: wild type.

files <- list.files(".",pattern="out$")
mynames <- gsub("-Amplicon","@",files)
mynames <- sapply(strsplit(mynames,"@"),"[[",1)


myfun <- function(i) {
  file <- files[i]
  x <- read.table(file)
  x$frac <- x$V5/x$V4
  x <- x[,c("V2","frac")]
  return(x)
}



l <- lapply(1:length(files),myfun)
mx <- join_all(l,by="V2",type="inner")
rownames(mx) <- mx$V2
mx$V2 = NULL
colnames(mx) <- mynames

ss <- mx[which(apply(mx,1,mean) < 0.99),]

pdf("res.pdf")

heatmap.2(as.matrix(mx),scale="none",trace="none",
  Rowv=FALSE,Colv=FALSE, dendrogram="none",
  cexCol=0.6,cexRow=0.5,margin=c(8,5))

par(mar=c(5,10,3,1))

barplot(unlist(as.vector(ss[1,,drop=TRUE])),horiz=TRUE,las=1,cex.names=0.6,main="286",xlim=c(0,0.5))

barplot(unlist(as.vector(ss[2,,drop=TRUE])),horiz=TRUE,las=1,cex.names=0.6,main="420",xlim=c(0,0.5))

barplot(unlist(as.vector(ss[3,,drop=TRUE])),horiz=TRUE,las=1,cex.names=0.6,main="437",xlim=c(0,0.5))

dev.off()

