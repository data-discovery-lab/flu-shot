text <- c("The regular early morning yell of horror was the sound of",
          "Arthur Dent waking up and suddenly remembering where he",
          "was. It wasn't just that the cave was cold, it wasn't just",
          "that it was damp and smelly. It was the fact that the cave",
          "was in the middle of Islington and there wasn't a bus due",
          "for two million years.")
text <- paste(text, collapse = " ")

library(reticulate)
use_python("/Users/longnguyen/anaconda/bin/python")

library(cleanNLP)
init_spaCy()
obj <- run_annotators(text, as_strings = TRUE)

names(obj)

get_document(obj)


get_token(obj)


library("arules")
data("Groceries")

Groceries

rules <- apriori(Groceries, parameter = list(support = .001))

rules

inspect(head(sort(rules, by = "lift"), 3))