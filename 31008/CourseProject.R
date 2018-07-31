library(dplyr)
library(ggplot2)
library(stringr)

# Read Data
path <- "~/Dropbox/MScA/31008 - Data Mining/Project/fma_metadata/"

special_read_csv <- function(file_path, n_rows=-1, offset=0) {
  # The flat files in this project are formatted for easy python loading. 
  # The headers are a multilevel index. 
  # The first row is the category: track, album, artist, or set. 
  # The second row is the column name: id, producer, name, etc
  # Togther they make up the full column name. These need to be read in 
  # separately and manually pasted together to get the full column names.
  row0 <- read.csv(file_path, nrows=1, skip=0+offset)
  row1 <- read.csv(file_path, nrows=1, skip=1+offset)
  
  df <- read.csv(file_path, nrows=n_rows, skip=2+offset)
  headers <- paste(
    str_replace_all(names(row0), c("\\."="", "[0-9]+"="")), 
    str_replace_all(names(row1), c("\\."="_")), 
    sep="_")
  headers[1] <- "track_id"
  names(df) <- headers
  df
}

genres <- read.csv(file.path(path, "genres.csv"))
tracks <- special_read_csv(file.path(path, "tracks.csv"), n_rows=100)
echonest <- special_read_csv(file.path(path, "echonest.csv"), n_rows=100, offset=1)

View(head(tracks))

# features <- read.csv(file.path(path, "features.csv"), nrows=100)
