# R Script
# Course Project for Getting and Cleaning Data (Coursera)

## Check if "UCI HAR Dataset" or "getdata-projectfiles-UCI HAR Dataset.zip" 
## exists. If not, make sure .zip files is downloaded and then unzip it.
zip <- "getdata-projectfiles-UCI HAR Dataset.zip"
link <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2F
UCI%20HAR%20Dataset.zip"
if (!file.exists("UCI HAR Dataset")) {
        if (!file.exists(zip)) {
                download(url = link)
        } else {
                unzip(zip)
        }
}

# 1. Merges the training and the test sets to create one data set.
test <- list.files("UCI HAR Dataset/test", full.names = TRUE)
train <- list.files("UCI HAR Dataset/train", full.names = TRUE)
library(data.table)
## Merges the test set to one data table.
s1 <- read.table(test[2])  # 2947 1
x1 <- read.table(test[3])  # 2947 561
y1 <- read.table(test[4])  # 2947 1
k <- 1:2947
s1 <- data.table(k, s1)
x1 <- data.table(k, x1)
y1 <- data.table(k, y1)
sy1 <- merge(s1, y1, by = "k")
syx1 <- merge(sy1, x1, by = "k")
## Merges the training set to one data table.
s2 <- read.table(train[2])  # 7352 X 1
x2 <- read.table(train[3])  # 7352 X 561
y2 <- read.table(train[4])  # 7352 X 1
k <- 1:7352
s2 <- data.table(k, s2)
x2 <- data.table(k, x2)
y2 <- data.table(k, y2)
sy2 <- merge(s2, y2, by = "k")
syx2 <- merge(sy2, x2, by ="k")
## Converts and merges both the training and test sets to one data frame.
df1 <- as.data.frame(syx1)
df2 <- as.data.frame(syx2)
colnames(df1) <- paste("V", 0:563, sep = "")
colnames(df2) <- paste("V", 0:563, sep = "")
mer <- rbind(df2, df1)
mer <- mer[,2:564]  # 10299 X 563

# 2. Extracts only the measurements on the mean and standard deviation for each 
#    measurement.
## Only columns with names containing the exact character strings of "mean()" 
## and "std()" are chosen.
feat <- read.table("UCI HAR Dataset/features.txt")
feat <- as.matrix(feat)
feat <- feat[,2]
tar1 <- grep("mean()", feat, fixed = TRUE)
tar2 <- grep("std()", feat, fixed = TRUE)
ext <- mer[,c(tar1, tar2)]

# 3. Uses descriptive activity names to name the activities in the data set.
act <- read.table("UCI HAR Dataset/activity_labels.txt")
act <- as.matrix(act[,2])
act <- act[1:6, 1]
mer <- as.data.table(mer)
mer <- mer[,V2 := act[V2]]

# 4. Appropriately labels the data set with descriptive variable names.
names <- c("SubjectID", "Activity", feat)
names <- make.names(names, unique = TRUE)
names <- sub("BodyBody", "Body", names, fixed = TRUE)
setnames(mer, names)

# 5. From the data set in step 4, creates a second, independent tidy data set 
#    with the average of each variable for each activity and each subject.
library(dplyr)
mer2 <- group_by(mer, SubjectID, Activity)
mer2 <- summarise_each(mer2, funs(mean))
write.table(mer2, file = "UCI HAR Tidy Dataset.txt", row.name = FALSE)
## The tidy data set is created as "UCI HAR Tidy Dataset.txt" under the working 
## directory.
