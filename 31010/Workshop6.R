suppressWarnings(library(faraway))


data( babyfood)
Boys.only.table<-as.data.frame(babyfood[1:3,1:2])
rownames(Boys.only.table)<-as.character(babyfood[1:3,4])
Boys.only.table

#1. Simple Method
#Create contingency table with total counts.
Contingency.Table<-t(Boys.only.table)
Full.Contingency.Table<-cbind(Contingency.Table,apply(Contingency.Table,1,sum))
Full.Contingency.Table<-rbind(Full.Contingency.Table,apply(Full.Contingency.Table,2,sum))
Full.Contingency.Table

#Calculate mean values for each cell.
(Contingency.Table.Means<-t(outer(Full.Contingency.Table[3,1:3],Full.Contingency.Table[1:2,4]))/
    Full.Contingency.Table[3,4])
#Check how the mean values are calculated.
sum(Full.Contingency.Table[1,1:3])*sum(Full.Contingency.Table[1:2,1])/Full.Contingency.Table[3,4]

#To test the null H0 : “There is no difference between factors” calculate the Chi-Square statistic and its p-value.
Chi.Sq.Statistic<-sum((Contingency.Table-Contingency.Table.Means)^2/Contingency.Table.Means)
Chi.Sq.Statistic

1-pchisq(Chi.Sq.Statistic,2)
# Reject the null

Contingency.Table-Contingency.Table.Means

#2. Binomial Regression
#Fit null binomial regression model
(Binomial.Model.Data<-as.data.frame(cbind(Boys.only.table,food=rownames(Boys.only.table))))


Boys.binomial.model.null<-glm(as.matrix(Binomial.Model.Data[,1:2])~1,family=binomial,data=Binomial.Model.Data)
summary(Boys.binomial.model.null)

#What data the model fits when we give it contingency table?
Boys.binomial.model.null$y
