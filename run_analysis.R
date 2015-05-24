library(plyr)
setwd("C:/MyData/R/GettingAndCleaningData")

#Download & Unzip File
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="rawData.zip")
unzip(zipfile="rawData.zip")

#Read all needed files and assign column names
features <- read.table("UCI HAR Dataset/features.txt")
colnames(features) <- c("featureId","featureName")
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activities) <- c("activityId","activityName")
      
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
colnames(x_train) <- features[,"featureName"]
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
colnames(y_train) <- "activityId"
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
colnames(subject_train) <- "subjectId";

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
colnames(x_test) <- features[,"featureName"]
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
colnames(y_test) <- "activityId"
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
colnames(subject_test) <- "subjectId";


#Create full traning & test matrix
train <- cbind(subject_train,x_train,y_train);
test <- cbind(subject_test,x_test,y_test)

#Merge everything into one dataset
allData <- rbind(train, test)

#find all column names with mean or std in them
columnNames <- names(allData)
wantedColumnsId <- grep("mean\\(\\)|std\\(\\)", columnNames)
wantedColumnsNames <- c("subjectId","activityId",columnNames[wantedColumnsId])

#Create subseted wanted tidy dataset
wantedData <- allData[,wantedColumnsNames]

#Add column - activityNames
wantedData = merge(wantedData,activities,by='activityId',all.x=TRUE);

#Clean variable names. 
names(wantedData)<-gsub("^t", "time", names(wantedData))
names(wantedData)<-gsub("^f", "frequency", names(wantedData))
names(wantedData)<-gsub("Acc", "Accelerometer", names(wantedData))
names(wantedData)<-gsub("Gyro", "Gyroscope", names(wantedData))
names(wantedData)<-gsub("Mag", "Magnitude", names(wantedData))
names(wantedData)<-gsub("BodyBody", "Body", names(wantedData))
#Create mean values per column
meanDataSet <- aggregate(wantedData, by=list(activity = wantedData$activityName, subject=wantedData$subjectId), mean)

#Clean up in data frame (avg mean and std have no meaning for these columns)
dropColumns <- c("activityId","subjectId","activityName")

#Write to file
write.table(meanDataSet[, !(colnames(meanDataSet) %in% dropColumns)], file = "meanDataSet.txt", sep="\t", row.name=FALSE)

