#############################
##     06/02/2017           #
##     transaction          #
##    ruonan.ding           #
#############################
setwd("~/")

##install.package("XML") if you don't have it
require(XML)

#load in data and convert it to LIST.
  data = xmlParse("poslog_20170227.xml")
  xml_data = xmlToList(data)
#####################################################
##smart bind function creation  
  sbind = function(x, y, fill=NA) {
    sbind.fill = function(d, cols){ 
      for(c in cols)
        d[[c]] = fill
      d
    }
    x = sbind.fill(x, setdiff(names(y),names(x)))
    y = sbind.fill(y, setdiff(names(x),names(y)))
    rbind(x, y)
  }

##############################################
  for (i in 1:length(xml_data)){
    if ( (length(xml_data[[i]])) == 11){
      startpoint = i
      break
    }
  }
  
  startpoint
################################################## 
##### first 9 columns
  a = as.data.frame(xml_data[[startpoint]][1])
  for (j in 2:9){
    a = cbind(a, as.data.frame(xml_data[[startpoint]][j]))
  }
  test = setNames(data.frame(matrix(ncol = length(colnames(a)), nrow = 0)), colnames(a))
  test = rbind(test, a)
  
  for (i in 1:length(xml_data)) { 
    if (i == startpoint){ 
      next 
    } else {
      b = as.data.frame(xml_data[[i]][1])
      for (j in 2:(length(xml_data[[i]])-2)){
        b = cbind(b, as.data.frame(xml_data[[i]][j]))
      }
      test = sbind(test, b, fill = NA)
    }
  }
  
  
############################################################
##column 10 are all the money spend##
  d = as.data.frame(xml_data[[startpoint]][10][[1]][length(xml_data[[startpoint]][10][[1]])-4])
  for (k in (length(xml_data[[startpoint]][10][[1]])-3):(length(xml_data[[startpoint]][10][[1]])-2)){
    d = cbind(d, as.data.frame(xml_data[[startpoint]][10][[1]][k]))
  }
  test1 = setNames(data.frame(matrix(ncol = length(colnames(d)), nrow = 0)), colnames(d))
  test1 = rbind(test1, d)

  for (i in 1:length(xml_data)) { 
    if (i == startpoint){ 
      next
    } else {
      len = length(xml_data[[i]]) 
      if (len < 11) {
        c = setNames(data.frame(matrix(ncol = length(colnames(test1)), nrow = 1)), colnames(test1))
      } else {
        c = as.data.frame(xml_data[[i]][len-1][[1]][length(xml_data[[i]][len-1][[1]])-4])
        for (k in (length(xml_data[[i]][len-1][[1]])-3):(length(xml_data[[i]][len-1][[1]])-2)){
          c = cbind(c, as.data.frame(xml_data[[i]][len-1][[1]][k]))
        }
      }
      test1 = sbind(test1, c , fill = NA)
    }
  }
  
 
#######################################################  
  ## Combine per transaction information
  transaction_lines = cbind(test, test1)

########################################################    
  ##adding a column to tell how many items a transaction has
  items = vector()
  for (i in 1:length(xml_data)){
    if (i == startpoint){ 
      items[1] = length(xml_data[[i]][len-1][[1]])-5
    } else {
      len = length(xml_data[[i]]) 
      items[i] = length(xml_data[[i]][len-1][[1]])-5
    }
  }
  
  ## add it to the datatable
  transaction_lines["number_items"] = as.data.frame(items)
  
  ##rename columns
  colnames(transaction_lines)[colnames(transaction_lines) == 'Total.text'] <- 'TransactionGrandAmount'
  colnames(transaction_lines)[colnames(transaction_lines) == 'Total.text.1'] <- 'TransactionNetAmount'
  colnames(transaction_lines)[colnames(transaction_lines) == 'Total.text.2'] <- 'TransactionTaxAmount'
  
  
  ##delete some colnames
  transaction_lines = transaction_lines[, -c(12, 14, 16)]
  dim(transaction_lines)
  
  ##save the file as a .csv
  write.csv(transaction_lines, paste("poslog_20170227.xml", ".csv", sep=""))
  