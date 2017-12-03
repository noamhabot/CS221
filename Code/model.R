library(data.table)
library(caTools)

## Read in the big data set however necessary. 
#data = data.table(read.csv("~/Downloads/dataset.csv"), sep = ',', header = FALSE, fill = TRUE)
#saveRDS(data, "~/Documents/cs221/CS221FinalProject/data.rds")
#data = readRDS("~/Documents/cs221/CS221FinalProject/data.rds")
data_ = subset(data, select=c(2,4,5,6,7,8,9,10,11,12:36))
colnames(data_)

# 2/3 of observations dont have a region 2
data_$region_2 = NULL

# 1/3 of observations dont have a designation
data_$designation = NULL

# Basically one winery per row... not predictive
data_$winery = NULL

# Lots of blanks, remove rows with blank cells
data_[data_==""] = NA
data_s = na.omit(data_)

# Grab the most frequent categories
countries = tail(names(sort(table(data_s$country))), 15)
provinces = tail(names(sort(table(data_s$province))), 50) 
regions = tail(names(sort(table(data_s$region_1))), 50) 
varieties = tail(names(sort(table(data_s$variety))), 100)
# wineries = tail(names(sort(table(data_s$winery))), 1500)

data_s = data_s[country %in% countries & province %in% provinces & region_1 %in% regions & variety %in% varieties,]

# sample = sample.int(n = nrow(data_s), size = floor(.8*nrow(data_s)), replace = F)
# train = data[sample, ]
# test  = data[-sample, ]

split = sample.split(data_s$flavors, SplitRatio = 0.8)
train = subset(data_s, split == TRUE)
test = subset(data_s, split == FALSE)

range = 7:31
error = rep(0, length(range))
for (i in range) {
  thisVariable <- names(train)[i]
  model = glm (train[, get(thisVariable)] ~ points+price+country+province+region_1+variety, data = train, family = binomial)
  err = 1 - sum((predict(model, newdata = test, type = "response") > 0.5) == (test[, get(thisVariable)] > 0.5))/nrow(test)
  error[i-6] = err
  print(i-6)
  print(thisVariable)
}

preliminary_error = data.frame(names(train)[range], error)
write.csv(preliminary_error, "~/Documents/cs221/CS221FinalProject/preliminary_error.csv")

for (i in range) {
  cat("Prediciton error for \"",  names(train)[i],"\" on the test dataset is ", round(error[i],2), "\n", sep ="")
}

# Test Error 
1 - sum((predict(model, newdata = test, type = "response") > 0.5) == (test$flavors > 0.5))/nrow(test)

# Exploratory analysis

# logistic regression model
# model <- glm (flavors ~ country+designation+points+price, data = train, family = binomial)
# summary(model)

if (FALSE) {
  # Cardinality of categorical feature variables is too high
  head(data_[, .(cnt = .N), .(country)][order(-cnt)], 50) # top 15
  head(data_[, .(cnt = .N), .(designation)][order(-cnt)], 50) # 1/3 blank... delete
  sum(head(data_[, .(cnt = .N), .(province)][order(-cnt)], 50)$cnt) # 50
  sum(head(data_[, .(cnt = .N), .(region_1)][order(-cnt)], 50)$cnt) # maybe
  head(data_[, .(cnt = .N), .(region_2)][order(-cnt)], 50) # 2/3 blank 
  View(data.frame(data_[, .(cnt = .N), .(variety)][order(-cnt)])) # go to top 200
  View(data.frame(data_[, .(cnt = .N), .(winery)][order(-cnt)])) # 1500
}
