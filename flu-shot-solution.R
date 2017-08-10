# flu-shot analysis

# step1. loead data into memory
tweets = read.csv("flu-shot.converted.csv", stringsAsFactors = FALSE, header = FALSE)

# add header
colnames(tweets) = c('tweet', 'favorite_count')

str(tweets)

tweets

library(tm)
# Create Corpus
corpus = Corpus(VectorSource(tweets$tweet))

# remove 

library(tidytext)

library(tidyr)
get_sentiments("bing")

data("stop_words")

tidyTweets = unnest_tokens(tweets, "word", "tweet")

cleanTweets = anti_join(tidyTweets, stop_words)

str(cleanTweets)

count(cleanTweets, word, sort = TRUE) 
