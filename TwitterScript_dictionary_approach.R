library(stringr)
library(RSQLite)
library(plyr)
library(iterators)

LoadPosWordSet<-function(){
  iu.pos = scan("C:/E Drive/ASU/classes/SML/Project NLP/Dictionary approach/positive-words.txt", what='character', comment.char=";")
  pos.words = c(iu.pos)
  return(pos.words)
}

LoadNegWordSet<-function(){
  iu.neg = scan("C:/E Drive/ASU/classes/SML/Project NLP/Dictionary approach/negative-words.txt", what='character', comment.char=";")
  neg.words = c(iu.neg)
  return(neg.words)
}

GetScore<-function(sentence, pos.words, neg.words) {
  tscore = NULL
  for (i in 1:length(sentence)) { 
    sentence[i] = gsub('[[:punct:]]', '', sentence[i])
    sentence[i] = gsub('[[:cntrl:]]', '', sentence[i])
    sentence[i] = gsub('\\d+', '', sentence[i])
    # and convert to lower case:
    sentence[i] = tolower(sentence[i])
    word.list = str_split(sentence[i], '\\s+')
    words = unlist(word.list)
    
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    score = sum(pos.matches) - sum(neg.matches)
    tscore <- rbind(tscore,score) 
  }
  return(tscore)
}


pos.words = LoadPosWordSet()
neg.words = LoadNegWordSet()
Book1 <- read.csv("C:/E Drive/ASU/classes/SML/Project NLP/Dictionary approach/retweet_favorite.csv", header=FALSE)
X = NULL
tweets <- Book1[6]
print(length(tweets))
for (tweet in tweets ) {
    tweet <- str_replace_all(tweet,"  ", " ")
    tweet <- str_replace_all(tweet,"http://t.co/[a-z,A-Z,0-9]{8}","")
    tweet <- str_replace_all(tweet,"RT [a-z,A-Z]*: ","")
    tweet <- str_replace_all(tweet,"#[a-z,A-Z0-9]*","")
    tweet <- str_replace_all(tweet,"@[a-z,A-Z0-9]*","")
    tweetScore = 0
    sentimentOkay = TRUE
    tryCatch(
      X<-GetScore(tweet, pos.words, neg.words)
      , error=function(e) {
        sentimentOkay = FALSE
      })
}

Book1 <- cbind(Book1, X)
write.csv(Book1, "C:/E Drive/ASU/classes/SML/Project NLP/Dictionary approach/retweet_favorite_analysis.csv")

