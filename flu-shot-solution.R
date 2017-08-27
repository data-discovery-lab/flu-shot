# flu-shot analysis

# step1. loead data into memory
setwd("~/Desktop/SOURCES/flue-shot")
tweets = read.csv("flu-shot.converted.csv", stringsAsFactors = FALSE, header = TRUE)
index = c(1:length(tweets$tweet))
tweets$tweetId = index;
tweets$state = tolower(tweets$state)
str(tweets)
# add header
#colnames(tweets) = c('tweet', 'favorite_count')

userTweets = split(tweets, tweets$user.Id)
cat("Number of users: ", length(userTweets))
cat("Number of tweets: ", nrow(tweets))

stateTweets = split(tweets, tweets$state)
for(i in 1:length(stateTweets)) {
  cat("State ", unique(stateTweets[[i]]$state))
  cat (" Tweet: ", nrow(stateTweets[[i]]))
  cat("\n")
}
cat("Number of states: ", length(stateTweets))
cat("Number of tweets: ", nrow(tweets))

ggplot(tweets, aes(x = state)) + geom_bar()


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
library(stringr)

replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"

cleanTweets = tweets %>% 
  dplyr::filter(!str_detect(tweet, "^RT")) %>%
  mutate(text = str_replace_all(tweet, replace_reg, "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = unnest_reg) %>%
  dplyr::filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

str(cleanTweets)
#View(cleanTweets)
#tidyTweets = unnest_tokens(tweets, "word", "tweet")
#cleanTweets = anti_join(tidyTweets, stop_words, by="word")
View(cleanTweets[cleanTweets$tweetId == 1604, ])

mySentiments = get_sentiments("afinn");
mySentiments = mutate(mySentiments, word = wordStem(word))
mySentiments = mySentiments[!duplicated(mySentiments),]

cleanTweets = mutate(cleanTweets, word = wordStem(word))

str(cleanTweets)
View(cleanTweets)
#create negative, positive words
sentimentTweets = inner_join(cleanTweets, mySentiments, by="word")
str(sentimentTweets)

tweets_sentiments = group_by(sentimentTweets, tweetId)
#compute tweet score
tweetScore = summarise(tweets_sentiments, tweetScore=sum(score) / n())
#attach tweetScore to tweet-word table
sentimentTweets = inner_join(sentimentTweets, tweetScore, by = "tweetId")

min(tweetScore$tweetScore)
max(tweetScore$tweetScore)

testT = left_join(tweetScore, tweets_sentiments, by = "tweetId")

# cluster tweets based on its score
positiveTweets = sentimentTweets[sentimentTweets$tweetScore >= 1,]
negativeTweets = sentimentTweets[sentimentTweets$tweetScore <= -1,]
neutralTweets = sentimentTweets[sentimentTweets$tweetScore < 1 & sentimentTweets$tweetScore > -1,]


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
NUMBER_TOPICS_POSITIVE = 3
NUMBER_TOPICS_NEGATIVE = 3
NUMBER_TOPICS_NEUTRAL = 3


# positive topics
positiveTopTerms = getTopicAndPopularTerms(positiveTweets, NUMBER_TOPICS_POSITIVE, NUMBER_POPULAR_TERMS)
View(positiveTopTerms)
plotTermsAndTopics(positiveTopTerms)

length(unique(positiveTweets$tweetId))

length(unique(negativeTweets$tweetId))

length(unique(neutralTweets$tweetId))

#negative
negativeTopTerms = getTopicAndPopularTerms(negativeTweets, NUMBER_TOPICS_NEGATIVE, NUMBER_POPULAR_TERMS)
View(negativeTopTerms)
plotTermsAndTopics(negativeTopTerms)

#netral
neutralTopTerms = getTopicAndPopularTerms(neutralTweets, NUMBER_TOPICS_NEUTRAL, NUMBER_POPULAR_TERMS)
View(neutralTopTerms)
plotTermsAndTopics(neutralTopTerms)

str(positiveTweets)

nrow(positiveTweets)
length(positiveTweets)
count(positiveTweets)

## ------- overallll

nrow(tweetScore)
ggplot(tweetScore, aes(tweetScore) ) +
  geom_histogram(color="white", binwidth = 0.03)

tweetAndScore = inner_join(tweetScore, tweets, by = "tweetId")

tweetAndScore = tweetAndScore[ order(tweetAndScore$tweetScore) , ]

View(tweetAndScore)

write.csv(tweetAndScore, file = "tweet.score.csv")
## ------------ NEGATIVE -------------------------

negativeTweetScores = filter(tweetScore, tweetScore <= -1)
nrow(negativeTweetScores)

ggplot(negativeTweetScores, aes(tweetScore) ) +
  geom_histogram(color="white", binwidth = 0.02)


testNegativeTweets = filter(negativeTweetScores, tweetScore == -2)
nrow(testNegativeTweets)

negativeTweetFull = inner_join(testNegativeTweets, tweets, by = "tweetId")

View(negativeTweetFull)

## ----------- POSITIVE -------------------------
ggplot(positiveTweets, aes(tweetScore) ) +
  geom_histogram(color="white", binwidth = 0.05)

ggplot(positiveTweets, aes(tweetScore)) +
  geom_density()


ggplot(data=positiveTweets) +
  geom_histogram( aes(tweetScore, ..density..), bins=50 ) +
  geom_density( aes(tweetScore, ..density..) ) +
  geom_rug( aes(tweetScore) )




test_sentiments = get_sentiments("afinn");

View(test_sentiments[test_sentiments$score == 0, ])

test_sentiments[test_sentiments$word == "like",]

fluShotTweets = filter(tweetAndScore, grepl("shot", tweet, ignore.case = TRUE))
nrow(fluShotTweets)

View(fluShotTweets)

write.csv(fluShotTweets, file = "flushot.tweets.csv")
#### analysis

sentimentTweets %>%
  count(word, sort = TRUE)

library(devtools)
install_github("dgrtwo/widyr")
library(widyr)

## word pare analysis
str(sentimentTweets)
tweet_word_pairs = sentimentTweets %>% 
  pairwise_count(word, tweetId, sort = TRUE, upper = FALSE)

tweet_word_pairs


library(ggplot2)
library(igraph)
library(ggraph)

set.seed(1234)
tweet_word_pairs %>%
  filter(n >= 80) %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = "cyan4") +
  geom_node_point(size = 5) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines")) +
  theme_void()


