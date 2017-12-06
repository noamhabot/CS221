rm(list = ls())

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


###### METRICS NEW ########
###########################
n = 100#nrow(prediction)
m = ncol(prediction)
startIndex <- 7 # by default, this is 7
recall = rep(0, n)
precision = rep(0, n)
for (i in 1:n) {
  added_probability = 0.2
  thisObsKeywords = test[i, startIndex:(m+startIndex-1)]
  predictions <- round(prediction[i, 1:m]+added_probability)
  acc = table(Predictions = as.numeric(predictions), TrueLabels = as.numeric(thisObsKeywords))
  TN = acc[1]
  FP = acc[2]
  FN = acc[3]
  TP = acc[4]
  precision[i] = TP / (TP + FP)
  recall[i] = TP / (TP + FN)
}

###### METRICS ########
#######################
totalPredictions <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_totalfirst1000.rds")
prediction = totalPredictions
n = 100#nrow(prediction)
m = ncol(prediction)
startIndex <- 7 # by default, this is 7
recall = rep(0, n)
precision = rep(0, n)
for (i in 1:n) {
  print(paste("Iteration:", i, "out of", n))
  
  # metric 1
  in_review = 0
  in_prediction = 0
  thisObsKeywords = test[i, startIndex:(m+startIndex-1)]
  predictions <- round(prediction[i, 1:m]+0.2)
  
  in_review = sum(thisObsKeywords)
  in_prediction = sum(bitwAnd(as.numeric(thisObsKeywords), as.numeric(predictions)))
  
  recall[i] = in_prediction / in_review
  
  # metric 2
  in_prediction = 0
  not_in_review = 0
  
  in_prediction = sum(predictions)
  not_in_review = as.numeric(table(as.numeric(predictions)-as.numeric(thisObsKeywords))["1"])
  
  precision[i] = 1-(not_in_review / in_prediction)
}
recall[is.nan(m1)]=NA
precision[is.nan(m2)]=NA #### WAS WAS WAS m2_test[is.nan(m1)]=NA

recallScore = mean(recall, na.rm = TRUE)
precisionScore = mean(precision, na.rm=TRUE)

Fscore = (2*precisionScore*recallScore)/(precisionScore+recallScore)

print(paste("Mean of recall:", recallScore))
print(paste("Mean of precision:", precisionScore))

















##### RUNNING KEYWORDS


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











