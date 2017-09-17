#############################
##     06/02/2017           #
##     item files         #
##    ruonan.ding           #
#############################


###########################
install.packages("XML")
require(XML)

data = xmlParse("poslog_20170228.xml")
xml_data = xmlToList(data)

##############################################
## repeat code
for (i in 1:length(xml_data)){
  if ( (length(xml_data[[i]])) == 11){
    startpoint = i
    break
    }
}

startpoint
#####################################################
##smart bind function creationl; repeat code
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

#############################################

bb = as.data.frame(xml_data[[startpoint]][10][[1]][1])[1, ]
for (k in 2:(length(xml_data[[startpoint]][10][[1]])-5)){
  bb = rbind(bb, as.data.frame(xml_data[[startpoint]][10][[1]][k])[1,])
}
blah = setNames(data.frame(matrix(ncol = length(colnames(bb)), nrow = 0)), colnames(bb))
blah = rbind(blah, bb)
blah[,c("RetailStoreID", "WorkstationID", "SequenceNumber")] = do.call("rbind", replicate(nrow(blah), as.data.frame(xml_data[[startpoint]][1:3]), simplify = FALSE))
blah


for (i in 1:length(xml_data)) { 
  if (i == startpoint){ 
    next
  } else {
    len = length(xml_data[[i]]) 
    if (length(xml_data[[i]][len-1][[1]])==6){
      cc = as.data.frame(xml_data[[i]][len-1][[1]][1])[1,]
      cc =cbind(cc, as.data.frame(xml_data[[i]][1:3]))
    } else {
      cc = as.data.frame(xml_data[[i]][len-1][[1]][1])[1, ]
      for (k in 2:(length(xml_data[[i]][len-1][[1]])-5)){
        cc = sbind(cc, as.data.frame(xml_data[[i]][len-1][[1]][k])[1,], fill = NA)
      } 
      cc[,c("RetailStoreID", "WorkstationID", "SequenceNumber")] = do.call("rbind", replicate(nrow(cc), as.data.frame(xml_data[[i]][1:3]),simplify = FALSE))
      cc = cc[complete.cases(cc[, -(15:16)]), ]
    }
    blah = sbind(blah, cc)
  }
}

dim(blah)

##save the file as a .csv
write.csv(blah, paste("poslog_20170228.xml", "item_table.csv", sep=""))

