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
m1 <- glm(count ~ temperature, data=minute_data, family=poisson())
summary(m1)
