dataPath <- "~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 3/"

Age.Time.Sample<-read.csv(file=paste(dataPath,"Week3_Homework_Project_Data.csv",sep="/"),header=TRUE,sep=",")
Age.Time.Sample<-as.matrix(Age.Time.Sample)
Age.Time.Sample[1:10,]

plot(Age.Time.Sample)

plot(rank(Age.Time.Sample[,1])/length(Age.Time.Sample[,1]+1),
     rank(Age.Time.Sample[,2])/length(Age.Time.Sample[,1]+1),xlab="Age",ylab="Time")

c(Correlation=cor(Age.Time.Sample)[1,2],Determination=cor(Age.Time.Sample)[1,2]^2)

hist(Age.Time.Sample[,1])
hist(Age.Time.Sample[,2])

library(mclust)
Age.Clusters <- mclust::Mclust(Age.Time.Sample[,1], modelNames=c("V"))
summary(Age.Clusters, parameters = TRUE)

Age.Clusters$G
Age.Clusters$param

Age.Clusters.Parameters<-rbind(mu=Age.Clusters$param$mean,sigma=sqrt(Age.Clusters$param$variance$sigmasq),pro=Age.Clusters$param$pro)

library(nor1mix)

Classified.Mix.Model.Age = norMix(Age.Clusters$parameters$mean, sigma=sqrt(Age.Clusters$parameters$variance$sigmasq))
plot(Classified.Mix.Model.Age,xout=seq(from=10,to=60,by=.25),p.norm=TRUE,p.comp=TRUE)


Time.Clusters<-Mclust(Age.Time.Sample[,2], G=2,modelNames=c("V"))

#separate samples and explore dependencies
Age.Mixing.Sequence<-Age.Clusters$classification
Age.25.Time.21.Mixing.Sequence<-((Age.Clusters$classification==1)&(Time.Clusters$classification==1))
Age.25.Time.23.Mixing.Sequence<-((Age.Clusters$classification==1)&(Time.Clusters$classification==2))
Age.45.Time.21.Mixing.Sequence<-((Age.Clusters$classification==2)&(Time.Clusters$classification==1))
Age.45.Time.23.Mixing.Sequence<-((Age.Clusters$classification==2)&(Time.Clusters$classification==2))
Grouped.Data.Age.25.Time.21<-
  Grouped.Data.Age.25.Time.23<-
  Grouped.Data.Age.45.Time.21<-
  Grouped.Data.Age.45.Time.23<-
  cbind(Age=rep(NA,200),Time=rep(NA,200))
Grouped.Data.Age.25.Time.21[Age.25.Time.21.Mixing.Sequence,]<-
  Age.Time.Sample[Age.25.Time.21.Mixing.Sequence,]
Grouped.Data.Age.25.Time.23[Age.25.Time.23.Mixing.Sequence,]<-
  Age.Time.Sample[Age.25.Time.23.Mixing.Sequence,]
Grouped.Data.Age.45.Time.21[Age.45.Time.21.Mixing.Sequence,]<-
  Age.Time.Sample[Age.45.Time.21.Mixing.Sequence,]
Grouped.Data.Age.45.Time.23[Age.45.Time.23.Mixing.Sequence,]<-
  Age.Time.Sample[Age.45.Time.23.Mixing.Sequence,]
matplot(Age.Time.Sample[,1],cbind(Grouped.Data.Age.25.Time.21[,2],
                                  Grouped.Data.Age.25.Time.23[,2],
                                  Grouped.Data.Age.45.Time.21[,2],
                                  Grouped.Data.Age.45.Time.23[,2]),
        pch=16,xlab="Age",ylab="Time",
        col=c('black','red', 'blue', 'green'))
legend('topleft', c("Age.25.Time.21","Age.25.Time.23","Age.45.Time.21","Age.45.Time.23") , 
       lty=1,lwd=3, col=c('black','red', 'blue', 'green'), bty='n', cex=.75)


Grouped.Data.Age.25<-cbind(Age=rep(NA,200),Time=rep(NA,200))
Grouped.Data.Age.25[Age.Clusters$classification==1,]<-Age.Time.Sample[Age.Clusters$classification==1,]
Grouped.Data.Age.45<-cbind(Age=rep(NA,200),Time=rep(NA,200))
Grouped.Data.Age.45[Age.Clusters$classification==2,]<-Age.Time.Sample[Age.Clusters$classification==2,]
plot(rank(na.omit(Grouped.Data.Age.25[,1]))/length(na.omit(Grouped.Data.Age.25[,1])),
     rank(na.omit(Grouped.Data.Age.25[,2]))/length(na.omit(Grouped.Data.Age.25[,2])),
     xlab="Age 25 Group: Age",ylab="Age 25 Group: Time")


Age.Clusters.Parameters<-rbind(mu=Age.Clusters$param$mean,sigma=sqrt(Age.Clusters$param$variance$sigmasq),pro=Age.Clusters$param$pro)

library(copula)

Gaussian.Copula.Age.25.Time.23.fit <- fitCopula(
  copula = normalCopula(),
  data = pobs(na.omit(Grouped.Data.Age.25.Time.23),ties.method = "average"),
  method = "ml",
  optim.method = "BFGS")
Gaussian.Copula.Age.25.Time.23.fit

Gaussian.Copula.Age.45.Time.21.fit <- fitCopula(
  copula = normalCopula(),
  data = pobs(na.omit(Grouped.Data.Age.45.Time.21),ties.method = "average"),
  method = "ml",
  optim.method = "BFGS")
Gaussian.Copula.Age.45.Time.21.fit


test_data <- read.table(paste(dataPath,'Week3_Test_Sample.csv',sep = '/'), header=TRUE)
plot(rank(test_data[,1])/length(test_data[,1]+1),
     rank(test_data[,2])/length(test_data[,1]+1),xlab="X",ylab="Y")


par(mfrow=c(1,1))
set.seed(8301735)
#Frank Copula, Theta=5
Frank.Copula<-frankCopula(param=parameter,dim=2)
persp(Frank.Copula, dCopula, main="pdf",xlab="u", ylab="v", zlab="c(u,v)")
contour(Frank.Copula,dCopula, main="pdf",xlab="u", ylab="v")
Simulated.Frank.Copula<-rCopula(5000,Frank.Copula)
SimulatedN<-length(Simulated.Frank.Copula[,1])
plot(Simulated.Frank.Copula,main="Simulated Copula",xlab="Variable 1",ylab="Variable 2")
Empirical.Frank.Copula<-apply(Simulated.Frank.Copula,2,rank)/SimulatedN
plot(Empirical.Frank.Copula,main="Empirical Copula",xlab="Variable 1",ylab="Variable 2")
title("Frank Copula, param=5",outer=TRUE,line=-2)



copula.type="Gaussian"

copula.fit <- fitCopula(
  copula = copula::normalCopula(),
  data = pobs(test_data, ties.method = "average"),
  method = "ml",
  optim.method = "BFGS"
)
parameter = copula.fit@estimate

frank_conditional_dist = function(theta, alpha, u) {
  -1/theta*log(1-(alpha*(1-exp(-theta)))/(exp(-theta*u)+alpha*(1-exp(-theta*u))))
}

gaussian_condition_dist = function(theta, alpha, u) {
  pnorm(qnorm(alpha)*sqrt(1-theta**2)+theta*qnorm(u))
}

frank_conditional_dist(parameter, 0.5, pobs(test_data, ties.method = "average")[,1])
quantile = gaussian_condition_dist(parameter, 0.5, pobs(test_data, ties.method = "average")[,1])

res <- list(copula.type = copula.type,
            parameter =parameter, 
            quantile = quantile) 

saveRDS(res, file = paste("~/Desktop",'result.rds',sep = '/'))
