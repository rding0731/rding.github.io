Channel = read.csv("Channel.csv")
Channel= Channel[, -1]

Sample = read.csv("Sample.csv")
Sample= Sample[, -1]


Demo_var = c('AGE_YR', "cust_tenure_yr")
Bal_var = c('bookbusi', "net_inoutbal")
Product_var = c("Chequing", "Saving", "TDW_IND", "ALL_MFD_IND", "ALL_TRM_IND", "visa_ind", 
                "mtg_ind", "uloc_ind", "heloc_ind", "loan_ind", "odp_ind", "CPins" )
Channel_var = c("num_WEBBANKING_TRANS", "num_MOBILE_TRANS", "num_ATM_TRANS", "num_PHONE_TRANS","num_BRANCH_TRANS" )
tran_var = c("num_PFT_TRANS","num_BPY_TRANS", "num_DEP_TRANS", "num_WD_TRANS","num_EMT_TRANS" )
Service_var = c("PAC_IND", "PAD_IND", "PAP_IND", "PAYROLL_IND", "PRT_PERSNL_EZ_ACCESS_ind")

cluster_dat1 = cbind(Sample[, "CUST_ID"], Sample[, Demo_var], Sample[, Bal_var], Sample[,Product_var])
cluster_dat2 = cbind(Channel[, c("CUST_ID", "num_WEBBANKING_LOG", "num_MOBILE_LOG")], Channel[, Channel_var], Channel[, tran_var])
colnames(cluster_dat1)[1] <- "CUST_ID"
colnames(cluster_dat2)[1] <- "CUST_ID"

#$BoBperTenure = apply(cluster_dat1,  1, cluster_dat1$bookbusi/cluster_dat1$cust_tenure_yr)
############################################################
head(cluster_dat1)

cluster_dat1$corr_group =ifelse(cluster_dat1$TDW == 1 | cluster_dat1$ALL_MFD_IND==1 | cluster_dat1$ALL_TRM_IND ==1, "OWN_Wealth", ifelse(
  cluster_dat1$mtg_ind == 1 | cluster_dat1$heloc_ind ==1, "OWN_MORTGAGE", ifelse(
    cluster_dat1$loan_ind == 1 | cluster_dat1$visa_ind ==1| cluster_dat1$uloc_ind == 1 | cluster_dat1$CPins ==1, "Own_credit", "own_CORE_only")
  )
)

view(cluster_dat1 %>% group_by(corr_group) %>%
  summarise( customer_count = length(CUST_ID),
              total = sum(bookbusi),
            totalnet = sum(net_inoutbal))) 

cluster_dat1$weight =ifelse(cluster_dat1$corr_group == "OWN_Wealth", 0.034, ifelse(cluster_dat1$corr_group == "OWN_MORTGAGE", 0.034,
                                                              ifelse(cluster_dat1$corr_group == "Own_credit", 0.36, 1)))

cluster_dat1$weight_bob = cluster_dat1$weight*cluster_dat1$bookbusi

cluster_dat1$num_prod = apply(cluster_dat1[, Product_var], 1, sum)

cluster_dat1$product_corr_ind = ifelse(cluster_dat1$corr_group == "OWN_Wealth", 1, ifelse(cluster_dat1$corr_group == "OWN_MORTGAGE", 0.75,
                                                                                              ifelse(cluster_dat1$corr_group == "Own_credit", 0.50, 0.25)))
#cluster_dat1$banking_serv = rowSums(cluster_dat1[, c("PAC_IND", "PAD_IND", "PAP_IND", "PAYROLL_IND")])
################################################################
head(cluster_dat2)
summary(cluster_dat2)
#cluster_dat2[, 2:13] = round(cluster_dat2[,2:13])

cluster_dat2$log_to_engage = (cluster_dat2$num_WEBBANKING_TRANS+cluster_dat2$num_MOBILE_TRANS)/(cluster_dat2$num_WEBBANKING_LOG+cluster_dat2$num_MOBILE_LOG)
cluster_dat2$log_to_engage[cluster_dat2$log_to_engage == Inf] = 1
cluster_dat2$log_to_engage[is.na(cluster_dat2$log_to_engage)] = -1


cluster_dat2$digital_preference = (cluster_dat2$num_WEBBANKING_TRANS+cluster_dat2$num_MOBILE_TRANS) / rowSums(cluster_dat2[, Channel_var])
cluster_dat2$digital_preference[is.na(cluster_dat2$digital_preference)] = -1

cluster_dat2$total_trans = rowSums(cluster_dat2[, tran_var])

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
#####################################################


#####################################################
## decide how many clusters to have.  Iterate from 1: 10 clusters, pick the elbow point
wssplot = function(data, nc = 10, seed = 0) { 
  wss = (nrow(data) - 1) * sum(apply(data, 2, var)) 
  for (i in 2:nc) { 
    set.seed(seed) 
    wss[i] = sum(kmeans(data, centers = i, iter.max = 10, nstart = 10)$withinss) 
  } 
  plot(1:nc, wss, type = "b",
       xlab = "Number of Clusters", 
       ylab = "Within-Cluster Variance", 
       main = "Scree Plot for the K-Means Procedure") 
} 

wssplot(cluster_final_scale[1:35000,-1])

####################################################
library("factoextra")
# Cluster tendency
clustend = get_clust_tendency(scale(cluster_final_scale[1:1000, -1]), 999)
# Hopkins statistic
clustend$hopkins_stat
# Customize the plot
clustend$plot + 
  scale_fill_gradient(low = "red", high = "white")

set.seed(123)
fviz_nbclust(cluster_final_scale[1:10000,-1], kmeans, method = "wss")

##############################################
## Step3: run the kmeans by the number of cluster you selected in step2. 
set.seed(123) 
km_test = kmeans(cluster_final_scale[, -1], centers = 6, nstart = 25) 
print(km_test)
View(aggregate(cluster_final_scale, by=list(cluster = km_test$cluster), mean))
View(aggregate(cluster_final, by=list(cluster = km_test$cluster), mean))
View(aggregate(cluster_dat2, by=list(cluster = km_test$cluster), mean))


fviz_cluster(km_test, data = cluster_final_scale[, -1], geom = "point")
km_test$size
km_test$withinss
km_test$tot.withinss
km_test$totss


View(lapply(cluster_final_scale[, -1], mean))
View(lapply(cluster_final[, -1], mean))

#plot(cluster_final_scale$cust_tenure_yr, cluster_final_scale$bookbusi, col = km_test$cluster, 
#     xlab = "cust_tenure_yr", ylab = "BOB", 
#     main = paste("Single K-Means Attempt #1\n WCV: ", 
#                  round(km_test$tot.withinss, 4))) 

index = cbind(cluster_final_scale[, 1], list(km_test$cluster)[[1]])
index = as.data.frame(index)
colnames(index)[1] <- "CUST_ID"
colnames(index)[2] <- "Cluster_Number"
map = data.frame(c(1,2,3,4,5,6), c("TD_LOYALISTS", "DIGITAL_SAVVY", "TRADITIONAL_TRANSACTORS", "ASSISTED AFFLUENT", "SILENT", "MOBILE_LEADERS"))
colnames(map)[1] <- "Cluster_Number"
colnames(map)[2] <- "Cluster_Names"

index = inner_join(index, map, "Cluster_Number")
#group_by(index, Cluster_Names)%>% summarise(n = n())

write.csv(map, "map.csv")
write.csv(index[, -2], "index.csv")

#######################################################
#Match our cluster to the TD defined clusters
TD_segment = read.csv("Batch3_Sample.csv")
TD_segment = TD_segment[, -1]
head(TD_segment)

View(inner_join(index,TD_segment, by = "CUST_ID") %>% group_by(Cluster_Number,Segment)%>%
       summarise(pop = n()))




