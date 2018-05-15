library(faraway)

coagulation
plot(coag~diet, data=coagulation, pch=19,col="black")

summaryByGroup<-aggregate(coag~diet,data=coagulation,FUN=summary)
means<-cbind(Means=summaryByGroup$coag[,4],Sizes=aggregate(coag~diet,data=coagulation,FUN=length)$coag)
rownames(means)<-as.character(summaryByGroup$diet)
means

model <- lm(coag~diet, data=coagulation)
modelSummary <- summary(model)
modelANOVA <- anova(model)

modelSummary$coefficients

# Test
dataPath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 8"
test_dat <- read.table(paste(dataPath,'Week8_Test_Sample.csv',sep = '/'), header=TRUE)

fit.1 <- lm(Output ~ Treatment, data=test_dat) # utility test
fit.2 <- lm(Output~Treatment-1, data=test_dat) # compare to 0 test

anova(fit.1)
anova(fit.2)
