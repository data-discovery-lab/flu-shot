library(widyr)
library(ggplot2)
library(igraph)
library(ggraph)
library(wordcloud2)
library(SnowballC)
library(stringr)
library(dplyr)
library(tidytext)
library(ggplot2)
library(igraph)
library(ggraph)

# without pre-processing data
#setwd("~/TTU-SOURCES/flu-shot")
setwd("~/Desktop/SOURCES/flue-shot")

preProcessing = FALSE
#without pre-processing
if (preProcessing == TRUE) {
  tweets = read.csv("data/convertedTweets.csv", stringsAsFactors = FALSE)
}

if (!preProcessing == TRUE) {
  ## assume the prediction is overfit
  tweets = read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)
  
}


cleanTweet = function(tweets) {
  replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
  unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
  
  tweets = tweets %>% 
    mutate(text = str_replace_all(tweet, replace_reg, ""))
  
  tweets$tweet = tweets$text
  tweets$text = NULL
  
  return(tweets)
}

#tweets = tweets[tweets$negativeFlushot == 1,]
tweets = cleanTweet(tweets)

str(tweets)
count(tweets)


additionalStopWords = c("feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "rt", "amp", "cdc", "feels")
additionalStopWords_df <- data_frame(lexicon="custom", word = additionalStopWords)


custom_stop_words = stop_words
custom_stop_words <- bind_rows(custom_stop_words, additionalStopWords_df)


words = tweets[tweets$negativeFlushot == 1,] %>%
  unnest_tokens(word, tweet) %>%
  anti_join(custom_stop_words, by = c("word" = "word")) %>%
  mutate(word = wordStem(word))

count(words, word, sort = TRUE) 

word_pairs <- words %>% 
  #filter(word == 'avoid' ) %>% 
  pairwise_count(word, user, sort = TRUE, upper = FALSE)  %>% 
  filter(n <= 20 )  %>% 
  filter(n >=3)




set.seed(1234)
edgeColor = ifelse(preProcessing, "darkred", "cyan4")

word_pairs %>%
  graph_from_data_frame() %>%
  ggraph(layout = "fr") +
  geom_edge_link(aes(edge_alpha = n, edge_width = n), edge_colour = edgeColor) +
  geom_node_point(size = 4) +
  geom_node_text(aes(label = name), repel = TRUE, 
                 point.padding = unit(0.2, "lines"),size=6)+
  theme_void()+
  theme(legend.text=element_text(size=16))