###############################################################################
# MScA 31010: Linear & Non-Linear Methods
# Assignment 6: Zero Inflated Models
#
# In this week's assignment we study zero-inflated models. There are count-based
# models with an additional component (usually logistic) to add more zero 
# counts. Thus there is a zero component and a count component to the model.
#
###############################################################################

library(MASS)
library(countreg)

dataPath<-"~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 6/"
test_dat <- read.table(paste(dataPath,'Week6_Test_Sample.csv',sep = '/'), header=TRUE)


# Fir the zero-inflated Negative Binomal regression model from the 
# packaged "countreg"
zeroinfl.nb.fit <- countreg::zeroinfl(
  Output ~ Predictor.Count | Predictor.Zero, 
  data=test_dat, 
  link = 'logit', 
  dist='negbin')

summary(zeroinfl.nb.fit)
getSummary.zeroinfl(zeroinfl.nb.fit)

# Get the probs of the zero count from the zero part of the model
predicted.prob.zero.component <- predict(zeroinfl.nb.fit, newdata=test_dat, type='zero')

# Get the probs of the zero count from the full model
Probability.Zero <- predict(zeroinfl.nb.fit, newdata=test_dat, type='prob')[,1]

# Get the probs of the zero count from the count part of the model 
# This is done by building a negative-binomial model and then overwriting the
# paraemters with the extracted count model. Then finding the probability by
# using predict on that model object.
nb <- glm.nb(Output ~ Predictor.Count, test_dat)
predict(nb, newdata = test_dat)
nb$coefficients <- zeroinfl.nb.fit$coefficients$count
nb$theta <- zeroinfl.nb.fit$theta
predict(nb, newdata = test_dat, type='response')

prob = function(newx, newy, fit) {
  dnbinom(newy, mu=predict(fit, newdata=data.frame(Predictor.Count=newx), type="response"), size=fit$theta)
}

predicted.prob.count.component2 <- sapply(test_dat$Predictor.Count, function(x) prob(x, 0, nb))

predicted.prob.total <- as.matrix(
  cbind(
    Probability.Zero = Probability.Zero,
    Predictor.Count = test_dat$Predictor.Count,
    Predictor.Zero = test_dat$Predictor.Zero
  )
)

# Get Theta estimate
theta = zeroinfl.nb.fit$theta

res <- list(predicted.prob.zero.component=predicted.prob.zero.component,
            predicted.prob.count.component = predicted.prob.count.component2,
            predicted.prob.total = predicted.prob.total,
            theta = theta)

saveRDS(res, file = paste(dataPath,'result9.rds',sep = '/'))
