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

#mx <- 1 - mx

heatmap.2(as.matrix(mx),scale="none",trace="none",Rowv=FALSE,Colv=FALSE)

pdf("hm1.pdf")

heatmap.2(as.matrix(mx),scale="none",trace="none",
  Rowv=FALSE,Colv=FALSE, dendrogram="none",
  cexCol=0.6,cexRow=0.5,margin=c(8,5))

dev.off()
