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

splitData <- function(data, smp_size) {
  # Take a dataset and split it randomly into train and test sets
  # The size of the training set is the smp_size argument
  train_ind <- sample(seq_len(nrow(data)), size = smp_size)
  train <- data[ train_ind, ]
  test  <- data[-train_ind, ]
  
  list("train"=train, "test"=test)
}

genres <- read.csv(file.path(path, "genres.csv"))
tracks <- special_read_csv(file.path(path, "tracks.csv"), n_rows=10000)
echonest <- special_read_csv(file.path(path, "echonest.csv"), n_rows=10000, offset=1)[,1:26]

View(head(tracks))

ggplot(tracks, aes(x=track_genre_top)) + 
  geom_bar(stat='count') +
  theme(axis.text.x = element_text(angle=90))

df <- dplyr::inner_join(tracks, echonest, "track_id")
set.seed(123)
l <- splitData(df, round(nrow(df) * 0.7))
df <- l$train

rpart(iter)

# df <- dplyr::inner_join(tracks, echonest, "track_id")


# features <- read.csv(file.path(path, "features.csv"), nrows=100)
