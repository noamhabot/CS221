setwd("~/Google Drive/Stanford/Stanford Y2 Q1/CS 221/Final Project")
df1 <- read.csv("wine.csv", stringsAsFactors=FALSE)
#df1$description <- as.character(df1$description)
set.seed(123)

# randomly sample to make computations easier
#n <- 1000
#df <- df1[sample(nrow(df1), n),]
df <- df1

total <- ""

print(paste("Num Rows:", nrow(df)))
for (desc in df$description) {
  desc <- gsub("–", " ", desc)
  desc <- gsub("[[:punct:]]", "", desc)
  desc <- tolower(desc)
  total <- paste(total, desc)
}

total <- substr(total, 2, nchar(total))

words <- strsplit(total, " ")[[1]]
firstTenThousand <- sort(table(words), decreasing = TRUE)[1:10000]



corpus <- 