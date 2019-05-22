library(zoo)
library(xts)
library(ggplot2)

df <- read.csv('~/Datasets/31006/EVData.csv', stringsAsFactors=F)
names(df)[2] <- "EV"
df$Time <- as.POSIXct(df$Time, format = "%Y-%m-%d %H:%M:%S")

# Plot the whole shebang


# It looks rather spiky. Going to be hard for a model to pick up
# on this. Is there a pattern at a smaller level?


ggplot(head(df, 200), aes(x=Time, y=EV)) + geom_line()


library(prophet)
names(df) <- c("ds", 'y')
m <- prophet(df)

future <- make_future_dataframe(m, periods = 365)
tail(future)
forecast <- predict(m, future)
plot(m, forecast)
prophet_plot_components(m, forecast)
