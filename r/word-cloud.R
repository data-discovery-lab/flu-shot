library(wordcloud2)
library(SnowballC)

words = read.csv(file = "tweet-word-transaction.csv", sep = ",")
words$item[words$item == 'dead'] = 'die'
words$item[words$item == 'paralyzed'] = 'paralyze'


str(words)

## visualize negative flu-shot words
wordFreq = count(words[words$negativeFlushot == 1,], item, sort = TRUE)

colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordcloud2(data = wordFreq)



## visualize non-negative flu shot word
wordFreq = count(words[words$negativeFlushot == 0,], item, sort = TRUE)

colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordcloud2(data = wordFreq)