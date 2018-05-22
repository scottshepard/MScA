library(relaimpo)

# 1. Data

dataPath <- "~/Dropbox/MScA/31007 - Stats Analysis/Assignment 9/"

Project.Data<-read.csv(file.path(dataPath, "PCA_ExampleData.csv"))
Project.Data[1:10,]

# The first row of Project.Data contains the levels at which the variables are measured.
# Separate them from the Outputs for further analysis

Data.Levels<-as.numeric(Project.Data[1,])
Project.Data<-Project.Data[-1,]
head(Project.Data)

matplot(Project.Data,type="l")

Project.Data.PCA <- princomp(Project.Data)

names(Project.Data.PCA)

# Components
plot(Project.Data.PCA)

# Loadings
matplot(Project.Data.PCA$loadings[,1:3], type='l')

# Factors
matplot(Project.Data.PCA$scores[,1:3], type='l')

# Test

# Pull in the data and build a basic linear model with given variables
# With PCA we will try to make a model that is almost as good with fewer 
# variables
test_dat <- read.table(paste(dataPath,'Week9_Test_Sample.csv',sep = '/'), header=TRUE)
linMod <- lm(Resp~., data=test_dat)
original.r.squared <- summary(linMod)$r.squared
original.r.squared
# The r.squared we want to approximate is 0.997

# Break out predictors. PCA will be done on the predictors only.
# PCA explains variance among predictors
predictors <- test_dat[,2:11]
pca <- princomp(predictors)

# Quiz question 1 & 2
# 1). What is the smallest number of factors sufficient for explanation of at 
# least: 80.68317 % of the total variance of predictors?
# 2). Which are the factors selected in question 1?
# Answer:
# Just look at summary(pca)
# The "cumulative proporation" row measures % variance explained cumulatively
# For this question, by #3 we get 80.7%
summary(pca)
plot(pca)

# Quiz Question 3
# Fit another linear model with the same response, but predictors replaced by 
# principal components (factors). Which principal components you decide to 
# include in such linear model if you are asked to achive R^2 of at least 
# `0.9*r.squared`, where `r.squared` is R-squared of the model with all 
# original predictors?

# This is trickier. First build a new data.frame with 
# the original response but the columns now are the principal
# components
td_rot <- as.data.frame(cbind(Resp=test_dat$Resp, pca$scores))

# Create a linear model with the principal components
linModPCA <- lm(Resp~., data=td_rot)

# Calculate the importance of each component in predicting response
calc.relimp(linModPCA)@lmg.rank

# Reorder the components based on the relative importance
order <- c(1,3,5,6,4,10,9,7,8,2)
calc.relimp(linModPCA)@lmg.rank[order]
td_rot_reorder <- td_rot[,c(1,order+1)]

# Calculate the R^2 of PCA model with each subesquent 
# compnent added. The first r^2 to break 90% original R^2 wins
r2s <- sapply(2:11, function(x) {
  summary(lm(Resp~., data=td_rot_reorder[,1:x]))$r.squared
})
r2s >= summary(lm(Resp~., data=test_dat))$r.squared*0.9

# By the third component we have it. Which ones are they?
order[1:3]
# It's components 1, 3, 5 
