u<-c(1,2,3)
v<-c(4,5,6)
u*v

(Dot.Product.1<-sum(u*v))

(Dot.Product.2<-u%*%v)

lVector <- function(vec) 
  sqrt(vec %*% vec)[1,1]



u <- c(1.5, sqrt(3)/2)
v <- c(2, 0)

u %*% v

Manual.Calculation.Projection.U.on.V <- (u %*% v)[1,1] / lVector(v) * v

lVector(Manual.Calculation.Projection.U.on.V)


M<-matrix(1:12,ncol=4)

X.values<-c(1,2,3,4,5)
Y.values<-c(6,7,8,9,10)
(Product<-outer(X.values,Y.values))

contour(X.values,Y.values,log(Product))

Divide<-outer(X.values,Y.values,"/")
contour(X.values,Y.values,log(Divide))

(A<-rbind(c(5,2),c(3,1)))


(A.inv<-solve(A))

A%*%A.inv

dataPath <- "~/Dropbox/MScA/31007 - Stats Analysis"
da<-read.csv(file=paste(dataPath,"LognormalSample.csv",sep="/"))
head(da$x)

plot(da$x)

hist(da$x)

mu = log(median(da$x))
sigma = sqrt(2*log(mean(da$x))-2*mu)

c(mu=mu,sigma=sigma)

library(MASS)
fitdistr(da$x,"log-normal")

mean(log(da$x))
sd(log(da$x))
