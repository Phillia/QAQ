library(rgdal)
library(maptools)
library(tidyverse)
library(scales)

#topic: uninusred
#kff
#total: https://www.kff.org/other/state-indicator/total-population/?currentTimeframe=0&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D
#how many years
get_yr <- function(dt,key) {
    nam <- names(dt)
    substr(nam[grep(key,nam)],2,5)
}
uninsured.tot.pct <- read.csv("uninsured_total_pct.csv",skip=2) %>% select(-Footnotes) %>% filter(complete.cases(.))
uninsured.tot.pct <- uninsured.tot.pct[-1,] %>% select(grep("Location|Uninsured",names(.))) %>% set_names("statename",paste0("uninsured_pct_",get_yr(uninsured.tot.pct,"Uninsured")))
uninsured.tot.num <- read.csv("uninsured_total_num.csv",skip=2) %>% select(-Footnotes) %>% filter(complete.cases(.))
uninsured.tot.num <- uninsured.tot.num[-1,] %>% select(grep("Location|Uninsured",names(.))) %>% set_names("statename",paste0("uninsured_num_",get_yr(uninsured.tot.num,"Uninsured")))


states.shp <- readOGR(dsn="./us_states_hexgrid/us_states_hexgrid.shp",
                      layer = "us_states_hexgrid",verbose = FALSE)
states.shp@data <- states.shp@data %>% 
    mutate(statename=gsub(" \\(United States\\)","",google_nam)) %>%
    select(st=iso3166_2,statename)

states.shp@data <- states.shp@data %>% left_join(uninsured.tot.pct,by="statename") %>% left_join(uninsured.tot.num,by="statename")

save(states.shp,file="cleaned_shp.rda")

# https://xinye1.github.io/projects/brexit-cartogram-leaflet/
# hexagon -> carto


library(cartogram)
state_carto <- cartogram_cont(states.shp, "uninsured_num_2016")
state_carto@data$xcentroid <- sp::coordinates(state_carto)[,1]
state_carto@data$ycentroid <- sp::coordinates(state_carto)[,2]

library(leaflet)
library(RColorBrewer)
pall <- colorNumeric("YlOrRd", NULL)
leaflet(data=state_carto) %>%
    addPolylines(stroke = TRUE, weight = 1, color = "#444444", fill = FALSE) %>%
    addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity =0.5, fillColor = ~pall(uninsured_pct_2016)) %>%
    addLabelOnlyMarkers(lng=~xcentroid, lat=~ycentroid, label =  ~as.character(st),
                        labelOptions = labelOptions(noHide = TRUE, textOnly = TRUE,
                                                    style=list("font-size" = "6px"))) %>% 
    addMarkers(lng=~xcentroid, lat=~ycentroid, label =  ~as.character(percent(uninsured_pct_2016)),
               options = markerOptions(riseOnHover=TRUE,opacity=0)) %>% 
    addLegend("bottomleft",pal = pall,values = ~uninsured_pct_2016,labFormat = labelFormat(
        prefix = "(", suffix = ")%", between = ", ",
        transform = function(x) 100 * x
    ))

#centroid: KY
# library(maptools)
# library(rgeos)
# landuse <- readShapePoly("landuse") 
# 
# centr <- gCentroid(landuse, byid = TRUE)

