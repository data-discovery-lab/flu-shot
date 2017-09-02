
# this code will convert classified tweets into transaction single format.
# each tweet is a transaction id and each important word in a transaction is an item.

set.seed(123)
library(tidytext)


#setwd("~/TTU-SOURCES/flu-shot")
setwd("~/Desktop/SOURCES/flue-shot")

tweets = read.csv("predicted-flu-shot.csv", stringsAsFactors = FALSE)

str(tweets)

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

library(reticulate)
use_python("/Users/longnguyen/anaconda/bin/python")
library(cleanNLP)
init_spaCy()

obj <- run_annotators(tweets$tweet, as_strings = TRUE)

names(obj)

get_document(obj)


transactions = get_token(obj)

stopWordList = c("flu", "shot", "shots", "feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "flushot", "be", "shoot", "-PRON-", stop_words$word)

meanfulUniversalPartOfSpeech = c("ADJ", "VERB")

transactions = transactions %>% 
  dplyr::filter(!lemma %in% stopWordList,
                str_detect(word, "[a-z]")) %>% 
  dplyr::filter(upos %in% meanfulUniversalPartOfSpeech,
                str_detect(word, "[a-z]"))

transactionData <- transactions[, c('id', 'lemma')]

colnames(transactionData) = c('transactionId', 'item')
str(transactionData)



myAdditionalItems = as.data.frame(unique(transactionData$transactionId))
colnames(myAdditionalItems) = c('transactionId')
myAdditionalItems$item = 'negative-flu-shot'

str(myAdditionalItems)

finalTransactionData <- rbind(transactionData, myAdditionalItems)

write.csv(finalTransactionData, file = "tweet-transaction.csv")
