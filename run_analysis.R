url <- getwd()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", paste(url, "/wearable.zip", sep = ""))
unzip("wearable.zip")
setwd(paste(url, "/UCI HAR Dataset", sep = ""))
library(dplyr)
library(data.table)

#feature <----> x_test x_train  This file contains variables' names
features <- read.table("features.txt")

#activity_labels <----> y_test y_train This file contains activities' names
activity_labels <- read.table("activity_labels.txt")

#subject_test <----> x_test
subject_test <- read.table("test/subject_test.txt")
subject_train <- read.table("train/subject_train.txt")

# test data
x_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")

# training data
x_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")

#1:Merges the training and the test sets to create one data set.
x <- data.table(rbind(x_test, x_train))

#2:Extracts only the measurements on the mean and standard deviation for each measurement.
extracted_features_logical_index <- grepl("mean|std", features[,2])
extracted_x <- x[,extracted_features_logical_index, with=FALSE]

#3:Appropriately labels the data set with descriptive variable names.
# I think give column name is step3 is more sensible
names(extracted_x) <- as.character(features[,2][extracted_features_logical_index])
subject <- data.table(rbind(subject_test, subject_train))
names(subject) <- c("subject")
subject_x <- cbind(subject,extracted_x)

#4:Uses descriptive activity names to name the activities in the data set
y <- data.table(rbind(y_test, y_train))
names(y) <- c("activity")
all <- cbind(y,subject_x)
all_temp <- merge(activity_labels, all, by.x = "V1", by.y = "activity")
all_temp <- data.table(all_temp[,names(all_temp)[-1]])
names(all_temp) <- c("activities",names(all_temp)[-1])

#5:From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
# planA: result <- all_temp %>% group_by(subject, activities) %>% summarize(mean = mean(names(all_temp)))
# planB: aggragate function
result <- all_temp %>% group_by(subject, activities) %>% summarize_each(funs(mean))
View(result)

#output file as txt extension
write.table(result,file = "Result.txt")
