# flu-shot analysis

# step1. loead data into memory
tweets = read.csv("flu-shot.converted.csv", stringsAsFactors = FALSE, header = FALSE)

# add header
colnames(tweets) = c('tweet', 'favorite_count')

library(tm)
library(tidytext)
library(tidyr)
library(dplyr)
library(SnowballC)

getTweetSentimentScore = function(message) {
  text <- c(message)
  text_df <- data_frame(line = 1:1, text = text)
  tidyMessage = unnest_tokens(text_df, "word", "text")
  
  data("stop_words")
  
  # remove stop words
  cleanMessage = anti_join(tidyMessage, stop_words, by="word")
  
  mySentiments = get_sentiments("afinn");
  
  mySentiments = mutate(mySentiments, word = wordStem(word))
  mySentiments = mySentiments[!duplicated(mySentiments),]
  #bing_sentiments = unique(bing_sentiments)

  # stemming, sacasm, etc using SnowballC
  cleanMessage = mutate(cleanMessage, word = wordStem(word))
  
  #create negative, positive words
  sentimentMessage = inner_join(cleanMessage, mySentiments, by="word")

  #sentiment score = counting negative, positive and make decision of the message sentiment
  return (sum(sentimentMessage$score))
}

testTweets = tweets[1:10, ]
tweetSentimentScore = lapply(testTweets$tweet, getTweetSentimentScore)
testTweets$sentiment = tweetSentimentScore

positiveTweets = testTweets[testTweets$sentiment >= 3, ]
negativeTweets = testTweets[testTweets$sentiment <= -3, ]
neutralTweets = testTweets[(testTweets$sentiment) > -3 & (testTweets$sentiment < 3), ]
library(topicmodels)
lda = LDA(positiveTweets$tweet, control = list(alpha = 0.1), k = 2)
str(positiveTweets)

# data("AssociatedPress", package="topicmodels")
# 
# str(AssociatedPress)
