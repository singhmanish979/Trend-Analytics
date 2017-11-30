#### Function to get quetsion for a Tag from stackoverflow
get.tagged.questions <- function(tag = "chi-squared", page = 2500, fromdate="2016-01-01" , todate = Sys.Date(), order = "desc"){
  library(httr)
  library(jsonlite)
  library(parsedate)
  
  if(!is.null(fromdate)){
    fromdate <- as.numeric(as.POSIXct(fromdate, origin = "1960-01-01",tz='GMT'))
    todate <- as.numeric(as.POSIXct(todate, origin = "1960-01-01",tz='GMT'))
    part <- paste0("&fromdate=",fromdate,"&todate=",todate,"&order=",order)
  }else{
    part <- paste0("&order=",order)
  }
  
  pages <- list()
  i<- 1
  for(i in 1:page){
    url <- paste0("https://api.stackexchange.com/2.2/questions?page=",i,"&pagesize=100",part,"&sort=activity&tagged=",tag,"&site=stackoverflow&key=eLZ5T3WUBEd0EOADuHHiTA((&access_token=2R(E(6aCJqfaDZimODUajw))")
    mydata <- fromJSON(content(GET(url),type = "text",encoding = "ISO-8859-1"))
    pages[[i+1]] <- mydata$items
    if(mydata$has_more==F) break
  }
  
  # filings<- rbind.pages(pages[sapply(pages, length)>0])
  filings <- rbind_pages(pages)
  filings$migrated_to <- NULL
  filings$migrated_from <- NULL
  filings$owner <- NULL
  filings$tags <- as.character(filings$tags)
  filings$last_edit_date[is.na(filings$last_edit_date)==T]<- 0
  
  # Parsing Date
  filings$last_activity_date <- as.Date(parse_date(filings$last_activity_date))
  filings$creation_date <- as.Date(parse_date(filings$creation_date))
  filings$last_edit_date <- as.Date(parse_date(filings$last_edit_date))
  filings$name<- tag
  return(filings)
}
