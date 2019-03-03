library(dplyr)
library(MASS)
library(pscl)

dataPath <- "~/Dropbox/MScA/31010 - Linear Non Linear/Course Project/"
Course.Project.Data <- read.csv(file=paste(dataPath,"MScA_31010_LinearNonLinear_MalfunctionData.csv",sep="/"))
head(Course.Project.Data,10)

# Step 1

counting_process<-as.data.frame(cbind(Time=Course.Project.Data$Time,                                      
                                      Count=1:length(Course.Project.Data$Time)))
counting_process[1:10,]

plot(counting_process$Time,counting_process$Count,type="s")

plot(counting_process$Time,
     counting_process$Count/counting_process$Time,type="l",
     ylab="Cumulative Intensity")
abline(h=counting_process$Count[length(counting_process$Count)]/
         counting_process$Time[length(counting_process$Time)])
abline(h=mean(counting_process$Count/counting_process$Time))

c(Last.Intensity=counting_process$Count[length(counting_process$Count)]/
    counting_process$Time[length(counting_process$Time)],
  Mean.Intensity=mean(counting_process$Count/counting_process$Time))

Course.Project.Data$minute <- floor(Course.Project.Data$Time / 60) + 1

minute_data <- Course.Project.Data %>% 
  group_by(minute) %>%
  summarize( count=n(), temperature = mean(Temperature)) %>%
  data.frame()

head(minute_data, 2)
dim(minute_data)

# Step 1 Quiz 
minute_data[67,]

# Step 2
# Analysis of overdispersion
# Use three different methods to analyze dispersion
m1 <- glm(count ~ minute, data=minute_data, family=poisson())

# Method 1 - CI based on deviance & dof
ci_chisq <- function(model) {
  deviance = summary(model)$deviance
  dof = summary(model)$df.residual
  qchisq(c(.025,.975), df=dof, lower.tail=FALSE)
}
summary(m1)$deviance
ci_chisq(m1)
# The deviance far outside the confidence interval for Chi-Squared

# Method 2 - Regression Test
AER::dispersiontest(m1)
# The dispersion test shows the same thing the CI test did, p-value is small
# enought to reject the null. True dispersion is greater than 1.

# Method 3 - Test Against Neg Binom
m1.nb <- MASS::glm.nb(count ~ minute, data=minute_data)
pscl::odTest(m1.nb)
# Again, p-value is very small. Data cannot be described by Poisson.


# Step 2 Quiz
# Repeat three over-dispersion tests above on new data
test_dat <- read.table(paste(dataPath,'MScA_LinearNonlinear_step2_sample.csv',sep = '/'), header=TRUE)
test_dat$minute <- as.numeric(row.names(test_dat))

m2 <- glm(count ~ minute, data=test_dat, family=poisson())
summary(m2)$deviance
ci_chisq(m2)
# Deviance: 578.6287
# Lower Limit: 438.0601
# Upper Limit: 561.7274

AER::dispersiontest(m2)
# test stat: 2.0338
# p-value: 0.02099

m2.nb <- MASS::glm.nb(count ~ minute, data=test_dat)
pscl::odTest(m2.nb)
# test stat: 4.7795
# p-value: 0.0144

# Step 3
# Analyses of distributions of variables
library(lattice)
library(latticeExtra)

sample1=rnorm(100)
sample2=rnorm(100,1,2)
Cum.Distr.Functions <- data.frame(sample1,sample2)
ecdfplot(~ sample1 + sample2, data=Cum.Distr.Functions, auto.key=list(space='right'))

ks.test(sample1,sample2)

ks.test(sample1,"pnorm",mean=0,sd=1)

ks.test(sample2,"pnorm",mean=0,sd=1)

counting_process$Time

fitExp <- MASS::fitdistr(counting_process$Time, "exponential")
KSTest_event_intervals <- ks.test(counting_process$Time, "pexp", rate=fitExp$estimate)
c(KSTest_event_intervals$statistic,p.value=KSTest_event_intervals$p.value)

plot(ecdf(diff(counting_process$Time)),
     ylab="CDF",xlab="Time Intervals", 
     main="ECDF")

# Fit 5 candidates for distribution to event_indensities
event_intensities = minute_data$count
hist(event_intensities)

# Normal
fit.norm = MASS::fitdistr(event_intensities, densfun='normal')
ks.test(event_intensities,"pnorm",mean=fit.norm$estimate[1],sd=fit.norm$estimate[2])
# D = 0.15707, p-value = 8.78e-06

# Exponential
fit.exp = MASS::fitdistr(event_intensities, densfun = "exponential")
ks.test(event_intensities, "pexp", rate = fit.exp$estimate)
# D = 0.17956, p-value = 1.996e-07

# Gamma
fit.gam = MASS::fitdistr(event_intensities, densfun="gamma")
ks.test(event_intensities, "pgamma", shape=fit.gam$estimate[1], rate=fit.gam$estimate[2])
# D = 0.076201, p-value = 0.1097

# Log Normal
fit.lognorm = MASS::fitdistr(event_intensities, densfun = "lognormal")
ks.test(event_intensities, "plnorm", meanlog=fit.lognorm$estimate[1], sdlog=fit.lognorm$estimate[2])
# D = 0.12003, p-value = 0.001488

# Logistic
fit.logit = MASS::fitdistr(event_intensities, densfun="logistic")
ks.test(event_intensities, "plogis", location=fit.logit$estimate[1], scale=fit.logit$estimate[2])
# D = 0.10735, p-value = 0.006287

# Fit the same five candidates on temperature
temps = minute_data$temperature

# Normal
fit.norm = MASS::fitdistr(temps, densfun='normal')
ks.test(temps,"pnorm",mean=fit.norm$estimate[1],sd=fit.norm$estimate[2])
# D = 0.041953, p-value = 0.7711

# Exponential
fit.exp = MASS::fitdistr(temps, densfun = "exponential")
ks.test(temps, "pexp", rate = fit.exp$estimate)
# D = 0.57975, p-value < 2.2e-16

# Gamma
fit.gam = MASS::fitdistr(temps, densfun="gamma")
ks.test(temps, "pgamma", shape=fit.gam$estimate[1], rate=fit.gam$estimate[2])
# D = 0.048746, p-value = 0.5924

# Log Normal
fit.lognorm = MASS::fitdistr(temps, densfun = "lognormal")
ks.test(temps, "plnorm", meanlog=fit.lognorm$estimate[1], sdlog=fit.lognorm$estimate[2])
# D = 0.052065, p-value = 0.5069

# Logistic
fit.logit = MASS::fitdistr(temps, densfun="logistic")
ks.test(temps, "plogis", location=fit.logit$estimate[1], scale=fit.logit$estimate[2])
# D = 0.038929, p-value = 0.8431
