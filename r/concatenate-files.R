setwd("~/Desktop/SOURCES/flue-shot/data/converted/2014")

files = list.files(pattern="*.csv")
# for (i in 1:length(files)) {
#   ##assign(temp[i], read.csv(temp[i]))
#   print(files[i])
# }

myData = do.call(rbind, lapply(files, function(x) read.csv(x, stringsAsFactors = FALSE)))
nrow(myData)

str(myData)

## remove dulicate user
myData = myData[!duplicated(myData[, c("user")]),]

## remove duplicate tweet
myData = myData[!duplicated(myData[, c("tweet")]),]

write.csv(myData, file = "all-tweets-2014.csv")


## create label data

labeledData = myData[sample(nrow(myData), 1000), ]
str(labeledData)
nrow(labeledData)

write.csv(labeledData, file = "labeled-tweets-2014.csv")
