dataPath<-"~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 8/"

dat <- read.table(paste(dataPath,'Week8_Test_Sample.csv',sep = '/'), header=TRUE)

mFixedEffects <- lm(Response ~ Predictor1 + Predictor2, data=dat)

fixedEffects <- c(
  mFixedEffects$coefficients[1], 
  sapply(mFixedEffects$coefficients[3:9], function(fe) {
    mFixedEffects$coefficients[1] + fe
  })
)
fixedEffects<-fixedEffects-mean(fixedEffects)

Manual<-aggregate(dat$Response,
                  by=list(dat$Predictor2),
                  function(z) mean(z))$x
(Manual<-Manual-mean(Manual))


mRandomEffects <- lme4::lmer(Response ~ Predictor1+(1|Predictor2), data=dat)
randomEffects <- lme4::ranef(mRandomEffects,condVar=T)

baseLevel<-summary(mRandomEffects)$coefficients[1]
pred<-unique(predict(mRandomEffects))
cbind(Manual=pred-baseLevel,
      RandomEffects=randomEffects$Predictor2)

Kappa = sd(unlist(randomEffects)) / sd(fixedEffects)


res <- list(fixedEffects = fixedEffects,
            randomEffects = randomEffects,
            Kappa = Kappa
)
saveRDS(res, file = paste(dataPath,'result4.rds',sep = '/'))
