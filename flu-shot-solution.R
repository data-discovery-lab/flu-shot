# flu-shot analysis

# step1. loead data into memory
tweets = read.csv("flu-shot.converted.csv", stringsAsFactors = FALSE, header = FALSE)

# add header
colnames(tweets) = c('tweet', 'favorite_count')


install.packages("tm")
install.packages("tidytext")
install.packages("tidyr")
install.packages("dplyr")
install.packages("SnowballC")
install.packages("topicmodels")
install.packages("ggplot2")

library(tm)
library(tidytext)
library(tidyr)
library(dplyr)
library(SnowballC)
library(topicmodels)
library(ggplot2)


index = c(1:length(tweets$tweet))
tweets$tweetId = index;

tidyTweets = unnest_tokens(tweets, "word", "tweet")

cleanTweets = anti_join(tidyTweets, stop_words, by="word")

mySentiments = get_sentiments("afinn");
mySentiments = mutate(mySentiments, word = wordStem(word))
mySentiments = mySentiments[!duplicated(mySentiments),]

cleanTweets = mutate(cleanTweets, word = wordStem(word))

str(cleanTweets)

#create negative, positive words
sentimentTweets = inner_join(cleanTweets, mySentiments, by="word")
str(sentimentTweets)

positiveTweets = sentimentTweets[sentimentTweets$score >= 3,]
negativeTweets = sentimentTweets[sentimentTweets$score <= -3,]
neutralTweets = sentimentTweets[sentimentTweets$score < 3 & sentimentTweets$score > -3,]


getTopicAndPopularTerms = function (clusteredTweets, noTopics, noTopTerms) {
  # positive topics
  word_counts = count(clusteredTweets, tweetId, word, sort = TRUE) 
  clusteredTweets_dtm = cast_dtm(word_counts, tweetId, word, n) 
  
  clusteredTweets_lda = LDA(clusteredTweets_dtm, k = noTopics, control = list(seed = 1234))
  clusteredTweets_topics = tidy(clusteredTweets_lda, matrix = "beta")
  # top 5 terms in each topic
  top_terms = clusteredTweets_topics %>%
    group_by(topic) %>%
    top_n(noTopTerms, beta) %>%
    ungroup() %>%
    arrange(topic, -beta)
  
  top_terms
  
  return (top_terms)
}

plotTermsAndTopics = function(top_terms) {
  top_terms %>%
    mutate(term = reorder(term, beta)) %>%
    ggplot(aes(term, beta, fill = factor(topic))) +
    geom_col(show.legend = FALSE) +
    facet_wrap(~ topic, scales = "free") +
    coord_flip()
}

NUMBER_POPULAR_TERMS = 10
NUMBER_TOPICS_POSITIVE = 4
NUMBER_TOPICS_NEGATIVE = 4
NUMBER_TOPICS_NEUTRAL = 4


# positive topics
positiveTopTerms = getTopicAndPopularTerms(positiveTweets, NUMBER_TOPICS_POSITIVE, NUMBER_POPULAR_TERMS)
plotTermsAndTopics(positiveTopTerms)

#negative
negativeTopTerms = getTopicAndPopularTerms(negativeTweets, NUMBER_TOPICS_NEGATIVE, NUMBER_TOPICS_NEGATIVE)
plotTermsAndTopics(negativeTopTerms)

#netral
neutralTopTerms = getTopicAndPopularTerms(neutralTweets, NUMBER_TOPICS_NEUTRAL, NUMBER_TOPICS_NEUTRAL)
plotTermsAndTopics(neutralTopTerms)


