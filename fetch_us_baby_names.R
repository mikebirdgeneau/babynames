require(RSelenium)
require(stringr)
require(png)
require(data.table)
require(rjson)
require(RCurl)

startServer()
remDr <- remoteDriver(browserName = "safari")
remDr$open(silent = FALSE)
remDr$setImplicitWaitTimeout(2000)
remDr$setWindowSize(width=856,height=663)
remDr

# For years:
if(file.exists("all_results.Rda")){load("all_results.Rda")}
if(!exists("all_results")){all_results <- data.table()}
for(i in 2014:1880){
  if(nrow(all_results)>0){
    if(nrow(all_results[Year==i,])>0){
      message(paste0("Skipping Year: ",i))
      next
      }
  }
  message(paste0("Year: ",i))
  
  remDr$navigate("https://www.ssa.gov/OACT/babynames/#&ht=1")
  Sys.sleep(3)
  
  webElem<-remDr$findElement(using="class","tabs")$findChildElements(using="tag name","a")[[2]]
  webElem$clickElement()
  
  inputYr <- remDr$findElement(using = "name","year")
  inputYr$clearElement()
  inputYr$sendKeysToElement(list(as.character(i)))
  
  inputPop <- remDr$findElement(using = "id", "rank")
  option <- remDr$findElement(using = 'xpath', "//*/option[@value = '1000']")
  option$clickElement()
  
  option <- remDr$findElement(using = "id","percent")
  option$clickElement()
  
  submitBtn <- remDr$findElement(using="xpath", '//*[contains(concat( " ", @class, " " ), concat( " ", "uef-btn-primary", " " ))]')
  submitBtn$clickElement()
  Sys.sleep(2)
  
  # Get Table
  table <- remDr$findElements(using = "xpath","//table")[[2]]
  table_data <- table$getElementText()
  
  result <- str_split(table_data,"\n")[[1]][-c(1:8)]
  result <- result[1:1000]
  
  dt_result<-rbindlist(lapply(result,FUN=function(x){
    temp <- strsplit(x,split = ' ')[[1]]
    data.table(t(temp))
  }))
  setnames(dt_result,c("Rank","BoyName","BoyPercent","GirlName","GirlPercent"))
  dt_boys <- subset(dt_result,select=c("Rank","BoyName","BoyPercent"))
  dt_boys[,gender:="Boy",]
  setnames(dt_boys,c("Rank","Name","Percent","Gender"))
  dt_girls <- subset(dt_result,select=c("Rank","GirlName","GirlPercent"))
  dt_girls[,gender:="Girl",]
  setnames(dt_girls,c("Rank","Name","Percent","Gender"))
  
  dt_result <- rbindlist(list(dt_boys,dt_girls))
  dt_result[,Year:=i]
 
  all_results <- rbindlist(list(all_results,dt_result))

}

save(all_results,file="all_results.Rda")

us_baby_names <- copy(all_results)
us_baby_names[,Percent:=as.numeric(str_replace_all(Percent,"%","")),]
us_baby_names[,Rank:=as.numeric(Rank),]


save(us_baby_names,file="us_baby_names.Rda")
