dataPath <- "~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 1/"

df <- read.table(paste(dataPath,'Week1_Test_Sample.csv',sep = '/'), header=TRUE)

LM  <-  lm(
  Output ~ Input1 + Input2 + Input3, 
  data=df)

LM.Null <- lm(Output~1, data=df)

GLM <- glm(
  Output ~ Input1 + Input2 + Input3, 
  family=gaussian(link="identity"),
  data=df)

cbind(
  Output.LM=LM$coefficients,
  Output.GLM=GLM$coefficients)

manual_log_likelihood <- function(linear_model) {
  n = nrow(linear_model$model)
  y = linear_model$model[1,]
  sigma = sd(linear_model$residuals)
  - n/2 * log(2*pi*sigma**2) - 1/(2*sigma**2) * sum(linear_model$residuals**2)
}

manual_aic <- function(linear_model) {
  log_likelihood <- manual_log_likelihood(linear_model)
  p = length(linear_model$coefficients)-1
  -2*log_likelihood+2*p
}

cbind(AIC.Manual=manual_aic(LM),
      AIC.From.Function=AIC(LM),
      AIC.From.GLM=GLM$aic)

res <- list(Linear.Model.Data.lm = LM,
            coefficients = LM$coefficients,
            residuals = LM$residuals,
            fitted.values = LM$fitted.value,
            linear.predictors = LM$fitted.value,
            deviance = sum(LM$residuals^2),
            aic = manual_aic(LM),
            y = df[,1],
            null.deviance = sum(LM.Null$residuals**2),
            dispersion = sigma(LM)**2
)

saveRDS(res, file = paste(dataPath,'result.rds',sep = '/'))
