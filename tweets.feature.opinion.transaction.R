
tweets = read.csv("flushot.tweets.csv", stringsAsFactors = FALSE)

str(tweets)

text <- c("hello shit help poor become the no matter what",
          "was in the middle of Islington and there wasn't a bus due",
          "for two million years.")
#text <- paste(text, collapse = " ")

library(reticulate)
use_python("/Users/longnguyen/anaconda/bin/python")

library(cleanNLP)
init_spaCy()
obj <- run_annotators(text, as_strings = TRUE)

names(obj)

get_document(obj)


tokens = get_token(obj)

View(tokens)