library(kernlab)
library(psych)
library(caret)
data(spam)

train <- sample(1:nrow(spam), 8*nrow(spam)/10)
spamTrain <- spam[train,]
spamTest <- spam[-train,]
spamVars <- setdiff(colnames(spam),list('spam'))
spamFormula <- as.formula(paste('spam', paste(spamVars,collapse=' + '),sep=' ~ '))
spamFormula

M <- abs(cor(spamTrain[,-58]))
diag(M) <- 0 # Set correlation between variables and itself to zero which(M > 0.6, arr.ind=T) 
which(M > 0.85, arr.ind=T) 

#library(caret)
#preProcValues1 <- preProcess(spamTrain, method = c("center", "scale"))
#scaledTrain <- predict(preProcValues1, spamTrain)
#preProcValues2 <- preProcess(spamTest, method = c("center", "scale"))
#scaledTest <- predict(preProcValues2, spamTest)

#############################
###measurement###############
#############################
accuracyMeasures <- function(pred, truth, name = 'model'){
  ctable <- table(truth = truth, pred =(pred>0.5)) 
  accuracy <- sum(diag(ctable))/sum(ctable)
  precision <- ctable[2,2]/sum(ctable[,2])
  recall <- ctable[2,2]/sum(ctable[2,])
  f1 <- precision * recall
  data.frame(model = name, accuracy = accuracy, f1=f1, ctable)
}

##########################################################
#forest select variables##############################
library(randomForest)
set.seed(0)
fmodel <- randomForest(x=spamTrain[,1:57], y=spamTrain$type, ntree= 500, nodesize = 7, importance = T)

varImp<- importance(fmodel)
varImpPlot(fmodel, type = 1)

accuracyMeasures(predict(fmodel, newdata =spamTrain, type = 'prob')[,'spam'],
                 spamTrain$type == 'spam', name =' randomforest, train')

accuracyMeasures(predict(fmodel, newdata =spamTest, type = 'prob')[,'spam'],
                 spamTest$type == 'spam', name =' randomforest, test')

#conclusion: random tree overfitting

###########################################################
##PCA######################################
##We have applied a transformation to the data, the log10 function, and added +1 to it. 
##This makes the data look a little bit more Gaussian. This helps because some of the variables are skewed, while others are normal looking.

my.prc<-prcomp(log10(spamTrain[,-58]+1))
screeplot(my.prc, main="Scree Plot", xlab="Components")
screeplot(my.prc, main="Scree Plot", type="line" )

pca_spam <- principal(log10(spamTrain[,-58]+1), nfactors = 2, rotate = "none") 
pca_spam$loadings

#PC variables 
trainPC <- predict(pca_spam, log10(spamTrain[,-58]+1))
head(trainPC)

# training only on the PC variables.
modelFit <- train(spamTrain$type ~ ., method="glm", data=trainPC)

#for prediction
testPC <- predict(pca_spam, log10(spamTest[,-58]+1))
testpred <- predict(modelFit, testPC)

#model measurement
accuracyMeasures(predict(modelFit, trainPC, type = 'prob')[,'spam'],
                 spamTrain$type == 'spam', name ='PCA, train')
accuracyMeasures(predict(modelFit, testPC, type = 'prob')[,'spam'],
                 spamTest$type == 'spam', name ='PCA, test')

#PCA is not overfitting with a better compared to the tree. 


