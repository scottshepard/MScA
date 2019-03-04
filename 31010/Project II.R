library(copula)

part2_data<-read.csv(file=paste(dataPath,"OneMinuteCountsTemps.csv",sep="/"))
head(part2_data)

part2_data<-part2_data[complete.cases(part2_data),]

part2_data$intensity<-part2_data[,"count"]
head(part2_data)

plot(part2_data$temperature,part2_data$intensity)

plot(rank(part2_data$temperature)/(dim(part2_data)[1]+1),
     rank(part2_data$intensity)/(dim(part2_data)[1]+1),xlab="Temperature",ylab="Intensity")

plot(copula::pobs(part2_data[,c("temperature","intensity")]),xlab="Temperature",ylab="Intensity")


# Part 1 - Fit Parametric Copulas
# Normal, Gumbel, Clayton, Frank

copula_data <- copula::pobs(part2_data[,c("temperature","intensity")])

fit.copula.normal <- fitCopula(
  copula = normalCopula(),
  data = copula_data,
  method = "ml",
  optim.method = "BFGS")
fit.copula.normal@loglik
# 198.146

fit.copula.gumbel <- fitCopula(
  copula = gumbelCopula(),
  data = copula_data,
  method = "ml",
  optim.method = "BFGS")
fit.copula.gumbel@loglik
# 247.092

fit.copula.clayton <- fitCopula(
  copula = claytonCopula(),
  data = 1-copula_data,
  method = "ml",
  optim.method = "BFGS")
fit.copula.clayton@loglik
# 111.659 -- wrong for some reason
# 259.973

fit.copula.frank <- fitCopula(
  copula = frankCopula(),
  data = copula_data,
  method = "ml",
  optim.method = "BFGS")
fit.copula.frank@loglik
# 211.514

# Part 2 - Copula quantile regression

alphaClayton = summary(fit.copula.clayton)$coefficients[1]
copulaClayton_sim <- claytonCopula(param=alphaClayton,dim=2)
persp(copulaClayton_sim, dCopula, main="pdf",xlab="u", ylab="v", zlab="c(u,v)")

contour(copulaClayton_sim,dCopula, main="pdf",xlab="u", ylab="v")

simData<-rCopula(1000,copulaClayton_sim)
plot(simData)

contour(copula_data)

distrParam

# Follow the steps of copula quantile regression:

# 1. Calculate copula image of the predictor imgX using the marginal 
#    distribution fitted to the data in Part 1
temp_mean = distrParam$temperature$estimate[1]
temp_sd = distrParam$temperature$estimate[2]

imgX <- pnorm(part2_data$temperature, mean=temp_mean, sd=temp_sd)

# 2. If the copula needs to be inverted from upper tail to lower tail or 
#    vice versa, rotate the image by imgX <- -imgX+1
copulat_data_rot = 1-copula_data
imgX <- 1-imgX

# 3. Calculate image quantiles of conditional distribution V|U corresponding 
#    to the selected copula type, its parameter and every point of
#    imgX (image of X) for levels 5%, 95% and 50% (median). Use formulas given
#    in the lecture for quantiles of conditional distributions corresponding to 
#    different copula types

qclayton <- function(X, alpha_, theta_) {
  # Clayton conditional distribution quantile
  ((alpha_**(-theta_/(1+theta_)) - 1) * X**(-theta_) + 1) ** (-1/theta_)
}

theta <- fit.copula.clayton@estimate

intensity.Q.Low  <- qclayton(imgX, alpha_=0.95, theta_=theta)
intensity.Q.Mid  <- qclayton(imgX, alpha_=0.50, theta_=theta)
intensity.Q.High <- qclayton(imgX, alpha_=0.05, theta_=theta)

plot(cbind(imgX, copulat_data_rot[,2]))
points(imgX,intensity.Q.Low,col="orange",pch=16)
points(imgX,intensity.Q.Mid,col="cyan",pch=16)
points(imgX,intensity.Q.High,col="orange")

# 4. Reconstruct quantiles for the original data units from the image quantiles
#   using marginal distributions fitted to the variables. Remember to rotate 
#   image before reconstructing if necessary

intensity.Q.Low  = 1 - intensity.Q.Low
intensity.Q.Mid  = 1 - intensity.Q.Mid
intensity.Q.High = 1 - intensity.Q.High

fitted_shape = distrParam$intensity$estimate[1]
fitted_rate  = distrParam$intensity$estimate[2]

intensLow  = qgamma(intensity.Q.Low,  shape=fitted_shape, rate=fitted_rate)
intensMid  = qgamma(intensity.Q.Mid,  shape=fitted_shape, rate=fitted_rate)
intensHigh = qgamma(intensity.Q.High, shape=fitted_shape, rate=fitted_rate)

# 5. Use reconstructed quantiles as predictions of conditional quantiles of 
#    Y given X. In particular, predict Y by the 50% quantile (median)

lowMidHigh = data.frame(
  "intensLow" = intensLow,  
  "intensMid" = intensMid, 
  "intensHigh" = intensHigh
  )

df <- cbind(part2_data, lowMidHigh)
anomalies <- df[df$intensity > df$intensHigh,]

plot(part2_data$temperature,part2_data$intensity)
points(part2_data$temperature,lowMidHigh[,"intensLow"],col="orange")
points(part2_data$temperature,lowMidHigh[,"intensHigh"],col="red")
points(part2_data$temperature,lowMidHigh[,"intensMid"],col="cyan")
points(part2_data$temperature[anomalies$minute],
       part2_data$intensity[anomalies$minute],col="magenta",pch=16)


# Step 5 Test

dat <- readRDS(paste(dataPath,'nonlinear_models_course_assignment_step_5_data.rds',sep = '/'))

test_copula_data = pobs(cbind(dat$predictor, dat$output))
plot(test_copula_data)

test_imgX <- pnorm(dat$predictor, mean=dat$predictor_DistrParameters[1], sd=dat$predictor_DistrParameters[2])
test_imgX_rot <- 1-test_imgX

fit.copula.clayton.test <- fitCopula(
  copula = claytonCopula(),
  data = 1-test_copula_data,
  method = "ml",
  optim.method = "BFGS")
fit.copula.clayton.test@loglik

theta <- fit.copula.clayton.test@estimate
test.output.Q.Low  <- 1-qclayton(test_imgX_rot, alpha_=0.95, theta_=theta)
test.output.Q.Mid  <- 1-qclayton(test_imgX_rot, alpha_=0.50, theta_=theta)
test.output.Q.High <- 1-qclayton(test_imgX_rot, alpha_=0.05, theta_=theta)

test_fitted_mean = dat$output_DistrParameters[1]
test_fitted_sd = dat$output_DistrParameters[2]

test.output.Low  = qlnorm(test.output.Q.Low,  meanlog=test_fitted_mean, sdlog=test_fitted_sd)
test.output.Mid  = qlnorm(test.output.Q.Mid,  meanlog=test_fitted_mean, sdlog=test_fitted_sd)
test.output.High = qlnorm(test.output.Q.High, meanlog=test_fitted_mean, sdlog=test_fitted_sd)

plot(dat$predictor,dat$output)
points(dat$predictor,test.output.Low,col="orange")
points(dat$predictor,test.output.Mid,col="red")
points(dat$predictor,test.output.High,col="cyan")


res <- list(anomalies_temperature = anomalies$temperature,
            anomalies_intensity = anomalies$intensity,
            copulaType = "clayton",
            quantileLow=test.output.Low,
            quantileMid=test.output.Mid,
            quantileHigh=test.output.High
)

saveRDS(res, file = paste(dataPath,'result2.rds',sep = '/'))
