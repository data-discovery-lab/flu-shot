library(arulesCBA)

data(iris)

iris


iris.disc <- as.data.frame(lapply(iris[1:4], function(x) discretize(x, categories=9)))

iris.disc


iris.disc$Species <- iris$Species

head(iris.disc)

?CBA

classifier <- CBA(Species ~ ., iris.disc, supp = 0.05, conf=0.9)

rules(classifier)

inspect(rules(classifier))

classes <- predict(classifier, iris.disc)

head(classes)

table(classes)

library(gmodels)

CrossTable(classes, iris.disc$Species, prop.chisq = FALSE, prop.r = FALSE, prop.c = FALSE)