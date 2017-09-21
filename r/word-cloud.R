library(wordcloud2)
library(SnowballC)
library(stringr)

# without pre-processing data
setwd("~/TTU-SOURCES/flu-shot")

tweets = read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)

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

additionalStopWords = c("flu", "shot", "shots", "feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "flushot")
additionalStopWords_df <- data_frame(lexicon="custom", word = additionalStopWords)


custom_stop_words = stop_words
custom_stop_words <- bind_rows(custom_stop_words, additionalStopWords_df)


words = tweets %>%
  unnest_tokens(word, tweet) %>%
  anti_join(custom_stop_words, by = c("word" = "word")) %>%
  mutate(word = wordStem(word))


str(words)

## visualize negative flu-shot words
wordFreq = count(words[words$negativeFlushot == 1,], word, sort = TRUE) %>%
  filter(n >= 3) 
  
colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordcloud2(data = wordFreq)
