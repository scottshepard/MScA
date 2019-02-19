
library(MASS)
library(countreg)

dataPath<-"~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 6/"

test_dat <- read.table(paste(dataPath,'Week6_Test_Sample.csv',sep = '/'), header=TRUE)

zeroinfl.nb.fit <- zeroinfl(Output ~ Predictor.Count | Predictor.Zero, 
                            data=test_dat, link = 'logit', dist='negbin')

summary(zeroinfl.nb.fit)
getSummary.zeroinfl(zeroinfl.nb.fit)

predicted.prob.count.component <- predict(zeroinfl.nb.fit, newdata=test_dat, type='prob', at=0)
predicted.prob.zero.component <- predict(zeroinfl.nb.fit, newdata=test_dat, type='zero')

probs = predict(zeroinfl.nb.fit, newdata=test_dat, type='prob')

Probability.Zero <- predict(zeroinfl.nb.fit, newdata=test_dat, type='prob')[,1]
predicted.prob.total <- as.matrix(
  cbind(
    Probability.Zero = Probability.Zero,
    Predictor.Count = test_dat$Predictor.Count,
    Predictor.Zero = test_dat$Predictor.Zero
  )
)

theta = zeroinfl.nb.fit$theta

res <- list(predicted.prob.zero.component=predicted.prob.zero.component,
            predicted.prob.count.component = predicted.prob.count.component,
            predicted.prob.total = predicted.prob.total,
            theta = theta)

saveRDS(res, file = paste(dataPath,'result6.rds',sep = '/'))
