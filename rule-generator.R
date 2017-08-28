## rules generation
library(arules)


tweets = read.csv("flushot.tweets.csv", stringsAsFactors = FALSE)

str(tweets)

# data("Adult")
# ## find itemsets that only contain small or large income and young age
# is <- apriori(Adult, parameter = list(support= 0.1, target="frequent"),
#               appearance = list(items = c("income=small", "income=large", "age=Young"),
#                                 default="none"))
# arules::inspect(head(is))
# 
# a_df <- data.frame(
#   Tags = as.factor(c("scala",
#                      "ios, button, swift3, compiler-errors, null",
#                      "c#, pass-by-reference, unsafe-pointers",
#                      "spring, maven, spring-mvc, spring-security, spring-java-config",
#                      "android, android-fragments, android-fragmentmanager",
#                      "scala, scala-collections",
#                      "python-2.7, python-3.x, matplotlib, plot"))
# )
# 
# arules::inspect(head(Adult))

