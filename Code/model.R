library(data.table)
library(caTools)

## Read in the big data set however necessary. 
#data = data.table(read.csv("~/Downloads/dataset.csv"), sep = ',', header = FALSE, fill = TRUE)
#saveRDS(data, "~/Documents/cs221/CS221FinalProject/data.rds")
data = readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/data.rds")
data_ = subset(data, select=c(2,4,5,6,7,8,9,10,11,12:ncol(data)))
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

set.seed(1)
split = sample.split(data_s$flavors, SplitRatio = 0.8)
train = subset(data_s, split == TRUE)
test = subset(data_s, split == FALSE)




#range = 108:357
#range = 358:507
#range = 508:1007
prediction = as.data.table(matrix(nrow = nrow(test), ncol = length(range)))
colnames(prediction) = colnames(test)[range]
for (i in range) {
  print(i)
  thisVariable <- names(train)[i]
  model = glm(as.matrix(train[, get(thisVariable)]) ~ points+price+country+province+region_1+variety, data = train, family = binomial(logit))
  prediction[, thisVariable] = predict(model, newdata = test, type = "response")
}
#saveRDS(prediction, "~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/predictions_108_357.rds")






library(doMC)
registerDoMC()
options(cores=7)
r <- foreach(i=508:1007, .combine=list) %dopar% {
  thisVariable <- names(train)[i]
  model = glm (as.matrix(train[, get(thisVariable)]) ~ points+price+country+province+region_1+variety, data = train, family = binomial(logit))
  prediction = predict(model, newdata = test, type = "response")
  #err = 1 - sum((prediction > 0.5) == (test[, get(thisVariable)] > 0.5))/nrow(test)
  l = list(prediction)
  names(l)[1] = thisVariable
  l
}
#saveRDS(r, "~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/predictions_2.rds")
r = readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/predictions_508_1007.rds")

# convert "r" to the nice format of the data
newDF <- data.frame(rep(1,nrow(test)))
# first one
first <- paste("r", paste(rep("[[1]]",499), collapse=""), "", sep="")
newDF[,names(eval(parse(text = first)))] <- eval(parse(text = first))[[1]]
# from 498 to 1
for (i in 498:1) {
  varText <- paste(rep("[[1]]",i), collapse="")
  varText <- paste("r", varText, "[[2]]", sep="")
  newDF[,names(eval(parse(text = varText)))] <- eval(parse(text = varText))[[1]]
}
# last one:
varText <- "r[[2]]"
newDF[,names(eval(parse(text = varText)))] <- eval(parse(text = varText))[[1]]

newDF <- newDF[,-(1),drop=FALSE] # delete first column
pred5081007 <- newDF
saveRDS(pred5081007, "~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/predictions_508_1007.rds")






###### METRICS ########
#######################

n = nrow(prediction)
m = ncol(prediction)
startIndex <- 508
m1 = rep(0, n)
m1_test = rep(0, n)
for (i in 1:100) {
  print(i)
  in_review = 0
  in_prediction = 0
  thisObsKeywords = test[i, startIndex:(m+startIndex-1)]
  predictions <- round(prediction[i, 1:m]+0.25)
  
  in_review = sum(thisObsKeywords)
  in_prediction = sum(bitwAnd(as.numeric(thisObsKeywords), as.numeric(predictions)))
  
  m1_test[i] = in_prediction / in_review
}
m1_test[is.nan(m1)]=NA
mean(m1_test, na.rm = TRUE)

# Metric 2
m2 = rep(0, n)
m2_test = rep(0, n)
for (i in 1:n) {
  in_prediction = 0
  not_in_review = 0
  
  
  predictions <- round(prediction[i, 1:m]+0.25)
  in_prediction = sum(predictions)
  
  thisObsKeywords = test[i, startIndex:(m+startIndex-1)]
  not_in_review = as.numeric(table(as.numeric(predictions)-as.numeric(thisObsKeywords))["1"])
  
  m2_test[i] = not_in_review / in_prediction
}
m2_test[is.nan(m1)]=NA
mean(m2_test, na.rm = TRUE)









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
