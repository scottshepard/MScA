rm(list=ls())

library(dplyr)
library(ggplot2)

## 1. Separate mixed samples of linear model data using logistic regression

datapath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 6/"

LinearModel.Training<-read.csv(file=paste(datapath,'ResidualAnalysisProjectData_1_Train.csv',sep="/"),
                               header=TRUE,sep=",")
LinearModel.Training$Model.Switch <- factor(LinearModel.Training$Model.Switch)

nSample.Training<-length(LinearModel.Training[,1])
head(LinearModel.Training)

ggplot(LinearModel.Training, aes(x=Input, y=Output, color= Model.Switch)) + geom_point()

EstimatedLinearModel.Training <- lm(Output ~ Input, data=LinearModel.Training)
LinearModel.Training$Residuals <- EstimatedLinearModel.Training$residuals

ggplot(LinearModel.Training, aes(x=Input, y=Residuals, color=Model.Switch)) + geom_point()

# Logistic regression
Logistic.Model.Data <- LinearModel.Training
Logistic.Model.Data <- Logistic.Model.Data %>% 
  mutate(Logistic.Output = Model.Switch, Logistic.Input = Residuals)

LinearModel.Training.Logistic<-glm(Logistic.Output~Logistic.Input,data=Logistic.Model.Data,
                                   family=binomial(link=logit))

summary(LinearModel.Training.Logistic)

Logistic.Model.Data$Predicted<-predict(LinearModel.Training.Logistic,type="response")

ggplot(Logistic.Model.Data, aes(x=Input, y=Predicted)) + geom_point()

Logistic.Model.Data$Unscrambling.Sequence <-
  (predict(LinearModel.Training.Logistic,type="response")>.5)*1

ggplot(Logistic.Model.Data, aes(x=Input, y=Residuals*1:nSample.Training, color=Unscrambling.Sequence)) + 
  geom_point()


# Real model
LinearModel<-read.csv(file=paste(datapath,'ResidualAnalysisProjectData_1.csv',sep="/"),header=TRUE,sep=",")
nSample<-length(LinearModel[,1])
head(LinearModel)

EstimatedLinearModel <- lm(Output ~ Input, data=LinearModel)
LinearModel$Residuals <- EstimatedLinearModel$residuals

ggplot(LinearModel, aes(x=Input, y=Residuals)) + geom_point()

Unscrambling.Sequence.Logistic<-(predict(LinearModel.Training.Logistic,
                                         newdata=data.frame(Logistic.Output=LinearModel$Residuals,
                                                            Logistic.Input=LinearModel$Residuals),
                                         type="response")>.5)*1

Probability<-sum(Unscrambling.Sequence.Logistic)/length(Unscrambling.Sequence.Logistic)
Probability

binom.test(sum(Unscrambling.Sequence.Logistic), nSample)

LinearModel$Unscrambling.Sequence.Logistic <- Unscrambling.Sequence.Logistic

ggplot(LinearModel, aes(x=Input, y=Residuals, color=factor(Unscrambling.Sequence.Logistic))) + geom_point()

ggplot(LinearModel, aes(x=Input, y=Output, color=factor(Unscrambling.Sequence.Logistic))) + geom_point()

# Homework portion

train_dat <- read.table(paste(datapath,'Week6_Test_Sample_Train.csv',sep = '/'), header=TRUE)
ggplot(train_dat, aes(x=Input, y=Output, color=factor(Selection.Sequence))) + geom_point()
TrainingLinear <- lm(Output ~ Input, data=train_dat)

Logistic.Model.Data <- data.frame(
  Output = train_dat$Selection.Sequence, 
  Input = TrainingLinear$residuals
)

Logistic.Model.Training <- glm(Output ~ Input, 
                               data=Logistic.Model.Data,
                               family=binomial(link=logit))

train_dat$Predicted.Probabilities <- predict(Logistic.Model.Training, type='response')
ggplot(train_dat, aes(x=Input, y=Predicted.Probabilities)) + geom_point()

train_dat$Unscramble <- (train_dat$Predicted.Probabilities > 0.5) * 1

ggplot(train_dat, aes(x=Input, y=Predicted.Probabilities, color=Unscramble)) + geom_point()



main_dat <- read.table(paste(datapath,'Week6_Test_Sample_Test.csv',sep = '/'), header=TRUE)
ggplot(main_dat, aes(x=Input, y=Output)) + geom_point()

LinearModel <- lm(Output ~ Input, data=main_dat)


main_dat$Unscramble <- (predict(Logistic.Model.Training, 
                               newdata=data.frame(
                                 Output = LinearModel$residuals,
                                 Input = LinearModel$residuals),
                               type='response') > 0.5) * 1

ggplot(main_dat, aes(x=Input, y=Output, color=factor(Unscramble))) + geom_point()

res <- list(Unscrambling.Sequence.Logistic = main_dat$Unscramble)
write.table(res, file = paste(datapath,'result.csv',sep = '/'), row.names = F)
