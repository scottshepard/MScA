install.packages(
  c(
    # Data Manipulation
    "dplyr",
    "plyr",
    "DataCombine",
    "openxlsx",
    "gdata",
    
    # Plotting
    "ggplot2",
    "lattice",
    "latticeExtra",
    "rgl",
    
    # Animation
    "animation",
    
    # Statistical Models
    "faraway",
    "MASS",
    "AER",
    "pscl",
    "copula",
    "countreg",
    "caret",
    "relaimpo",
    "lme4", # mixed effects
    "depmixS4", # hidden markov models
    "kohonen", # self organizing maps
    
    # Clustering
    "mclust",
    "nor1mix",
    
    # Randomness
    "randtests",
    "randtoolbox",
    "random",
    
    # Timeseries
    "zoo",
    "xts",
    "tseries",
    "forecast",
    "TSA",
    "prophet"
  ),
  repos='http://cran.us.r-project.org'
)
