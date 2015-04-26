# clear everything out
rm(list=ls());

# set working directory
setwd('/nfs/science/raleys/donso/sandbox')

# bring in needed packages
library("data.table")
library("reshape2")

# read in activity labels file
activity_labels <- read.table("activity_labels.txt")[,2]

# read in column names
features <- read.table("features.txt")[,2]
features

# Extract only relevant features
extract_features <- grepl("mean|std|Mean", features)
extract_features

# Read in X_test + y_test data
X_test <- read.table("X_test.txt")
y_test <- read.table("y_test.txt")
# Read in subject definitions for test data
subject_test <- read.table("subject_test.txt")

# add in the features
names(X_test) = features
# drop variables that arent mean or std
X_test = X_test[,extract_features]

# apply the activity labels
y_test[,2] = activity_labels[y_test[,1]]

# names for the y and subject test tables
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# cbind the test data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)

# delete out test data that was just used in cbind
rm(list = c("subject_test", "y_test", "X_test"))

# read in the train data
X_train <- read.table("X_train.txt")
y_train <- read.table("y_train.txt")
subject_train <- read.table("subject_train.txt")

# add the names 
names(X_train) = features
# keep only the main and std features
X_train = X_train[,extract_features]

# read in the activity data 
y_train[,2] = activity_labels[y_train[,1]]

# names for the y and subject train tables
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# cbind the train data f rames
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# delete out train data that was just used in cbind
rm(list = c("subject_train", "y_train", "X_train"))

# stack the test and train data
full_data = rbind(test_data, train_data)
summary(full_data)

# delete out data that was just used in cbind
rm(list = c("test_data","train_data"))

# list out ID labels
id_labels=c("subject", "Activity_ID", "Activity_Label")
data_labels=setdiff(colnames(full_data), id_labels)

# melt function - 
prep_data=melt(full_data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function - mean by subject and Activity_Label
tidy_out_data=dcast(prep_data, subject + Activity_Label ~ variable, mean)

# clear out some of the characters from the tidy data names
sub("()-","",names(tidy_out_data),)

# lower case for tidy data output
tolower(names(tidy_out_data))

# summary of tidy data
summary(tidy_out_data)

# names from tidy data
names(tidy_out_data)

# head from tidy data
head(tidy_out_data,5)

# struture of tidy data
str(tidy_out_data)

# output the tidy data txt file
write.table(tidy_out_data, file = "./tidy_out_data.txt")
