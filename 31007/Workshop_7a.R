library(ggplot2)
library(faraway)

# Build the model 
a<-.8; b<-.1
N.sample<-1000
X.mean<-3
X.sd<-2.5
set.seed(458769)
Eps.mean<-0
Eps.sd<-2

X = rnorm(N.sample, X.mean, X.sd)
Eps = rnorm(N.sample, Eps.mean, Eps.sd)
Y = a*X+b+Eps

LinearModel1<-cbind(X,Eps,Y)
head(LinearModel1)

# Plot the model
ggplot(data.frame(LinearModel1), aes(x=X, y=Y)) + geom_point()

# Fit linear model
Model1.lm<-lm(LinearModel1[,3]~LinearModel1[,1])
summary(Model1.lm)

qqnorm(Model1.lm$residuals)


(my.Conf.Int<-confint(Model1.lm))


findInterval(.5,1:2)

findInterval(2.5,1:2)

findInterval(a,my.Conf.Int[2,])==1


Simulation.Experiment<-function(Intercept.b,Slope.a) {
  X = rnorm(N.sample, X.mean, X.sd)
  Eps = rnorm(N.sample, Eps.mean, Eps.sd)
  Y = Slope.a*X+Intercept.b+Eps
  dat = data.frame(X=X,Eps=Eps,Y=Y)
  m <- lm(Y~X,data=dat)
  my.Conf.Int <- confint(m)
  return(c(findInterval(Intercept.b,my.Conf.Int[1,])==1, findInterval(Slope.a,my.Conf.Int[2,])==1))
}

Simulation.Experiment(.8,.1)

set.seed(94)
Repeated.Experiment<-replicate(10000,Simulation.Experiment(b,a))
dim(Repeated.Experiment)

Repeated.Experiment[,1:20]

Coverage.table<-rbind(Intercept=table(Repeated.Experiment[1,]),
                      Slope=table(Repeated.Experiment[2,]))
Coverage.table/c(sum(table(Repeated.Experiment[1,])),sum(table(Repeated.Experiment[2,])))
