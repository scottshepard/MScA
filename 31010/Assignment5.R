# This assignment helps understanding Poisson regression and Negative Binomial regression.

# The data is from the measles dataset form the CDD 
# Recent outbreak of measles caused debates about necessity of vaccination.
# The data file for this project contains CDC data on immunization coverage 
# for MMR for all U.S. states and the national immunization rate.
# The data for outbreaks in each state were simulated using the assumption 
# that after vaccination 90% of vaccinated children become immuned.
# Another assumption was made that 100% of not immunized people get infected 
# when exposed to the virus.
# 

dataPath <- "~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 5/"
measles.data<-read.csv(file=paste(dataPath,"MeaslesImmunizationCoverageAndOutbreaks.csv",sep="/"))
head(measles.data)


# Fit Poisson Model
measles.poisson.model <- glm(Outbreaks ~ Coverage, family=poisson(link='log'), data=measles.data)

measles.poisson.model$coefficients
measles.poisson.model$deviance
measles.poisson.model$df.residual
measles.poisson.model$aic
measles.poisson.model$linear.predictors
rbind(measles.data$Outbreaks,measles.poisson.model$fitted.values)
log(measles.poisson.model$fitted.values)

# Fit Negative Binomal Regression
library(MASS)
Negative.Binomial.Model.glm.nb <- glm.nb(Outbreaks ~ Coverage, data=measles.data)
Negative.Binomial.Model.glm.nb

Negative.Binomial.Model.glm.nb$theta


## Test
test_dat <- read.table(paste(dataPath,'Week5_Test_Sample.csv',sep = '/'), header=TRUE)
head(test_dat)

glm.poisson.fit <- glm(Output ~ Predictor, family=poisson(link='log'), data=test_dat)
glm.nb.fit <- glm.nb(Output ~ Predictor, data=test_dat)

theta <- glm.nb.fit$theta
dispersion.test.p.value <- AER::dispersiontest(glm.poisson.fit,alternative="two.sided")$p.value
predicted.values <- predict(glm.nb.fit, newdata = test_dat, type="response")


res <- list(predicted.values=predicted.values,  
            dispersion.test.p.value=dispersion.test.p.value,
            theta = theta)
saveRDS(res, file = paste(dataPath,'result.rds',sep = '/'))
