library(rvest)
library(tidyverse)

url <- "https://de.wikipedia.org/wiki/Liste_der_St%C3%A4dte_in_Deutschland"
towns <- url %>% read_html() %>% html_nodes("dd a") %>% html_text()
towns <- towns %>% str_remove_all("\\(.*\\)") %>% str_trim() %>% str_replace_all(" ","%20")

base_url <- "https://timetable.eurail.com/v1/timetable/location.name?&input="

pb <- txtProgressBar(min = 1, max = length(towns), style = 3)
for(i in 1:length(towns)){
  k <- 0
  setTxtProgressBar(pb, i)
  stations <- tryCatch(jsonlite::fromJSON(paste0(base_url,towns[i])),error=function(e) tibble())
  while(is_empty(stations) & k<=10){
    k <- k+1
    stations <- tryCatch(jsonlite::fromJSON(paste0(base_url,towns[i])),error=function(e) tibble())
    Sys.sleep(runif(1,0,1.2))
  } 
  if(k==10){
    next()
  }
  stations <- stations$stopLocationOrCoordLocatio$StopLocation %>% select(name,lon,lat,extId)
  if(file.exists("stations.csv")){
    write_csv(stations,"stations.csv",append=T)
  } else{
    write_csv(stations,"stations.csv",append=F)
  }
  Sys.sleep(runif(1,1,3))
}
close(pb)

