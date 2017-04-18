setwd("C:/Users/Redirection/DINGRU5/Desktop")
SampleId = Sample$CUST_ID

custData_1 = read.csv("Batch2/custdata_201612_1.csv", header = TRUE)
custData_1[is.na(custData_1)] <- 0

custData_2 = read.csv("Batch2/custdata_201612_2.csv", header = TRUE)
custData_2[is.na(custData_2)] <- 0

custData_3 = read.csv("Batch2/custdata_201612_3.csv", header = TRUE)
custData_3[is.na(custData_3)] <- 0

custData_4 = read.csv("Batch2/custdata_201612_4.csv", header = TRUE)
custData_4[is.na(custData_4)]=0

custData_5 = read.csv("Batch2/custdata_201612_5.csv", header = TRUE)
custData_5[is.na(custData_5)] <- 0

custData_6 = read.csv("Batch2/custdata_201612_6.csv", header = TRUE)
custData_6[is.na(custData_6)] <- 0

custData_7 = read.csv("Batch2/custdata_201612_7.csv", header = TRUE)
custData_7[is.na(custData_7)] <- 0

## for data check purpose run the following
#apply(custData_1,2,function(col)sum(is.na(col))/length(col))


library("dplyr")
Sample1 = custData_1[custData_1$CUST_ID %in% SampleId, ]
Sample2 = custData_2[custData_2$CUST_ID %in% SampleId, ]
Sample3 = custData_3[custData_3$CUST_ID %in% SampleId, ]
Sample4 = custData_4[custData_4$CUST_ID %in% SampleId, ]
Sample5 = custData_5[custData_5$CUST_ID %in% SampleId, ]
Sample6 = custData_6[custData_6$CUST_ID %in% SampleId, ]
Sample7 = custData_7[custData_7$CUST_ID %in% SampleId, ]

transaction_sample2 = rbind(Sample4, Sample5, Sample6, Sample7) 

Sample_trans = rbind(transaction_sample, transaction_sample2)
dup_id = Sample_trans[!duplicated(Sample_trans$CUST_ID), ]

dim(Sample_trans)

write.csv(dup_id, "Sample_trans.csv")

##############################################################
## best practice
path = "C:/Users/Redirection/DINGRU5/Desktop/Batch2"
out.file<-"" 
file.names <- dir(path, pattern =".csv") 

setwd("C:/Users/Redirection/DINGRU5/Desktop/Batch2")
for(i in 1:length(file.names)){ 
  file = read.csv(file.names[1], header=TRUE) 
  sample_match = file[file$CUST_ID %in% Sample$CUST_ID, ]
  out.file <- rbind(out.file, file) 
} 

write.table(out.file, file = "sample_batch2.csv",row.names = FALSE) 

