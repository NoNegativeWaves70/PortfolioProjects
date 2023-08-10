########################
# Loading Iris data set 
########################

#Method 1

library(datasets)
data("iris")

iris2 <- datasets::iris


#Method 2
install.packages("RCurl")

library(RCurl)
iris3 <- read.csv(text =
getURL("https://raw.githubusercontent.com/dataprofessor/data/master/iris.csv"))

#View the data
View(iris)

#############################
# Display summary statistics
#############################

# head() / tail()
head(iris, 5)
tail(iris, 5)

# summary()
summary(iris)
summary(iris$Sepal.Length)

# Check to see if there is any missing data
sum(is.na(iris))

# skimr() - expands on summary() by providing larger set of statistics
# install.packages("skimr")
# https://github.com/ropensci/skimr

install.packages("skimr")
library(skimr)
skim(iris) # Perform dkim to display summary statistics

# Group data by Species then perform skim
# Load "dplyr" if not done already
# Also kind of important to spell "dplyr" correctly.
# Don't ask me how I know...

install.packages("dplyr")
library(dplyr)

iris %>%
  dplyr::group_by(Species) %>%
  skim()

############################
# Quick data visualization
#
# R base plot()
############################

# Panel plots
plot(iris)
plot(iris, col = "red")                  

# Scatter plot
plot(iris$Sepal.Width, iris$Sepal.Length)

plot(iris$Sepal.Width, iris$Sepal.Length, col = "red")

plot(iris$Sepal.Width, iris$Sepal.Length, col = "red", xlab = "Sepal width", ylab = "Sepal length")

# Histogram
hist(iris$Sepal.Width)

hist(iris$Sepal.Width, col = "red")


# Feature plots
# https://www.machinelearningplus.com/machine-learning/caret-package/

install.packages("caret")
library(caret)

featurePlot(x = iris[,1:4], 
            y = iris$Species, 
            plot = "box",
            strip=strip.custom(par.strip.text=list(cex=.7)),
            scales = list(x = list(relation="free"), 
                          y = list(relation="free")))

