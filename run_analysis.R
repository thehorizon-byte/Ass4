
###### Getting And Cleaning Data - FINAL ASSIGNMENT 

# Step 1: load library
library(dplyr) 

# Step 2: download the zip file
if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/Dataset.zip",method="curl")

# Step 3: unzip the file
unzip(zipfile="./data/Dataset.zip", exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")

# Step 4.1: read train data 
x_train   <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
y_train   <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE) 
sub_train <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)

# Step 4.2: read test data 
x_test    <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
y_test    <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
sub_test  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

# Step 4.3: read features description 
features <- read.table(file.path(path_rf,"features.txt"),header = FALSE)

# Step 4.4: read activity labels 
activity_labels  <- read.table(file.path(path_rf,"activity_labels.txt"),header = FALSE)

### Step 5: merge the training and the test data sets
x_total     <- rbind(x_train,x_test)
y_total     <- rbind(y_train,y_test)
sub_total   <- rbind(sub_train,sub_test)

### Step 6: appropriately label the data set with descriptive variable name
names(x_total)   <- features[,2]
names(y_total)   <- "activity_id"
names(sub_total) <- "subject"
names(activity_labels) <- c("activity_id","activity")

names(x_total)  <-  gsub("Acc", "Accelerometer", names(x_total))
names(x_total)  <-  gsub("Gyro", "Gyroscope", names(x_total))
names(x_total)  <-  gsub("BodyBody", "Body", names(x_total))
names(x_total)  <-  gsub("Mag", "Magnitude", names(x_total))
names(x_total)  <-  gsub("^t", "Time", names(x_total))
names(x_total)  <-  gsub("^f", "Frequency", names(x_total))
names(x_total)  <-  gsub("tBody", "TimeBody", names(x_total))
names(x_total)  <-  gsub("-mean()", "Mean", names(x_total), ignore.case = TRUE)
names(x_total)  <-  gsub("-std()", "STD", names(x_total), ignore.case = TRUE)
names(x_total)  <-  gsub("-freq()", "Frequency", names(x_total), ignore.case = TRUE)
names(x_total)  <-  gsub("angle", "Angle", names(x_total))
names(x_total)  <-  gsub("gravity", "Gravity", names(x_total))

### Step 7: extract the measurements on the mean and SD for each measurement
x_total_selected  <- x_total[,grep("mean|std",features[,2])]

### Step 8: merge all data together into one data frame
tidy_data <- cbind(sub_total,y_total,x_total_selected) 

# Step 9: use descriptive activity names to name the activities in the data set
tidy_data <- merge(activity_labels,tidy_data, by = "activity_id", all.x = TRUE)

# Step 10: deleting the redundant column "activity_id" and making sure "subject" is in first column
tidy_data <- tidy_data[,c(3,2,4:82)] 

# Step 11: create independent tidy data set with the average of each variable for each activity and each subject
tidy_data <- aggregate(.~ subject + activity,tidy_data, mean)
