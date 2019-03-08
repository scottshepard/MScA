# Significance and comparing mixed vs. random effects models
library(lme4)
library(lmerTest)

fm8 <- lmer(Reaction ~ Days + (Days|Subject), sleepstudy, REML=F)
head(ranef(fm8)$Subject)
summary(fm8)
fm8ci = confint.merMod(fm8, oldNames=FALSE)
cbind(as.data.frame(VarCorr(fm8), order="lower.tri"), fm8ci[1:4,])

fm9 <- lmer(Reaction ~ 1 + Days + (1|Subject) + (0+Days|Subject), sleepstudy, REML=F)
fm9ci = confint.merMod(fm9, oldNames=FALSE)
cbind(as.data.frame(VarCorr(fm9), order="lower.tri"), fm9ci[1:3,])

anova(fm8, fm9)

# Test
dataPath<-"~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 9/"
dat <- read.table(paste(dataPath,'Week9_Test_Sample.csv',sep = '/'), header=TRUE)

mFixedEffects <- lm(Response ~ 1+Predictor, data=dat)
anova(mFixedEffects)
AIC(mFixedEffects)

summary(mFixedEffects)
confint(mFixedEffects)

fixed_Effects = c(
  "Intercept" = 1,
  "Predictor" = 1,
  "sigmaIntercept" = 0,
  "sigmaSlope" = 0,
  "Correlation" = 0
)

mCorrelatedRandomEffects <- lme4::lmer(
  Response ~ 1+Predictor + (1+Predictor|Subject), 
  data=dat,
  REML=F
)
anova(mCorrelatedRandomEffects)
AIC(mCorrelatedRandomEffects)
summary(mCorrelatedRandomEffects)
confint(mCorrelatedRandomEffects, oldNames=FALSE)

correlated_Random_Effects = c(
  "Intercept" = 1,
  "Predictor" = 1,
  "sigmaIntercept" = 1,
  "sigmaSlope" = 1,
  "Correlation" = 0
)

mIndependentRandomEffects <- lme4::lmer(
  Response ~ 1+Predictor+(1|Subject)+(0+Predictor|Subject),
  data=dat,
  REML=F
)
anova(mIndependentRandomEffects)
AIC(mIndependentRandomEffects)
confint(mIndependentRandomEffects, oldNames=FALSE)

independent_Random_Effects = c(
  "Intercept" = 1,
  "Predictor" = 1,
  "sigmaIntercept" = 1,
  "sigmaSlope" = 1,
  "Correlation" = 0
)

significance <- as.matrix(cbind(fixed_Effects, correlated_Random_Effects, independent_Random_Effects))

res <- list(selectedModel="independent_Random_Effects",
            significance= significance)

saveRDS(res, file = paste(dataPath,'result3.rds',sep = '/'))
