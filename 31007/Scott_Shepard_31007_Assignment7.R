datapath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 7/"

Regression.ANOVA.Data <- read.csv(file=paste(datapath,"DataForRegressionANOVA.csv",sep="/"),header=TRUE,sep=",")
head(Regression.ANOVA.Data)

fit.1<-lm(Output~1,data=Regression.ANOVA.Data)
fit.1.2<-lm(Output~1+Input1,data=Regression.ANOVA.Data)
fit.1.3<-lm(Output~1+Input2,data=Regression.ANOVA.Data)
fit.1.2.3<-lm(Output~.,data=Regression.ANOVA.Data)

anova(fit.1.2)



# Test
dataPath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 7/"
test_dat <- read.table(paste(dataPath,'Week7_Test_Sample.csv',sep = '/'), header=TRUE)


fit.1<-lm(Output~1,data=test_dat)
fit.1.2<-lm(Output~1+Input1,data=test_dat)
fit.1.3<-lm(Output~1+Input2,data=test_dat)
fit.1.2.3<-lm(Output~.,data=test_dat)

anova(fit.1, fit.1.2)
anova(fig.1.3)$"Sum Sq"
