library(tidyverse)
library(gganimate)
GER <- map_data(map = "world", region = "Germany")

trips <- read_csv("trips.csv")
stations <- read_csv("stations.csv")
stations_ger <- stations %>%
  distinct() %>% 
  dplyr::filter(str_detect(name,"Germany")) 

left_join(trips,select(stations_ger,extId,lon,lat),by=c("extID"="extId")) %>% 
  distinct() %>% 
  ggplot(aes(lon,lat))+
  geom_polygon(data = GER, aes(x = long, y = lat, group = group),fill="grey",colour="black")+
  geom_point(aes(col=factor(minswitches)))+
  scale_color_manual(values=c("#008B00", "#EE9A00", "#1874CD", "#9A32CD", "#CD3333"))+
  coord_map()+
  theme_void()+
  theme(legend.position = "none",
        panel.background = element_rect(fill="black"),
        plot.background = element_rect(fill="black"),
        strip.text = element_text(colour="white"),
        plot.title = element_text(colour="white",size=16),
        plot.caption = element_text(colour="grey",size=7))+
  facet_wrap(~minswitches,nrow=1)+
  labs(title="switches required to get to Berlin via train")

left_join(trips,select(stations_ger,extId,lon,lat),by=c("extID"="extId")) %>% 
  distinct() %>% 
  ggplot(aes(lon,lat))+geom_hex(aes(fill=factor(minswitches)))

left_join(trips,select(stations_ger,extId,lon,lat),by=c("extID"="extId")) %>% 
  distinct() %>% 
  ggplot(aes(lon,lat))+geom_point(aes(col=minduration))+
  scale_color_gradient(low="green",high="red",na.value = "green")
trips %>% 
  group_by(minswitches) %>% 
  count() %>% 
  ungroup() %>% 
  mutate(n=n/sum(n)) %>% 
ggplot()+
  geom_col(aes(x=minswitches,y=n))+
  ggthemes::theme_tufte(ticks = F)+
  labs(x="number of switches",y="fraction")+
  theme(panel.grid.major.y = element_line(color="grey"),
        text=element_text(size=14))

ggplot(trips)+geom_histogram(aes(minduration))

trips %>% dplyr::filter(!is.infinite(minduration)) %>% arrange(-minduration) %>% print(n=50)
