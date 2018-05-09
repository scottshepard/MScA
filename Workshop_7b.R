
## Variable Selection
dat<-as.data.frame(state.x77)
names(dat)[4]<-"LifeExp"
names(dat)[6]<-"HSGrad"
head(dat)

pairs(dat)

m1<-lm(LifeExp~.,data=dat)
summary(m1)

anova(m1)

anova(
  lm(LifeExp~Population+Income, data=dat),
  lm(LifeExp~Population, data=dat))


m2<-lm(LifeExp~.,data=dat[,-8])
summary(m2)

anova(m1, m2)


m3 <- lm(LifeExp~.,data=dat[,c(-3,-8)])
summary(m3)

m4 <- lm(LifeExp~.,data=dat[,-c(2,3,8)])
summary(m4)


ma0<-lm(LifeExp~1,data=dat)
summary(ma0)
anova(ma0)
myScope<-names(dat)[-which(names(dat)=="LifeExp")]
add1(ma0,scope=myScope)

ma1<-lm(LifeExp~Murder,data=dat)
summary(ma1)

myScope<-myScope[-which(myScope=="Murder")]
add1(ma1,scope=myScope)
ma2<-lm(LifeExp~Murder+HSGrad,data=dat)

myScope<-myScope[-which(myScope=="HSGrad")]
add1(ma2,scope=myScope)

step(m1,direction="both")
