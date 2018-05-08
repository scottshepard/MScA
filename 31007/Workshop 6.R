library(dplyr)
library(ggplot2)

datapath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 6/"

trebuchetData<-read.csv(file=paste(datapath,"trebuchetdata.csv",sep="/"),header=TRUE,sep=",")
trebuchetData

nTrebData<-length(trebuchetData$distance)

trebModel<-lm(distance~projectileWt,data=trebuchetData)
summary(trebModel)

plot(trebuchetData$projectileWt,trebuchetData$distance)
lines(trebuchetData$projectileWt,trebModel$fitted.values,type="l")

anova(trebModel)

# Manually calculate SSE, SSM, F

# SSE
sse <- sum(trebModel$residuals^2)
sse

# SSM
ssm <- sum((trebModel$fitted.value - mean(trebuchetData$distance))^2)
ssm

# F-statistic
ssm / (sse / (nTrebData-2))

# SST
sst <- sum((trebuchetData$distance - mean(trebuchetData$distance))^2) 
sst

# R^2
ssm / sst

# Adjusted R^2
1 - (sse / (nTrebData-2)) / (sst / (nTrebData-1))

##############################################################################

tasteData<-read.csv(file=paste(datapath,"tastetest.csv",sep="/"),header=TRUE,sep=",")
tasteData

taste.model<-lm(score~scr,data=tasteData)
summary(taste.model)

tasteData$scr-mean(tasteData$scr)

tasteData$dummy <- as.numeric(tasteData$scr)-1



Beta0 <- sum(tasteData$score * (tasteData$dummy-mean(tasteData$dummy))) / sum((tasteData$dummy-mean(tasteData$dummy))^2)


    
c(Beta0,Beta1)
