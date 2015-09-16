library("rvest")
library("httr")

###################################################################
## This function get a vector of application ids
## and extract the application name and description
## from google play
## the output is a list of data frames for all apps
get.play.data <- function(x){
  
  app.data <- data.frame(app_name=as.character(),description=as.character())
  
  base.url <- "https://play.google.com/store/apps/details?id="
  en.code <- "&hl=en"
  
  run.url <-  paste(base.url,x,en.code,sep = "")
  tryCatch({
    
    htmlpage <- html(run.url)
    app.info <- html_nodes(htmlpage, ".document-title div,.id-app-orig-desc",)
    app.text <- html_text(app.info)
    app.data <- as.data.frame(rbind(app.text))
    #app.data <- rbind(app.data,tmp)
    app.data$pkg.id <- x},
    error=function(e){})
  
  handle_reset(run.url)
  gc()
  return(app.data)
}

## executing the "get.play.data" 
## output is a list
scrape.data.list <- lapply(pkg.id.tb$pkg.id,get.play.data)
## convert the list to a single data frame
scrape.play.data <- do.call("rbind", scrape.data.list)
###################################################################
