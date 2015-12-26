
library(reshape2)
library(cluster)
library(textcat)

fullCluster <- dcast(melt(subset(us_baby_names[Gender=="Boy" & Rank<=250,],select=c(Year,Name,Percent)),id.vars = c("Name","Year")),Name~Year ,fun.aggregate = function(x){ifelse(is.finite(mean(x,na.rm=TRUE)),mean(x,na.rm=TRUE),0)})

clusterMatrix<-as.matrix(subset(fullCluster,select=-c(Name)))

cl <- clara(clusterMatrix,k = 9,samples = 1000)

fullCluster <- data.table(fullCluster)
fullCluster[,Cluster:=cl$clustering,]

result <- melt(fullCluster,id.vars = c("Name","Cluster"))
setnames(result,c("Name","Cluster","Year","Percent"))

ggplot(result,aes(x=Year,y=Percent,group=Name))+geom_line()+facet_wrap(~Cluster,scales = "free_y")
