setwd("C:/Users/Redirection/DINGRU5/Desktop")
custData_7 = read.table("Batch1/custData_20161231_7.txt", header = TRUE, sep = "\t")
dim(custData_7)
head(custData_7)


## for data check purpose run the following
apply(custData_7,2,function(col)sum(is.na(col))/length(col))

######################################################
#Delete the plank Field n Product Indication
complete_sample = subset(custData_7, !(is.na(custData_7$RET_MFN_IND) | is.na(custData_7$PAC_IND)))
dim(complete_sample)
summary(complete_sample)

####couple fields that still NAs#######################
plot(density(complete_sample$AGE_YR[!is.na(complete_sample$AGE_YR)]))

###Deal with the missing value###
#install.packages('Hmisc')
library(Hmisc) 
set.seed(0)
complete_sample$AGE_YR = impute(complete_sample$AGE_YR, "random") 

plot(density(complete_sample$AGE_YR), col = "red", main = "Imputation Random for Age") 
#legend("topright", c("Original", "Mean Imputed", "Random Imputed"), col = c("blue", "red", "green"), lwd = 2) 

train = sample(1:nrow(complete_sample), 100000*nrow(complete_sample)/nrow(complete_sample)) 

complete_sample6 <- complete_sample[train,] 
testdata_batch6 <- complete_sample[-train,] 
dim(complete_sample6)
dim(testdata_batch6)
write.csv(complete_sample6, "complete_sample6.csv")
write.csv(testdata_batch6, "testdata_batch6.csv")
