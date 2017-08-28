# Data

set.seed(123)
setwd("~/Desktop/SOURCES/flue-shot")

tweets = read.csv("flushot.tweets.csv", stringsAsFactors = FALSE)

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
sparseTweets

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