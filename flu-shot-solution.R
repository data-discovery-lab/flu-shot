# flu-shot analysis

# step1. loead data into memory
tweets = read.csv("flu-shot.converted.csv", stringsAsFactors = FALSE, header = FALSE)

# add header
colnames(tweets) = c('tweet', 'favorite_count')

str(tweets)

tweets

library(tm)
library(tidytext)
library(tidyr)
library(dplyr)
library(SnowballC)

get_sentiments("bing")

data("stop_words")

tidyTweets = unnest_tokens(tweets, "word", "tweet")

str(tidyTweets)

cleanTweets = anti_join(tidyTweets, stop_words, by="word")

str(cleanTweets)

count(cleanTweets, word, sort = TRUE) 

bing_sentiments = get_sentiments("afinn");
sentimentTweets = inner_join(cleanTweets, bing_sentiments, by="word")

str(sentimentTweets)


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

tweets$tweet[1]
             
st = getTweetSentimentScore("i am feeling happy and lucky")
st


?count
count(st, word, sort = T)
str(st);
?mutate
st

View(st)


