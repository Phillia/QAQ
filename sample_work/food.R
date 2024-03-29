library(tidyverse)
library(readxl)
library(furrr)
library(tmaptools)

food <- read_excel("food.xlsx")
food$n <- row.names(food)

### geocode
plan(multiprocess)
geocoded <- future_map(paste0(food$street,",USA"),
                            safely(function(x) geocode_OSM(x)$coords %>% t() %>% tbl_df())) %>% purrr::transpose()
new <- geocoded$result %>% set_names(food$n) %>% 
    bind_rows(.id="n") %>% select(n,longitude=x,lat=y) %>% 
    full_join(food,by=c("n"))

new[new$name=="Sonobana",c("longitude","lat")] <- c(-86.8523238,36.1299624)
new[new$name=="Pastaria",c("longitude","lat")] <- c(-86.8202853,36.1513777)
new[new$name=="Lemongrass Thai",c("longitude","lat")] <- c(-86.8555744,36.1296867)
new[new$name=="Anatolia",c("longitude","lat")] <- c(-86.8523238,36.1299624)
new[new$name=="Merengue Cafe",c("longitude","lat")] <- c(-86.7684410510235,36.1133171653906) 
new[new$name=="Sump Coffee",c("longitude","lat")] <- c(-86.8202853,36.1513777)
new[new$name=="Korea House Restaurant",c("longitude","lat")] <- c(-86.8742499,36.1436356)

new <- new %>% mutate(dish=ifelse(is.na(dish),"",dish))

save(new,file="foodie.rda")
saveRDS(new,file="~/Desktop/foodlist.rds")