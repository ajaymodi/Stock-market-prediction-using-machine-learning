if(!require("tm"))
  install.packages("tm")

#required package for SVM
if(!require("e1071"))
  install.packages("e1071")

#required package for KNN
if(!require("RWeka"))
  install.packages("RWeka", dependencies = TRUE)

#required package for Adaboost
if(!require("ada"))
  install.packages("ada")
library("tm")
library("e1071")
library(RWeka)
library("ada")
#Initialize random generator
set.seed(1245)

#This function makes vector (Vector Space Model) from text message using highly repeated words
vsm<-function(message,highlyrepeatedwords){
  
  tokenizedmessage<-strsplit(message, "\\s+")[[1]]
  
  #making vector
  v<-rep(0, length(highlyrepeatedwords))
  for(i in 1:length(highlyrepeatedwords)){
    for(j in 1:length(tokenizedmessage)){
      if(highlyrepeatedwords[i]==tokenizedmessage[j]){
        v[i]<-v[i]+1
      }
    }
  }
  return (v)
}
#loading data. Original data is from http://archive.ics.uci.edu/ml/datasets/tweet+Spam+Collection
print("Uploading tweet Spams and Hams!\n")

tweettable<-read.csv("C:/E Drive/ASU/classes/SML/Project NLP/Spam filter/Sample.csv", header = TRUE, sep = ",")
tweettabletmp<-tweettable

print("Extracting Ham and Spam Basic Statistics!")

#Basic Statisctics like mean and variance of spam and hams
hamavg<-mean(tweettabletmp$type)
print("Average Ham is :");hamavg

hamvariance<-var(tweettabletmp$type)
print("Var of Ham is :");hamvariance

print("Extract average token of Hams and Spams!")

nohamtokens<-0
noham<-0
nospamtokens<-0
nospam<-0

for(i in 1:length(tweettable$type)){
  if(tweettable[i,1]==1){
    nohamtokens<-length(strsplit(as.character(tweettable[i,2]), "\\s+")[[1]])+nohamtokens
    noham<-noham+1
  }else{ 
    nospamtokens<-length(strsplit(as.character(tweettable[i,2]), "\\s+")[[1]])+nospamtokens
    nospam<-nospam+1
  }
}

totaltokens<-nospamtokens+nohamtokens;
print("total number of tokens is:")
print(totaltokens)

avgtokenperham<-nohamtokens/noham
print("Avarage number of tokens per ham message")
print(avgtokenperham)

avgtokenperspam<-nospamtokens/nospam
print("Avarage number of tokens per spam message")
print(avgtokenperspam)

print(" Make two different sets, training data and test data!")
#select the percent of data that you want to use as training set
trdatapercent<-0.7

#training data set
trdata=NULL

#test data set
tedata=NULL

for(i in 1:length(tweettable$type)){
  if(runif(1)<trdatapercent){
    trdata=rbind(trdata,c(tweettable[i,1],tolower(tweettable[i,2])))
  }
  else{
    tedata=rbind(tedata,c(tweettable[i,1],tolower(tweettable[i,2])))
  }
}

print("Training data size is!")
dim(trdata)

print("Test data size is!")
dim(tedata)

# Text feature extraction using tm package

trtweets<-Corpus(VectorSource(trdata[,2]))
trtweets<-tm_map(trtweets, stripWhitespace)
trtweets <- tm_map(trtweets, removeNumbers)
trtweets<-tm_map(trtweets, tolower)
trtweets <- tm_map(trtweets, removePunctuation)
trtweets<-tm_map(trtweets, removeWords, stopwords("english"))
trtweets <- tm_map(trtweets, PlainTextDocument)

dtm <- DocumentTermMatrix(trtweets)

highlyrepeatedwords<-findFreqTerms(dtm, 1)

#These highly used words are used as an index to make VSM 
#(vector space model) for trained data and test data

#vectorized training data set
vtrdata=NULL

#vectorized test data set 
vtedata=NULL


for(i in 1:length(trdata[,2])){
  if(trdata[i,1]==1){
    vtrdata=rbind(vtrdata,c(1,vsm(trdata[i,2],highlyrepeatedwords)))
  }
  else{
    vtrdata=rbind(vtrdata,c(0,vsm(trdata[i,2],highlyrepeatedwords)))
  }
  
}

for(i in 1:length(tedata[,2])){
  if(tedata[i,1]==1){
    vtedata=rbind(vtedata,c(1,vsm(tedata[i,2],highlyrepeatedwords)))
  }
  else{
    vtedata=rbind(vtedata,c(0,vsm(tedata[i,2],highlyrepeatedwords)))
  }
  
}

# Run different classification algorithms
# differnet SVMs with different Kernels 
print("----------------------------------SVM-----------------------------------------") 
print("Linear Kernel")
svmlinmodel <- svm(x=vtrdata[,2:length(vtrdata[1,])],y=vtrdata[,1],type='C', kernel='linear');
summary(svmlinmodel)
predictionlin <- predict(svmlinmodel, vtedata[,2:length(vtedata[1,])])
tablinear <- table(pred = predictionlin , true = vtedata[,1]); tablinear
precisionlin<-sum(diag(tablinear))/sum(tablinear);
print("General Error using Linear SVM is (in percent):");(1-precisionlin)*100
#print("Ham Error using Linear SVM is (in percent):");(tablinear[1,2]/sum(tablinear[,2]))*100
#print("Spam Error using Linear SVM is (in percent):");(tablinear[2,1]/sum(tablinear[,1]))*100

print("Polynomial Kernel")
svmpolymodel <- svm(x=vtrdata[,2:length(vtrdata[1,])],y=vtrdata[,1], kernel='polynomial', probability=FALSE)
summary(svmpolymodel)
predictionpoly <- predict(svmpolymodel, vtedata[,2:length(vtedata[1,])])
tabpoly <- table(pred = predictionpoly , true = vtedata[,1]); tabpoly

print("Radial Kernel")
svmradmodel <- svm(x=vtrdata[,2:length(vtrdata[1,])],y=vtrdata[,1], kernel = "radial", gamma = 0.09, cost = 1, probability=FALSE)
summary(svmradmodel)
predictionrad <- predict(svmradmodel, vtedata[,2:length(vtedata[1,])])
tabrad <- table(pred = predictionrad, true = vtedata[,1]); tabrad

print("----------------------------------KNN-----------------------------------------")
data<-data.frame(tweet=vtrdata[,2:length(vtrdata[1,])],type=vtrdata[,1])
classifier <- IBk(data, control = Weka_control(K = 20, X = TRUE))
summary(classifier)
evaluate_Weka_classifier(classifier, newdata = data.frame(tweet=vtedata[,2:length(vtedata[1,])],type=vtedata[,1]))

print("---------------------------------Adaboost-------------------------------------")
adaptiveboost<-ada(x=vtrdata[,2:length(vtrdata[1,])],y=vtrdata[,1],test.x=vtedata[,2:length(vtedata[1,])], test.y=vtedata[,1], loss="logistic", type="gentle", iter=100)
summary(adaptiveboost)
varplot(adaptiveboost)

