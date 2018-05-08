library(ggplot2)

set.seed(1)

len <- function(x)
  sqrt(x %*% x)

nSample <- 1000 
b0 <- 3
b1 <- -1.5
sigma <- 2.2
eps <- rnorm(nSample, 0, sigma)
X <- runif(nSample, 0, 10)
Y <- b0 + b1 * X + eps

df <- data.frame(X, Y)

ggplot(df, aes(x=X, y=Y)) + geom_point() + geom_smooth(method='lm')

m1 <- lm(Y~X, data=df)

df$y_hat <- m1$fitted.values
df$error <- Y - m1$fitted.values

df$y_hat %*% df$error

len(df$y_hat)
(df$Y %*% df$y_hat) / len(df$y_hat)

df$y_bar <- mean(df$Y)

len(df$y_bar)
(df$Y %*% df$y_bar)/len(df$y_bar)

df$effect <- df$y_hat - df$y_bar
df$y_bar %*% df$effect

len(df$effect)
(df$Y %*% df$effect)/len(df$effect)

##############################################################################

set.seed(1029384)
Total.sample.size<-1000000
One.run.size<-1000
Slope<-1.7
Intercept<-3
Input<-rnorm(One.run.size,1,1)

set.seed(102938)
Eps<-rnorm(Total.sample.size,0,1)
dim(Eps)<-c(1000,1000)

Output.matrix<-Slope*Input+Intercept+Eps

Fits<-apply(Output.matrix,2,function(z) lm(z~Input))

Matrix.coefficients<-cbind(unlist(lapply(Fits,function(z) z$coefficients[1])),
                           unlist(lapply(Fits,function(z) z$coefficients[2])),
                           unlist(lapply(Fits,function(z) summary(z)$sigma)))

colnames(Matrix.coefficients)<-c("Intercept","Slope","Sigma")
rownames(Matrix.coefficients)<-NULL
head(Matrix.coefficients)

apply(Matrix.coefficients,2,mean)

par(mfrow=c(3,1))
apply(Matrix.coefficients,2,hist)

par(mfrow=c(1,1))

mu<-c(Intercept,Slope,1)
sig<-apply(Matrix.coefficients,2,sd)
zMatrix.coefficients<-t(apply(Matrix.coefficients,1,function(z) (z-mu)/sig)) # Matrix of z-scores
head(zMatrix.coefficients)

apply(zMatrix.coefficients,2,function(z) ks.test(z,"pnorm")$p.value)

sqrt(apply(Matrix.coefficients,2,var))

oneSample<-Output.matrix[,1]
m1<-lm(oneSample~Input)
summary(m1)
