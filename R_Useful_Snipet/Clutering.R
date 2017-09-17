##Batch1
##???Sample = read.csv("Sample.csv")
Sample= Sample[, -1]

Demo_var = c('AGE_YR', "cust_tenure_yr")
Bal_var = c('bookbusi', "net_inoutbal")
Product_var = c("Chequing", "Saving", "TDW_IND", "ALL_MFD_IND", "ALL_TRM_IND", "visa_ind", 
                "mtg_ind", "uloc_ind", "heloc_ind", "loan_ind", "odp_ind", "CPins" )
cluster_dat1 = cbind(Sample[, "CUST_ID"], Sample[, Demo_var], Sample[, Bal_var], Sample[,Product_var])
colnames(cluster_dat1)[1] <- "CUST_ID"

##################################
##Batch2
Sample_tran = read.csv()
cluster_dat2_test = Sample_trans[, c("CUST_ID", "num_WEBBANKING_LOG", "num_MOBILE_LOG")]

WEB_VAR = grep("num_WEBBANKING", colnames(Sample_trans), value=TRUE)
MOBILE_VAR = grep("num_MOBILE", colnames(Sample_trans), value=TRUE)
ATM_VAR = grep("num_ATM", colnames(Sample_trans), value=TRUE)
PHONE_VAR = grep("num_PHONE", colnames(Sample_trans), value=TRUE)
BRANCH_VAR = grep("num_BRANCH", colnames(Sample_trans), value=TRUE)

###Derived Varibes
cluster_dat2_test$num_WEBBANKING_TRANS = apply(Sample_trans[ , WEB_VAR[c(1, 3, 4)]], 1, sum)
cluster_dat2_test$num_MOBILE_TRANS = apply(Sample_trans[ , MOBILE_VAR[c(1:3, 5)]], 1, sum)
cluster_dat2_test$num_ATM_TRANS = apply(Sample_trans[ , ATM_VAR], 1, sum)
cluster_dat2_test$num_PHONE_TRANS = apply(Sample_trans[ , PHONE_VAR], 1, sum)
cluster_dat2_test$num_BRANCH_TRANS = apply(Sample_trans[ , BRANCH_VAR], 1, sum)
cluster_dat2_test$total_num_TRANS = apply(cluster_dat2_test[, c("num_WEBBANKING_TRANS", 'num_MOBILE_TRANS', 'num_ATM_TRANS',
                                            'num_PHONE_TRANS', 'num_BRANCH_TRANS')], 1, sum)

Channel_var = c("num_WEBBANKING_TRANS", "num_MOBILE_TRANS", "num_ATM_TRANS", "num_PHONE_TRANS","num_BRANCH_TRANS" )
#tran_var = c("num_PFT_TRANS","num_BPY_TRANS", "num_DEP_TRANS", "num_WD_TRANS","num_EMT_TRANS" )
#Service_var = c("PAC_IND", "PAD_IND", "PAP_IND", "PAYROLL_IND", "PRT_PERSNL_EZ_ACCESS_ind")

################################################################
head(cluster_dat2)
head(cluster_dat2_test)
summary(cluster_dat2_test)
#cluster_dat2_test[, 2:13] = round(cluster_dat2_test[,2:13])

cluster_dat2_test$log_to_engage = (cluster_dat2_test$num_WEBBANKING_TRANS+cluster_dat2_test$num_MOBILE_TRANS)/(cluster_dat2_test$num_WEBBANKING_LOG+cluster_dat2_test$num_MOBILE_LOG)
cluster_dat2_test$log_to_engage[cluster_dat2_test$log_to_engage == Inf] = 1
cluster_dat2_test$log_to_engage[is.na(cluster_dat2_test$log_to_engage)] = -1


cluster_dat2_test$digital_preference = (cluster_dat2_test$num_WEBBANKING_TRANS+cluster_dat2_test$num_MOBILE_TRANS) / rowSums(cluster_dat2_test[, Channel_var])
cluster_dat2_test$digital_preference[is.na(cluster_dat2_test$digital_preference)] = -1

cluster_dat2_test$total_trans = rowSums(cluster_dat2_test[, Channel_var])

##############################################################
library("dplyr")
cluster_final = inner_join(cluster_dat1, cluster_dat2, by = "CUST_ID")
dim(cluster_final)
colnames(cluster_final)

Final_var=c("CUST_ID", "AGE_YR", "cust_tenure_yr", "weight_bob", "num_prod", "product_corr_ind",
            "log_to_engage", "digital_preference", "total_trans")

########################################################
## Step2: Scale the data in between 0 and 1
cluster_final_scale = cluster_final[, Final_var]
remove_outlier = function(x){
  quantiles = quantile(x, probs = c(0.05, 0.95))
  x[x < quantiles[1]] = quantiles[1]
  x[x > quantiles[2]]= quantiles[2]
  x
}

cluster_final_scale[, c("weight_bob", "log_to_engage", "total_trans")] = lapply(cluster_final_scale[, c("weight_bob", "log_to_engage", "total_trans")], remove_outlier)

range01 = function(x){(x -min(x))/(max(x)-min(x))}
colnames(cluster_final_scale)
cluster_final_scale[,c(2:5, 7:9)] <- lapply(cluster_final_scale[, c(2:5, 7:9)], range01)
head(cluster_final_scale)
summary(cluster_final_scale)

########################################################
load(km_test)
closest.cluster <- function(x) {
  cluster.dist <- apply(km_test$centers, 1, function(y) sqrt(sum((x-y)^2)))
  return(which.min(cluster.dist)[1])
}
prediction = apply(cluster_final_scale[1:50,-1], 1, closest.cluster)
Pred = cbind(cluster_final_scale[,1], prediction)
Pred = as.data.frame(Pred)
colnames(Pred)[1] <- "CUST_ID"
colnames(Pred)[2] <- "Cluster_Number"
Pred = inner_join(Pred, map, "Cluster_Number")[, -2]