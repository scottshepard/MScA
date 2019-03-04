dataPath<-"~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 9/"

dat <- read.table(paste(dataPath,'Week9_Test_Sample.csv',sep = '/'), header=TRUE)

mFixedEffects <- lm(Response ~ 1+Predictor, data=dat)
anova(mFixedEffects)
AIC(mFixedEffects)

summary(mFixedEffects)
confint(mFixedEffects)

mFixedEffects.sig = c(
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

as.data.frame(VarCorr(mCorrelatedRandomEffects))
confint(mCorrelatedRandomEffects, oldNames=FALSE)

mCorrelatedRandomEffects.sig = c(
  "Intercept" = 1,
  "Predictor" = 1,
  "sigmaIntercept" = 0,
  "sigmaSlope" = 0,
  "Correlation" = 0
)

mIndependentRandomEffects <- lme4::lmer(
  Response ~ 1+Predictor+(1|Subject)+(0+Predictor|Subject),
  data=dat,
  REML=F
)
anova(mIndependentRandomEffects)
AIC(mIndependentRandomEffects)

(fm8 <- lmer(Reaction~Days+(Days|Subject),sleepstudy,REML=F))
head(ranef(fm8)$Subject)
summary(fm8)
confint.merMod(fm8, oldNames=FALSE)

fumm(fm9 <- lmer(Reaction~1+Days+(1|Subject)+(0+Days|Subject),sleepstudy,REML=F))
summary(fm9)
confint(fm9)

anova(fm8, fm9)

cc <- confint(fm8)
cbind(as.data.frame(VarCorr(fm8), order="lower.tri"),cc)

