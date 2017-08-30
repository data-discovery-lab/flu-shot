setwd("~/Desktop/SOURCES/flue-shot/data/converted/2014")

files = list.files(pattern="*.csv")
# for (i in 1:length(files)) {
#   ##assign(temp[i], read.csv(temp[i]))
#   print(files[i])
# }

myData = do.call(rbind, lapply(files, function(x) read.csv(x, stringsAsFactors = FALSE)))
nrow(myData)
write.csv(myData, file = "all-tweets-2014.csv")