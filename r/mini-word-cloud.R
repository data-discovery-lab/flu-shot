library(wordcloud2)
library(SnowballC)
library(dplyr)
library(tidytext)

setwd("~/TTU-SOURCES/flu-shot")

text <- c("Flu shots do not work",
          "Get the flu shot they said. You won't get sick",
          "I work at a hospital and we have to get the flu shot. I'm only person in family to not get sick this year",
          "I haven't had any type of flu shot or vaccine in years. I don't trust em",
          "Another precious child dies from flu complications after getting flu shot!",
          "Flu-related death toll doubles in Wash State"
          )



text <- c("flu shot do ineffective",
"get the flu shot they said you will avoid sick",
"i work at a hospital and we have to get the flu shot I'm only person in family to avoid sick this year",
"have not had any type of flu shot or flu shot in years i do suspect em",
"Another precious child die from flu complications after getting flu shot!",
"Flu-related die toll doubles in Wash State"
)



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

custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "person",
                                          lexicon = "custom"))
custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "family",
                                          lexicon = "custom"))

custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "vaccine",
                                          lexicon = "custom"))

custom_stop_words <- bind_rows(custom_stop_words,
                               data_frame(word = "hospital",
                                          lexicon = "custom"))

words =text_df %>%
  unnest_tokens(word, text) %>%
  anti_join(custom_stop_words, by = c("word" = "word"))

## visualize negative flu-shot words
wordFreq = count(words, word, sort = TRUE)
wordFreq

colnames(wordFreq) = c("word", "freq")
wordcloud2(data = wordFreq)

