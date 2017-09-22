library(wordcloud2)
library(SnowballC)
library(stringr)
library(ggplot2)

setwd("~/TTU-SOURCES/flu-shot")

# without pre-processing data
#tweets = read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)

# processed tweets
  tweets = read.csv("data/convertedTweets.csv", stringsAsFactors = FALSE)


cleanTweet = function(tweets) {
  replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
  unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
  
  tweets = tweets %>% 
    mutate(text = str_replace_all(tweet, replace_reg, ""))
  
  tweets$tweet = tweets$text
  tweets$text = NULL
  
  return(tweets)
}

tweets = cleanTweet(tweets)

str(tweets)

additionalStopWords = c("flu", "shot", "shots", "feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "flushot", "rt", "amp", "cdc")
additionalStopWords_df <- data_frame(lexicon="custom", word = additionalStopWords)


custom_stop_words = stop_words
custom_stop_words <- bind_rows(custom_stop_words, additionalStopWords_df)


words = tweets %>%
  unnest_tokens(word, tweet) %>%
  anti_join(custom_stop_words, by = c("word" = "word")) 
  # mutate(word = wordStem(word))


str(words)

## visualize negative flu-shot words
wordFreq = count(words[words$negativeFlushot == 1,], word, sort = TRUE) 

colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordFreq = wordFreq %>%
  filter(freq >=7 ) %>%
  mutate(word = reorder(word, freq))

ggplot(data = wordFreq, aes(word, freq)) + 
  geom_col(fill = "darkred") + 
  coord_flip() + 
  labs(x = "Word \n", y = "\n Count", title = "Frequent words in text") +
  geom_text(aes(label = freq), hjust = 1.2, colour = "white", fontface = "bold") + 
  theme(plot.title = element_text(hjust = 0.5), 
        axis.title.x = element_text(face = "bold", colour = "darkblue", size = 12),
        axis.title.y = element_text(face = "bold", colour = "darkblue", size = 12))
  


