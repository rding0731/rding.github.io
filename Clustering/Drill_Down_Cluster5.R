####################################
###Merging data
index = read.csv("index.csv")
index = index[, -1]
library(dplyr)

tran_channel = inner_join(Sample_trans, index, by = "CUST_ID")
sample_cluster = inner_join(Sample, index, by = "CUST_ID")

###transaction and channel
tran_channel$num_WEBBANKING_TRANS = apply(tran_channel[ , WEB_VAR[c(1, 3, 4)]], 1, sum)
tran_channel$num_MOBILE_TRANS = apply(tran_channel[ , MOBILE_VAR[c(1:3, 5)]], 1, sum)
tran_channel$num_ATM_TRANS = apply(tran_channel[ , ATM_VAR[2:4]], 1, sum)
tran_channel$num_PHONE_TRANS = apply(tran_channel[ , PHONE_VAR[c(1,3,4)]], 1, sum)
tran_channel$num_BRANCH_TRANS = apply(tran_channel[ , BRANCH_VAR[2:4]], 1, sum)
tran_channel$total_num_TRANS = apply(tran_channel[, c("num_WEBBANKING_TRANS", 'num_MOBILE_TRANS', 'num_ATM_TRANS',
                                                      'num_PHONE_TRANS', 'num_BRANCH_TRANS')], 1, sum)

tran_channel$digital_percentage = (tran_channel$num_WEBBANKING_TRANS+tran_channel$num_MOBILE_TRANS)/tran_channel$total_num_TRANS
tran_channel$digital_percentage[is.na(tran_channel$digital_percentage)] = -1


tran_channel$BYPDigital = tran_channel$num_WEBBANKING_BPY + tran_channel$num_MOBILE_BPY
tran_channel$PFTDigital = tran_channel$num_WEBBANKING_PFT + tran_channel$num_MOBILE_PFT
tran_channel$EMTDigital = tran_channel$num_WEBBANKING_EMT + tran_channel$num_MOBILE_EMT
tran_channel$DPDigital = tran_channel$num_MOBILE_RDC
tran_channel$trans_type_enabled = apply(tran_channel[, c("BYPDigital", "PFTDigital", "EMTDigital", "DPDigital")], 1, function(c)sum(c!=0))

#################################################
multi_fun = function(x){
  c(total_num = sum(x), client = sum(x!=0))
}

Mobile_drill = subset(tran_channel, Cluster_Names=="MOBILE_LEADERS")
TD_Traditional = subset(tran_channel, Cluster_Names == "TD_LOYALISTS")
TRADITIONAL = subset(tran_channel, Cluster_Names == "TRADITIONAL_TRANSACTORS")
DIGITAL_SAVVY = subset(tran_channel, Cluster_Names == "DIGITAL_SAVVY")
AFFULENT = subset(tran_channel, Cluster_Names == "ASSISTED AFFLUENT")
SILENT = subset(tran_channel, Cluster_Names == "SILENT")

nrow(AFFULENT)
nrow(DIGITAL_SAVVY)
nrow(TD_Traditional)
nrow(TRADITIONAL)

View(apply(AFFULENT[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))
View(apply(TD_Traditional[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))
View(apply(TRADITIONAL[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))
View(apply(TRADITIONAL[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))

##########################################################
##Cluster 5: Mobile
###conditional on people that are using Branch Now 
BranchUser_Dep = subset(Mobile_drill, num_BRANCH_DEP > 0)
nrow(BranchUser_Dep)
View(colSums(BranchUser_Dep[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))
#View(apply(BranchUser_Mobile[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])], 2, sum))

BranchUser_BPY = subset(Mobile_drill, (num_BRANCH_BPY + num_ATM_BPY) > 0)
nrow(BranchUser_BPY)
View(colSums(BranchUser_BPY[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))

BranchUser_PFT = subset(Mobile_drill, (num_BRANCH_PFT + num_ATM_PFT) > 0)
nrow(BranchUser_PFT)
View(colSums(BranchUser_PFT[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))

##########################################################
##Cluster 3: Digital Savvy
BranchUser_Dep = subset(DIGITAL_SAVVY, num_BRANCH_DEP > 0)
nrow(BranchUser_Dep)
View(colSums(BranchUser_Dep[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))
#View(apply(BranchUser_Mobile[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])], 2, sum))

BranchUser_BPY = subset(DIGITAL_SAVVY, (num_BRANCH_BPY + num_ATM_BPY) > 0)
nrow(BranchUser_BPY)
View(colSums(BranchUser_BPY[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))

BranchUser_PFT = subset(DIGITAL_SAVVY, (num_BRANCH_PFT + num_ATM_PFT) > 0)
nrow(BranchUser_PFT)
View(colSums(BranchUser_PFT[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))


##########################################################
##Cluster 1: Affulent
colnames(AFFULENT)
AFFLUENT_DIGITAL = subset(AFFULENT, (BYPDigital+PFTDigital+ EMTDigital+DPDigital) > 0)
nrow(AFFLUENT_DIGITAL)
View(apply(AFFLUENT_DIGITAL[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))

AFFULENT_BOB= subset(sample_cluster, Cluster_Names == "ASSISTED AFFLUENT")
nrow(AFFULENT_BOB)
# privatebanking customers with assets > 500,000
nrow(subset(AFFULENT_BOB, bookbusi > 500000))

#######################################################3







############################################################
###Conditional on people that are using ATM now
ATMUser_Mobile = subset(Mobile_drill, num_ATM_TRANS > 0)
nrow(ATMUser_Mobile)
View(colSums(ATMUser_Mobile[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))
View(apply(ATMUser_Mobile[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])], 2, sum))

NoneDigital_Mobile = subset(Mobile_drill, digital_percentage == 0)
nrow(NoneDigital_cluster5)

#############################################################
Digital_drill = subset(tran_channel, Cluster_Names=="DIGITAL_SAVVY")
nrow(Digital_drill)
View(apply(Digital_drill[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)], PHONE_VAR, BRANCH_VAR, ATM_VAR)],2, multi_fun))

###conditional on people that are using Branch Now 
BranchUser = subset(Digital_drill, num_BRANCH_TRANS > 0)
nrow(BranchUser)
View(colSums(BranchUser[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))
View(apply(BranchUser[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])], 2, sum))

###Conditional on people that are using ATM now
ATMUser = subset(Digital_drill, num_ATM_TRANS > 0)
nrow(ATMUser)
View(colSums(ATMUser[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])]!= 0))
View(apply(ATMUser[, c(WEB_VAR[c(1, 3, 4)], MOBILE_VAR[c(1:3, 5)])], 2, sum))

###conditional on 
NoneDigital_Mobile = subset(Mobile_drill, digital_percentage == 0)
nrow(NoneDigital_cluster5)
