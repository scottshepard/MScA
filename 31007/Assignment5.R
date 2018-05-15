library(dplyr)
library(ggplot2)

datapath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 5"

dat<-read.csv(file=paste(datapath,"ResidualAnalysisProjectData_2.csv",sep="/"),header=TRUE,sep=",")
head(dat)

plot(dat$Input,dat$Output, type="p",pch=19)

m1<-lm(Output~Input,dat)
m1$coefficients
matplot(dat$Input,cbind(dat$Output,m1$fitted.values),type="p",pch=16,ylab="Sample and Fitted Values")

estimatedResiduals<-m1$residuals
plot(dat$Input,estimatedResiduals)

Train.Sample<-data.frame(trainInput=dat$Input,trainOutput=rep(NA,nSample))
Train.Sample.Steeper<-data.frame(trainSteepInput=dat$Input,
                                 trainSteepOutput=rep(NA,nSample))  
Train.Sample.Flatter<-data.frame(trainFlatInput=dat$Input,
                                 trainFlatOutput=rep(NA,nSample))  


head(cbind(dat,
           Train.Sample,
           Train.Sample.Steeper,
           Train.Sample.Flatter))

Train.Sample.Selector<-dat$Input>=5
Train.Sample.Steeper.Selector<-Train.Sample.Selector&
  (dat$Output>m1$fitted.values)
Train.Sample.Flatter.Selector<-Train.Sample.Selector&
  (dat$Output<=m1$fitted.values)

Train.Sample[Train.Sample.Selector,2]<-dat[Train.Sample.Selector,2]
Train.Sample.Steeper[Train.Sample.Steeper.Selector,2]<-dat[Train.Sample.Steeper.Selector,2]
Train.Sample.Flatter[Train.Sample.Flatter.Selector,2]<-dat[Train.Sample.Flatter.Selector,2]

head(cbind(dat,
           Train.Sample,
           Train.Sample.Steeper,
           Train.Sample.Flatter),10)

plot(Train.Sample$trainInput,Train.Sample$trainOutput,pch=16,ylab="Training Sample Output",
     xlab="Training Sample Input")
points(Train.Sample.Steeper$trainSteepInput,Train.Sample.Steeper$trainSteepOutput,pch=20,col="green")
points(Train.Sample.Flatter$trainFlatInput,Train.Sample.Flatter$trainFlatOutput,pch=20,col="blue")

Train.Sample.Steep.lm <- lm(trainSteepOutput ~ trainSteepInput, data=Train.Sample.Steeper[!is.na(Train.Sample.Steeper$trainSteepOutput),])
Train.Sample.Flat.lm <- lm(trainFlatOutput ~ trainFlatInput, data=Train.Sample.Flatter[!is.na(Train.Sample.Flatter$trainFlatOutput),])

plot(dat$Input,dat$Output, type="p",pch=19)
lines(dat$Input,predict(Train.Sample.Steep.lm,
                        data.frame(trainSteepInput=dat$Input),
                        interval="prediction")[,1],col="red",lwd=3)
lines(dat$Input,predict(Train.Sample.Flat.lm,data.frame(trainFlatInput=dat$Input),
                        interval="prediction")[,1],col="green",lwd=3)


################ Test Portion ################

dat <- read.table(paste(datapath,'Week5_Test_Sample.csv',sep = '/'), header=TRUE)
plot(dat$Input,dat$Output, type="p",pch=19)
m1<-lm(Output~Input,dat)
m1$coefficients
matplot(dat$Input,cbind(dat$Output,m1$fitted.values),type="p",pch=16,ylab="Sample and Fitted Values")


dat$fitted <- m1$fitted.values
ggplot(dat, aes(x=Input, y=Output)) + geom_point() + 
  geom_line(aes(y=fitted), color='red')

estimatedResiduals<-m1$residuals
plot(dat$Input,estimatedResiduals)
dat$parabola <- (dat$Output-mean(dat$Output))^2
dat$clusteringParabola <- (m1$fitted.values - mean(m1$fitted.values))^2

plot(dat$Input, dat$parabola, type="p",pch=19,
     ylab="Squared Deviations")
points(dat$Input, dat$clusteringParabola,pch=19,col="red")

dat$seperator <- dat$clusteringParabola > dat$parabola

ggplot(dat, aes(x=Input, y=parabola, color=seperator)) + geom_point()


ggplot(dat, aes(x=Input, y=Output, color=seperator)) + geom_point()

mFlat <- lm(Output ~ Input, data=dat[dat$seperator,])
dat[dat$seperator, 'fitted2'] <- mFlat$fitted.values

mSteep <- lm(Output ~ Input, data=dat[!dat$seperator,])
dat[!dat$seperator, 'fitted2'] <- mSteep$fitted.values

ggplot(dat, aes(x=Input, y=Output)) + geom_point() + 
  geom_line(aes(y=fitted2, color=seperator))

df <- data.frame(Input=dat$Input, Output=predict(mFlat, data.frame(dat$Input)))

res <- list( GeneralModel = m1, mSteep = mSteep, mFlat = mFlat)
saveRDS(res, file = paste(datapath,'result.rds',sep = '/'))
