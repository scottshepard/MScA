df <- read.csv("angry_moods.csv", stringsAsFactors = F)
mean(df$Anger_Expression)
sd(df$Anger_Expression)

 g = df %>% 
  group_by(Sports) %>%
  summarize(
    N = n(),
    M = mean(Anger.In),
    Var = var(Anger.In))
 g

sse = sum((df[df$Sport==1,]$Anger.In - g$M[1])^2) + 
  sum((df[df$Sport==2,]$Anger.In - g$M[2])^2)

d.f = sum(g$N)-2

mse = sse / d.f
nh = harmonic.mean(g$N)$harmean
s=sqrt(2*mse/nh)
t = qt(.975, d.f)

-diff(g$M)+t*s
-diff(g$M)-t*s


df1 = data.frame(
  age = rep(12, 10),
  time = c(rep(30, 5), rep(60, 5)),
  score = c(66, 68, 59, 72, 46, 69, 61, 69, 73, 61)
)

df2 = data.frame(
  age = rep(16, 10),
  time = c(rep(30, 5), rep(60, 5)),
  score = c(74, 71, 67, 82, 76, 95, 92, 95, 98, 94)
)

df <- rbind(df1, df2)
