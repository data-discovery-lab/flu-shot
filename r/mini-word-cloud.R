library(wordcloud2)
library(SnowballC)
library(dplyr)
library(tidytext)

setwd("~/TTU-SOURCES/flu-shot")

# text <- c("Flu shots do not work",
#           "Get the flu shot they said. You won't get sick",
#           "I work at a hospital and we have to get the flu shot. I'm only person in family to not get sick this year",
#           "I haven't had any type of flu shot or vaccine in years. I don't trust em",
#           "Another precious child dies from flu complications after getting flu shot!",
#           "Flu-related death toll doubles in Wash State",
#           "nobody dies because of flu shot this year",
#           "flu shot is not hurt at all"
#           )

text <- c("flu shot do ineffective",
"get the flu shot they said you will avoid sick",
"i work at a hospital and we have to get the flu shot I'm only person in family to avoid sick this year",
"i have not had any type of flu shot or flu shot in years i do suspect em",
"Another precious child die from flu complications after getting flu shot!",
"flu-related die toll doubles in Wash State",
"everyone survive because of flu shot this year",
  "flu shot is painless at all"
)

additionalStopWords = c("flu", "shot", "shots", "person", "family", "hospital", "hospital")
additionalStopWords_df <- data_frame(lexicon="custom", text = additionalStopWords)


custom_stop_words = stop_words
custom_stop_words <- bind_rows(custom_stop_words, additionalStopWords_df)


text_df <- data_frame(line = 1:length(text), text = text)

words =text_df %>%
  unnest_tokens(word, text) %>%
  anti_join(custom_stop_words, by = c("word" = "word"))

## visualize negative flu-shot words
wordFreq = count(words, word, sort = TRUE)
wordFreq

colnames(wordFreq) = c("word", "freq")
wordcloud2(data = wordFreq)

