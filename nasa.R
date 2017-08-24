library(jsonlite)

metadata = fromJSON("nasa-data.json")
names(metadata$dataset)
str(metadata)

class(metadata$dataset$title)

class(metadata$dataset$description)

class(metadata$dataset$keyword)
