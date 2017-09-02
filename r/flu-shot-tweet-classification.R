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
#setwd("~/TTU-SOURCES/flu-shot")
setwd("~/Desktop/SOURCES/flue-shot")

tweets = read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)

str(tweets)

version



replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

tweets = tweets %>% 
  mutate(text = str_replace_all(tweet, replace_reg, ""))

tweets$tweet = tweets$text
tweets$text = NULL

str(tweets)


# Create Corpus
tweetCorpus = Corpus(VectorSource(tweets$tweet))

# convert documents into lowercase
tweetCorpus = tm_map(tweetCorpus, content_transformer(tolower))
tweetCorpus = tm_map(tweetCorpus, content_transformer(removePunctuation))

str(tweetCorpus)

tweetCorpus = tm_map(tweetCorpus, content_transformer(removeWords), c("flu", "shot", "shots", "feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "flushot", stopwords("english")))
tweetCorpus = tm_map(tweetCorpus, stemDocument)

dtmTweets = DocumentTermMatrix(tweetCorpus)
dtmTweets

# find frequency
findFreqTerms(dtmTweets, lowfreq = 20)


# Filter out sparse terms by keeping only terms that appear in 0.3% or more of the revisions
sparseTweets = removeSparseTerms(dtmTweets, 0.997)
sparseTweets

cleanTweets = as.data.frame(as.matrix(sparseTweets))
colnames(cleanTweets) = make.names(colnames(cleanTweets))
cleanTweets$negativeFlushot = tweets$negativeFlushot

str(cleanTweets)  

library(caTools)
# create split with 70% is TRUE (this will be used as training set)
spl = sample.split(cleanTweets$negativeFlushot, SplitRatio = 0.7)
trainSparse = subset(cleanTweets, spl == TRUE)
testSparse = subset(cleanTweets, spl == FALSE)

str(testSparse)
# CART Model
library(rpart)
library(rpart.plot)
tweetCART <- rpart(negativeFlushot ~., data=trainSparse, method="class")
prp(tweetCART)


# Predict using the trainig set. Because the CART tree assigns the same predicted probability to each leaf node and there are a small number of leaf nodes compared to data points, we expect exactly the same maximum predicted probability.
predictCart <- predict(tweetCART, newData=testSparse, type="class")

str(predictCart)
str(testSparse$negativeFlushot)

## accuracy test
table(testSparse$negativeFlushot, predictCart)



