# Data
install.packages("devtools")



install.packages("tm")
install.packages("tidytext")
install.packages("tidyr")
install.packages("dplyr")
install.packages("SnowballC")
install.packages("topicmodels")
install.packages("ggplot2")

library(devtools)
install_url("https://cran.r-project.org/src/contrib/slam_0.1-40.tar.gz")


library(tm)
library(tidytext)
library(tidyr)
library(dplyr)
library(SnowballC)
library(topicmodels)
library(ggplot2)
library(stringr)

set.seed(123)
setwd("~/TTU-SOURCES/flu-shot")

tweets = read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)

str(tweets)

version



replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

tweets = tweets %>% 
  dplyr::filter(!str_detect(tweet, "^RT")) %>%
  mutate(text = str_replace_all(tweet, replace_reg, "")) %>%


str(tweets)


# install and include library tm
install.packages("tm")
library(tm)


# Create Corpus
tweetCorpus = Corpus(VectorSource(tweets$tweet))

# convert documents into lowercase
tweetCorpus = tm_map(tweetCorpus, tolower)

str(tweetCorpus)

# Remove Stop words & stemp document
install.packages("SnowballC")
library(SnowballC)
tweetCorpus = tm_map(tweetCorpus, removeWords, stopwords("english"))
tweetCorpus = tm_map(tweetCorpus, stemDocument)

dtmTweets = DocumentTermMatrix(tweetCorpus)
dtmTweets

findFreqTerms(dtmTweets, lowfreq = 20)

# Filter out sparse terms by keeping only terms that appear in 0.3% or more of the revisions
sparseTweets = removeSparseTerms(dtmTweets, 0.997)


cleanTweets = as.data.frame(as.matrix(sparseTweets))
cleanTweets$takeFluShot = tweets$Take.flu.shot

colnames(cleanTweets) = make.names(colnames(cleanTweets))

str(cleanTweets)  

library(caTools)
set.seed(456)
# create split with 70% is TRUE (this will be used as training set)
spl = sample.split(cleanTweets$takeFluShot, SplitRatio = 0.7)
train = subset(cleanTweets, spl == TRUE)
test = subset(cleanTweets, spl == FALSE)
# baseline model accuracy on the test set that always predicts "not vandalism"
table(test$takeFluShot)[1] / sum(table(test$takeFluShot))



# CART Model
library(rpart)
library(rpart.plot)
trialsCART <- rpart(trial~., data=train, method="class")
prp(trialsCART)


# Predict using the trainig set. Because the CART tree assigns the same predicted probability to each leaf node and there are a small number of leaf nodes compared to data points, we expect exactly the same maximum predicted probability.
predTrain <- predict(trialsCART)[,2]
# Accuracy on the training set
t1 <- table(train$trial, predTrain >= 0.5)
(t1[1,1] + t1[2,2])/(sum(t1))



### convert to short tweet
mdat <- matrix(c(1,2,3, 11,12,13), nrow = 2, ncol=3, byrow=TRUE, 
               dimnames = list(c("row1", "row2"), c("C.1", "C.2", "C.3")))

## get columns of item
colnames(mdat)[apply(mdat, 2, function(u) any(u < 3))]

