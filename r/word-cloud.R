library(wordcloud2)
library(SnowballC)

words = read.csv(file = "tweet-word-transaction.csv", sep = ",")

str(words)
wordFreq = count(words[words$negativeFlushot == 1,], item, sort = TRUE)

colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordcloud2(data = wordFreq)




wordFreq = count(words[words$negativeFlushot == 0,], item, sort = TRUE)

colnames(wordFreq) = c("word", "freq")

str(wordFreq)

wordcloud2(data = wordFreq)