# Load required libraries

library(tm)
library(RTextTools)
library(e1071)
library(dplyr)
library(caret)
# Library for parallel processing
library(doMC)
library(SnowballC)
library(stringr)

registerDoMC(cores=detectCores())  # Use all available cores



setwd("~/TTU-SOURCES/flu-shot")


# load the data
df<- read.csv("labeled-tweet-flu-shot.csv", stringsAsFactors = FALSE)
glimpse(df)
df$class = df$negativeFlushot
df$text = df$tweet

cleanTweet = function(tweets) {
  replace_reg = "https://t.co/[A-Za-z\\d]+|http://[A-Za-z\\d]+|&amp;|&lt;|&gt;|RT|https"
  unnest_reg = "([^A-Za-z_\\d#@']|'(?![A-Za-z_\\d#@]))"
  
  tweets = tweets %>% 
    mutate(text = str_replace_all(tweet, replace_reg, ""))
  
  tweets$tweet = tweets$text
  tweets$text = NULL
  
  return(tweets)
}

df = cleanTweet(df)

# randomize the data set
set.seed(1)
df <- df[sample(nrow(df)), ]
df <- df[sample(nrow(df)), ]
glimpse(df)

# Convert the 'class' variable from character to factor.
df$class <- as.factor(df$class)


#tokenize
corpus <- Corpus(VectorSource(df$text))
# Inspect the corpus
corpus
## <<VCorpus>>
## Metadata:  corpus specific: 0, document level (indexed): 0
## Content:  documents: 2000
inspect(corpus[1:3])

# data clean up - common
corpus.clean <- corpus %>%
  tm_map(content_transformer(tolower)) %>% 
  tm_map(content_transformer(removePunctuation)) %>%
  tm_map(content_transformer(removeNumbers)) %>%
  tm_map(content_transformer(removeWords),  c("flu", "shot", "shots", "feel", "like", "thank", "can", "may", "get", "got", "gotten", "think", "flushot", stopwords("english"))) %>%
  tm_map(content_transformer(stripWhitespace)) %>%
  tm_map(stemDocument)


inspect(corpus.clean[1:3])

# create Document Term Matrix
dtm <- DocumentTermMatrix(corpus.clean)
# Inspect the dtm
inspect(dtm[40:50, 10:15])


library(caTools)
set.seed(456)

# create split with 70% is TRUE (this will be used as training set)
spl = sample.split(df$class, SplitRatio = 0.7)
df.train = subset(df, spl == TRUE)
df.test = subset(df, spl == FALSE)
## trainSparse now has 700 rows (70%) 

#  create 75:25 partitions of the dataframe, corpus and document term matrix for training and testing purposes.
#df.train <- df[1:700,]
#df.test <- df[701:1000,]

nrow(df.train)


dtm.train <- subset(as.data.frame(as.matrix(dtm)), spl == TRUE)
dtm.test <- subset(as.data.frame(as.matrix(dtm)), spl == FALSE)
#dtm.train <- dtm[1:700,]
#dtm.test <- dtm[701:1000,]

inspect(dtm.train[1:3, 1:10])
nrow(dtm.train)

#corpus.clean.train <- corpus.clean[1:700]
#corpus.clean.test <- corpus.clean[701:1000]

corpus.clean.train <- subset(corpus.clean, spl == TRUE) 
corpus.clean.test <- subset(corpus.clean, spl == FALSE) 



# feature selection
# We reduce the number of features by ignoring words which appear in less than five reviews.
dim(dtm.train)

fivefreq <- findFreqTerms(dtm.train, 5)
length((fivefreq))

# Use only 5 most frequent words (fivefreq) to build the DTM
dtm.train.nb <- DocumentTermMatrix(corpus.clean.train, control=list(dictionary = fivefreq))
dim(dtm.train.nb)

# create test DTM
dtm.test.nb <- DocumentTermMatrix(corpus.clean.test, control=list(dictionary = fivefreq))
dim(dtm.train.nb)

str(dtm.train.nb)

inspect(dtm.train.nb[1:5, 1:10])

# Function to convert the word frequencies to yes (presence) and no (absence) labels
convert_count <- function(x) {
  y <- ifelse(x > 0, 1,0)
  y <- factor(y, levels=c(0,1), labels=c("No", "Yes"))
  return (y)
}

# Apply the convert_count function to get final training and testing DTMs
# apply() allows us to work either with rows or columns of a matrix.
# MARGIN = 1 is for rows, and 2 for columns
trainNB <- apply(dtm.train.nb, 2, convert_count)
testNB <- apply(dtm.test.nb, 2, convert_count)
str(dtm.train.nb)
str(trainNB)
#inspect(trainNB[40:50, 10:15])

# Train the classifier
# Since Naive Bayes evaluates products of probabilities, we need some way of assigning non-zero probabilities 
# to words which do not occur in the sample. We use Laplace 1 smoothing to this end.
system.time( classifier <- naiveBayes(trainNB, df.train$class, laplace = 1) )

# Use the NB classifier we built to make predictions on the test set.
system.time( pred <- predict(classifier, newdata=testNB) )

# Create a truth table by tabulating the predicted class labels with the actual class labels 
table("Predictions"= pred,  "Actual" = df.test$class )

# Prepare the confusion matrix
conf.mat <- confusionMatrix(pred, df.test$class)
conf.mat

conf.mat$byClass

conf.mat$overall
conf.mat$overall['Accuracy']


