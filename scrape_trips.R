library(rvest)
library(tidyverse)
library(lubridate)

stations <- read_csv("stations.csv")
stations_ger <- stations %>%
  distinct() %>% 
  dplyr::filter(str_detect(name,"Germany")) 

# res <- tibble()
pb <- txtProgressBar(min = 1, max = nrow(stations_ger), style = 3)
for(i in 1:nrow(stations_ger)){
  k <- 0
  id <- stations_ger$extId[i]
  setTxtProgressBar(pb, i)
  if(file.exists(paste0(id,".csv"))){
    next()
  }
  url <- paste0("https://timetable.eurail.com/v1/timetable/trip?&lang=en&originId=",id,"&destId=008062648&date=2019-02-20&time=23%3A59&searchForArrival=1")
  df <- tryCatch(jsonlite::fromJSON(url),error=function(e) tibble())
  while(is_empty(df) & k<=10){
    k <- k+1
    df <- tryCatch(jsonlite::fromJSON(url),error=function(e) tibble())
    Sys.sleep(runif(1,0,1.2))
  } 
  if(k==10){
    next()
  }
  if("errorText"%in%names(df)){
    next()
  }
  n <- length(df$Trip$LegList$Leg)
  sw <- sapply(1:n,function(x) nrow(df$Trip$LegList$Leg[[x]]))
  msw <- which.min(sw)
  mdr <- suppressWarnings(min(as.numeric(hm(df$Trip$duration))/60/60,na.rm=T))

  trip <- df$Trip$LegList$Leg[[msw]]$Destination %>% select(name,extId,time)
  route <- unname(apply(trip,2,function(x) paste0(x,collapse=";")))
  time <- df$Trip$duration[msw]
  tibble(from_name=stations_ger$name[i],
         from_id=stations_ger$extId[i],
         via_name=route[1],
         via_id=route[2],
         via_time=route[3],
         duration=time) ->trip_tbl
  write_csv(trip_tbl,paste0(id,".csv"))
  res <- bind_rows(res,tibble(name=stations_ger$name[i],
                              extID=stations_ger$extId[i],
                              minswitches=min(sw)-1,minduration=mdr))
  Sys.sleep(runif(1,0,2))
}

close(pb)
write_csv(res,"trips.csv")