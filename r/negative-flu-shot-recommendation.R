# read transaction files and create recommendation to "negative-flu-shot" and "none-negative-flu-shot"
library(arules)


tr <- read.transactions("negative-tweet-transaction.csv", format = "single", sep = ",", cols = c("transactionId", "item"), rm.duplicates = TRUE)


## find itemsets that only contain small or large income and young age
flushotRules <- apriori(tr, parameter = list(support= 0.01, target="rules"))

summary(flushotRules)

arules::inspect(head(flushotRules))
