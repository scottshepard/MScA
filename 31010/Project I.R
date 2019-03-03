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
