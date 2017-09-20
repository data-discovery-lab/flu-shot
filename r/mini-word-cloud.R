library(wordcloud2)
library(SnowballC)
library(dplyr)
library(tidytext)

setwd("~/TTU-SOURCES/flu-shot")

text <- c("Flu shots do not work",
          "Get the flu shot they said. You won't get sick",
          "I work at a hospital and we have to get the flu shot. I'm only person in family to not get sick this year"
          )



text_df <- data_frame(line = 1:length(text), text = text)

custom_stop_words = stop_words
custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "flu",
                                          lexicon = "custom"))
custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "shot",
                                          lexicon = "custom"))
custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "shots",
                                          lexicon = "custom"))


words =text_df %>%
  unnest_tokens(word, text) %>%
  anti_join(custom_stop_words, by = c("word" = "word"))

## visualize negative flu-shot words
wordFreq = count(words, word, sort = TRUE)
wordFreq

colnames(wordFreq) = c("word", "freq")
wordcloud2(data = wordFreq)

