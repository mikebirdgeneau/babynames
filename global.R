library(shiny)
library(data.table)
library(ggplot2)

library(reshape2)
library(cluster)
library(textcat)
library(wavelets)

options(stringsAsFactors = FALSE)

load("us_baby_names.Rda")
setkeyv(us_baby_names,c("Name","Gender","Year"))
us_baby_names <- unique(us_baby_names)

getCluster <- function(gender="Boy",maxRank=250,k=9){
  
  fullCluster <- dcast(melt(subset(us_baby_names[Gender==gender & Rank<=maxRank,],select=c(Year,Name,Gender,Percent)),id.vars = c("Name","Year","Gender"),variable.factor = FALSE),Name+Gender~Year ,fun.aggregate = function(x){ifelse(is.finite(mean(x,na.rm=TRUE)),mean(x,na.rm=TRUE),0)})
  
  clusterMatrix<-as.matrix(subset(fullCluster,select=-c(Name,Gender)))
  
  wtData <- NULL
  for (i in 1:nrow(clusterMatrix)) {
      a <- t(clusterMatrix[i,])[1,]
      wt <- dwt(a, filter="haar", boundary="periodic")
      wtData <- rbind(wtData, unlist(c(wt@W,wt@V[[wt@level]])))
  }
  
  cl <- clara(clusterMatrix,k = k,samples = 1000)
  cl2 <- clara(wtData,k = k, samples = 1000)
  
  fullCluster <- data.table(fullCluster)
  fullCluster[,Cluster:=cl$clustering,]
  fullCluster[,Cluster2:=cl2$clustering]
  
  result <- melt(fullCluster,id.vars = c("Name","Cluster","Cluster2","Gender"),value.factor = FALSE)
  setnames(result,c("Name","Cluster","Cluster2","Gender","Year","Percent"))
  result[,Year:=as.numeric(as.character(Year)),]
  
  return(merge(us_baby_names,subset(result,select=-c(Percent)),by=c("Name","Gender","Year")))

}