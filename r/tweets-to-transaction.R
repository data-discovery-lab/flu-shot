
# this code will convert classified tweets into transaction single format.
# each tweet is a transaction id and each important word in a transaction is an item.

set.seed(123)
#setwd("~/TTU-SOURCES/flu-shot")
setwd("~/Desktop/SOURCES/flue-shot")

tweets = read.csv("predicted-flu-shot.csv", stringsAsFactors = FALSE)

str(tweets)



# data <- paste(
#   "trans1,item1", 
#   "trans2,item1",
#   "trans2,item2", 
#   sep ="\n")
# cat(data)
# write(data, file = "demo_single.csv")
# 
# ## read demo data
# tr <- read.transactions("demo_single.csv", format = "single", cols = c(1,2), sep=",")
# inspect(tr)
