dataPath <- "~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 1/"

Linear.Model.Data <- read.csv(
  file=paste(dataPath,"Week1_Homework_Project_Data.csv",sep="/"),
  header=TRUE,
  sep=",")

head(Linear.Model.Data,10)

Linear.Model.Data.lm  <-  lm(
  Output ~ Input1 + Input2 + Input3, 
  data=Linear.Model.Data)

Linear.Model.Data.glm <- glm(
  Output ~ Input1 + Input2 + Input3, 
  data=Linear.Model.Data)

matplot(1:length(Linear.Model.Data[,1]),cbind(Linear.Model.Data.lm$residuals,Linear.Model.Data.glm$residuals),type="l",ylab="Residuals",xlab="Count")

sum(abs(Linear.Model.Data.lm$residuals-Linear.Model.Data.glm$residuals)>.00000000001)

res <- Linear.Model.Data.lm$residuals

