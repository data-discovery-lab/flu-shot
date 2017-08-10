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

unnest_tokens(tweets, "word", "tweet")

anti_join(tweets, stop_words)

