setwd("F:/Data Projects/AppCluster/")
library("tm")
library("stringr")
library("wordcloud")  

## Read application list with app description
pkg.data.info <- read.csv("./data/pkg.data.info.25082015.csv",header = T,colClasses = "character")
## read new stop words file
new.stopwords <- readLines("./data/stopwords.txt")
# add extra stop words
myStopwords <- c(stopwords("english"), new.stopwords)

##### Data lean up ############################################# 
# convert to lower case
pkg.data.info$description <-  tolower(pkg.data.info$description)
# remove URLs
removeURL <- function(x) gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", x)
pkg.data.info$description <- removeURL(pkg.data.info$description)
# remove punctuation
pkg.data.info$description <- str_replace_all(pkg.data.info$description, "[^[:alnum:]]", " ")
# remove numbers
pkg.data.info$description <- gsub(pattern = "[0-9]",replacement = "",x = pkg.data.info$description)
pkg.data.info$description.c <- sapply(VectorSource(pkg.data.info$description)$content,removeWords,myStopwords)

pkg.data.info$description.c <- gsub("(?<=[\\s])\\s*|^\\s+$", "", pkg.data.info$description.c, perl=TRUE)
pkg.data.info$description.c <- gsub('(\\b\\S+\\b)(?=.*\\b\\1\\b.*) ', "",pkg.data.info$description.c, perl=TRUE)
          
################## Stemming Process #####################
## Lemmatie function 
lemmatize <- function(wordlist) {
  get.lemma <- function(word, url) {
    response <- GET(url,query=list(spelling=word,standardize="",
                                   wordClass="",wordClass2="",
                                   corpusConfig="ncf",    # Nineteenth Century Fiction
                                   media="text"))
    content <- content(response,type="text")
    content <- str_replace_all(content, "[^[:alnum:]]", " ")
    lem.words <- strsplit(x = content,split = " ")[[1]][6]
    lem.words.df <-  data.frame(st=lem.words,word=word)
    return(lem.words.df)    
  }
  require(httr)
  require(XML)
  url <- "http://devadorner.northwestern.edu/maserver/lemmatizer"
  rt <- lapply(wordlist,get.lemma,url=url)
  #rt <- paste(rt,collapse = " ")
  rt <- do.call("rbind",rt)
  return(rt)
}
####### Start all stemming process        
        ## Select top words to keep
        top.words <- table(unlist(strsplit(x = pkg.data.info$description.c,split = " ")))[-1]
        ## select words with more than 50 appearances 
		top.words.a <- names(top.words[top.words>50])
			
			## Keep only selected words in description column
			pkg.data.info$description.cc <- sapply(VectorSource(pkg.data.info$description.c)$content,removeWords,top.words.a)
			for (i in 1:nrow(pkg.data.info))
			{
			  pkg.data.info$description.clean[i] <- sapply(VectorSource(pkg.data.info$description.c)$content[i],removeWords,unlist(strsplit(x = pkg.data.info$description.cc[i],split = " ")))
			}
        
        ### select unique words to stem
          word.list <-  unlist(strsplit(x = pkg.data.info$description.clean,split = " "))
          word.list <- word.list[word.list!=""]
          word.list <- names(table(word.list))
        
          ## stem    
            stem.word.list <- lemmatize(word.list)
          
          ## replace all description words with the stemmed words     
            for (i in 1:nrow(pkg.data.info))
          {
            st <-  unlist(strsplit(x = pkg.data.info$description.clean[i],split = " "))
            st <- st[st!=""]
            st <- as.character(stem.word.list[stem.word.list$word %in% st,"st"])
            pkg.data.info$description.stem[i] <- paste(st,collapse = " ")
            }
### Save stem words df
write.csv(pkg.data.info,"./data/pkg.data.info.stem.csv",row.names = F)
        
######################################################        
## create data for clustering
myCorpus <- Corpus(VectorSource(pkg.data.info$description.stem))
myTdm <- DocumentTermMatrix(myCorpus)

## create word matrix for clustering
m <- as.matrix(myTdm)
## number of clusteres
k <- 110
set.seed(1)
kmeansResult <- kmeans(m, k,iter.max = 50)
##########################################
### check clustering results
### merge cluster id with application data frame
pkg.cluster.out<- cbind(clusterid=kmeansResult$cluster,pkg.data.info)
### check how many pkg in each cluster
table(pkg.cluster.out$clusterid)

## Check total words popularity using word cloud graphics 
set.seed(142)   
dark2 <- brewer.pal(6, "Dark2")   
wordcloud(names(termFrequency), termFrequency, max.words=200, rot.per=0.2, colors=dark2)   

### check popular words in each cluster
for (i in 1:k) {
   cat(paste("cluster ", i, ": ", sep=""))
   s <- sort(kmeansResult$centers[i,], decreasing=T)
   cat(names(s)[1:5], "\n")
}

#### check apps n cluster
## set cluster id
x <- 5
pkg.cluster.out[pkg.cluster.out$clusterid==x,"pkg.name"]
## word cloud graph for cluster id
s <- sort(kmeansResult$centers[x,], decreasing=T)
wordcloud(names(s), s, max.words=50, rot.per=0.2, colors="black")   
