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
prediction <- readRDS("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/CS221FinalProject/Predictions/predictions_108_357.rds")


n = 10#nrow(prediction)
randomSample <- sample(1:nrow(prediction), n)
m = ncol(prediction)
startIndex <- 108 # by default, this is 7

recallMeans <- c()
specificityMeans <- c()
Fscores <- c()
for (added_probability in c(seq(-0.5, 0.4, 0.1), seq(0.4, 0.495, 0.005), seq(0.495, 0.5, 0.001))) {
  print(added_probability)

  recall = rep(0, n)
  precision = rep(0, n)
  specificity = rep(0, n)
  for (i in 1:n) {
    
    thisObsKeywords = test[randomSample[i], startIndex:(m+startIndex-1)]
    predictions <- round(prediction[randomSample[i], 1:m]+added_probability)
    acc = table(Predictions = as.numeric(predictions), TrueLabels = as.numeric(thisObsKeywords))
    TN = acc[1]
    FP = acc[2]
    FN = acc[3]
    TP = acc[4]
    
    if (nrow(acc) == 1) {
      if (rownames(acc)[1] == "1") {
        TN = 0
        FP = acc[1]
        FN = 0
        TP = acc[2]
      } else if (rownames(acc)[1] == "0") {
        TN = acc[1]
        FP = 0
        FN = acc[2]
        TP = 0
      }

    }
    if (TP == 0) {
      precision[i] = 0
    } else {
      precision[i] = TP / (TP + FP)
    }
    recall[i] = TP / (TP + FN)
    specificity[i] = TN/(TN+FP)
  }
  
  recall[is.nan(recall)]=NA
  precision[is.nan(precision)]=NA
  specificity[is.nan(specificity)]=NA
  
  recallScore = mean(recall, na.rm = TRUE)
  precisionScore = mean(precision, na.rm=TRUE)
  specificityScore = mean(specificity, na.rm=TRUE)
  
  Fscore = (2*precisionScore*recallScore)/(precisionScore+recallScore)
  Fscores <- c(Fscores, Fscore)
  
  print(paste("Mean of recall:", recallScore))
  print(paste("Mean of precision:", precisionScore))
  print(paste("Mean of specificity:", specificityScore))

  recallMeans <- c(recallMeans, recallScore)
  specificityMeans <- c(specificityMeans, specificityScore)
}
FPR <- (1-specificityMeans)
plot(recallMeans ~ FPR, xlim=c(0,1), ylim=c(0,1))
abline(0,1)
plot(Fscores[2:37])
#ggplot this bitch



FPR100 <- FPR
recall100 <- recallMeans













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











