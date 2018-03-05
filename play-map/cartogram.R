### cartogram
# https://team.carto.com/u/andrew/tables/andrew.us_states_hexgrid/public/map
rm(list=ls())
library(rgdal)
library(maptools)
library(tidyverse)

states.shp <- readOGR(dsn="./us_states_hexgrid/us_states_hexgrid.shp",
                     layer = "us_states_hexgrid",verbose = FALSE)
states.shp@data <- states.shp@data %>% 
        mutate(statename=gsub(" \\(United States\\)","",google_nam)) %>%
        select(st=iso3166_2,statename)


# https://xinye1.github.io/projects/brexit-cartogram-leaflet/
# hexagon -> carto
library(cartogram)
states.shp@data <- states.shp@data %>% left_join(uninsured.tot.pct,by="statename")
state_carto <- cartogram(states.shp, "uninsured_pct_2016")
state_carto@data$xcentroid <- sp::coordinates(state_carto)[,1]
state_carto@data$ycentroid <- sp::coordinates(state_carto)[,2]

library(leaflet)
library(RColorBrewer)
pall <- colorNumeric("viridis", NULL)
leaflet(data=state_carto) %>%
        addPolylines(stroke = TRUE, weight = 1, color = "#444444", fill = FALSE) %>%
        addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity =0.5, fillColor = ~pall(uninsured_pct_2016), label=~as.character(uninsured_pct_2016)) %>%
        addLabelOnlyMarkers(lng=~xcentroid, lat=~ycentroid, label =  ~as.character(st),
                            labelOptions = labelOptions(noHide = TRUE, direction = 'top', textOnly = TRUE,
                                                        style=list("font-size" = "10px")))



# http://staff.math.su.se/hoehle/blog/2016/10/10/cartograms.html

# http://rpubs.com/bhaskarvk/tilegramsR

# http://homepage.divms.uiowa.edu/~luke/classes/STAT4580/maps.html#proportion-of-population-without-health-insurance


#####TO DO
# State/county uninsured
# Cartogram
# 
# Medicaid expansion
# Hexagons?
# 
# Coverage composition
# Stacked bar
# Ggplot2?





# Scratch
# library(map_tools)
# state2 <- state_hex
# state2@data$xcentroid <- sp::coordinates(state2)[,1]
# state2@data$ycentroid <- sp::coordinates(state2)[,2]
# clean <- function(shape) {
#         shape@data$id = rownames(shape@data)
#         shape.points = fortify(shape, region="id")
#         shape.df = merge(shape.points, shape@data, by="id")
# }
# state_df <- clean(state2)st



# trans <- function(dt,type) {
#         
#         # convert it to Albers equal area
#         us_aea <- spTransform(dt, CRS("+proj=laea +lat_0=45 +lon_0=-100 +x_0=0 +y_0=0 +a=6370997 +b=6370997 +units=m +no_defs"))
#         us_aea@data$id <- rownames(us_aea@data)
#         
#         ###rules to filter states
#         if(type=="rating") {
#                 alaska <- us_aea[grepl("AK_*",us_aea$name),]
#                 hawaii <- us_aea[grepl("HI_*",us_aea$name),]
#                 alaska <- elide(alaska, rotate=-50)
#                 alaska <- elide(alaska, scale=max(apply(bbox(alaska), 1, diff)) / 2.3)
#                 alaska <- elide(alaska, shift=c(-1870000, -2500000))
#         } else if (type=="county") {
#                 alaska <- us_aea[us_aea$STATEFP=="02",]
#                 hawaii <- us_aea[us_aea$STATEFP=="15",]
#                 alaska <- elide(alaska, rotate=-50)
#                 alaska <- elide(alaska, scale=max(apply(bbox(alaska), 1, diff)) / 2.3)
#                 alaska <- elide(alaska, shift=c(-2100000, -2500000))
#         } else stop("type error")
#         
#         # extract, then rotate, shrink & move alaska (and reset projection)
#         proj4string(alaska) <- proj4string(us_aea)
#         
#         # extract, then rotate & shift hawaii
#         hawaii <- elide(hawaii, rotate=-35)
#         hawaii <- elide(hawaii, shift=c(5400000, -1400000))
#         proj4string(hawaii) <- proj4string(us_aea)
#         
#         if(type=="rating") {
#                 us_aea <- us_aea[!grepl("AK_*",us_aea$name) & !grepl("HI_*",us_aea$name),]
#         } else if (type=="county") {
#                 us_aea <- us_aea[!us_aea$STATEFP %in% c("02", "15", "72"),]
#         } else stop("type error")
#         
#         us_aea <- rbind(us_aea, alaska, hawaii)
#         # remove old states and put new ones back in; note the different order
#         # we're also removing puerto rico in this example but you can move it
#         # between texas and florida via similar methods to the ones we just used
#         
#         us_aea2 <- spTransform(us_aea, proj4string(dt))
#         
#         return(us_aea2)
# }
# state_shp <- trans(state_raw,"county")
# 
# save(state_shp,file="state_shp.rda")
