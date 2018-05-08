library(caret)
library(dplyr)
library(ggplot2)

# 1 Data

datapath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 4"

LinearModelData <- read.csv(file.path(datapath,"ResidualAnalysisProjectData_1.csv"))
head(LinearModelData)

plot(LinearModelData$Input,LinearModelData$Output)

# 2 Fitting Linear Model

LinearModel <- lm(Output ~ Input, data=LinearModelData)
names(LinearModel)

head(LinearModel$coefficients)

plot(LinearModel$residuals)


# 3 Analysis of residual

Residuals <- LinearModel$residuals
plot(LinearModelData$Input, Residuals)

Probability.Density.Residuals <- density(Residuals)
plot(Probability.Density.Residuals, ylim = c(0, 0.5))
lines(Probability.Density.Residuals$x, dnorm(Probability.Density.Residuals$x, 
                                             mean = mean(Residuals), sd = sd(Residuals)))


c(Left.Mean = mean(Residuals[Residuals < 0]), 
  Right.Mean = mean(Residuals[Residuals > 0]))

Unscrambled.Selection.Sequence <- Residuals > 0

LinearModelData$seq <- Unscrambled.Selection.Sequence

ggplot(LinearModelData, aes(x=Input, y=Output, color=seq)) + geom_point()

Unscrambled.Selection.Sequence.true <- Unscrambled.Selection.Sequence[Unscrambled.Selection.Sequence]
cm<-confusionMatrix(factor(Unscrambled.Selection.Sequence),factor(Unscrambled.Selection.Sequence))$table
                    

# 5 Test
dataPath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 4"
dat <- read.table(file.path(dataPath,'Week4_Test_Sample.csv'), header=TRUE)

plot(dat)

m <- lm(Y ~ X, dat)




dat$seq <- m$residuals > 0

ggplot(dat, aes(x=X, y=Y, color=seq)) + geom_point()


Unscrambled.Selection.Sequence <- as.integer(m$residuals > 0)

res <- list(Unscrambled.Selection.Sequence =  Unscrambled.Selection.Sequence)
write.table(res, file = paste(dataPath,'result.csv',sep = '/'), row.names = F)
