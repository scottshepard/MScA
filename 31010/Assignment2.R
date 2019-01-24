

derivative <- function(FUN, val, projectID, eps=0.0001) {
  y0 = FUN(val, projectID)
  y1 = FUN(val+eps, projectID)
  return( (y1-y0) / (val+eps-val) )
}

taylor_iteration <- function(FUN, val, projectID) {
  val - FUN(val, projectID) / derivative(FUN, val, projectID)
}

my.Optimizer <- function(Start.Value, Function.To.Optimize, Epsilon, projectID) {
  X1 = Start.Value - Function.To.Optimize(Start.Value,projectID) / derivative(Function.To.Optimize, Start.Value, projectID)
  if(Epsilon < (X1 - Start.Value)) {
    return(my.Optimizer(X1, Function.To.Optimize, Epsilon, projectID))
  } else {
    return(X1)
  }
}

my.Function<-function(my.X, projectID) {
  my.X^2*3-my.X*5-6
}

X<-seq(from=-5,to=5,by=.1)
Y<-my.Function(X)
plot(X,Y,type="l")
abline(h=0)

my.root = my.Optimizer(-3, my.Function, Epsilon=0.0001, 5)
uniroot.root = uniroot(my.Function,lower=-5,upper=+1)$root
my.root - uniroot.root

dataPath = '~/Dropbox/MScA/31010 - Linear Non Linear/Assignment 2/'
testFunction<-readRDS(file=paste(dataPath,"MScA_Nonlinear_Models_Week2_TestFunction.rds",sep="/"))$Week2_Test_Function
projectID= 615
testFunction(0,projectID)



my.root = my.Optimizer(-3, testFunction, 0.0001, projectID)
uniroot.root = uniroot(testFunction, lower=-3, upper=0, projectID=projectID)$root

res <- list(Start.Value = -3,
            my.Optimizer.root = my.root,
            uniroot.root = uniroot.root,
            uniroot.lower = -3,
            uniroot.upper = 0)

write.table(res, file = paste(dataPath,'result.csv',sep = '/'), row.names = F)
