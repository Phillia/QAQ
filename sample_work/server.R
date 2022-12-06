#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(scales)
library(cartogram)
library(leaflet)
library(RColorBrewer)
library(htmltools)
library(dplyr)
library(DT)
library(tmaptools)

load("cleaned_shp.rda")
pall <- colorNumeric("YlOrRd", NULL)
load("foodie.rda")
rescat <- unique(new$category)
rescat2 <- unique(new[!is.na(new$sub),]$sub) 

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
    
    #### P1 ####
    output$animated1 <- renderImage({
        
        # Return a list containing the filename
        list(src = "animated1.gif",
             contentType = 'image/gif'
             # width = 400,
             # height = 300,
             # alt = "This is alternate text"
        )}, deleteFile = FALSE)
    
    output$animated2 <- renderImage({
        
        # Return a list containing the filename
        list(src = "animated2.gif",
             contentType = 'image/gif'
        )}, deleteFile = FALSE)
    
    #### P2 ####
    #data to plot
    dtplot <- eventReactive(input$click,{
        if(input$carto=="Yes") {
            state_carto <- cartogram_cont(states.shp, paste0("uninsured_num_",input$yr))
            state_carto@data$xcentroid <- sp::coordinates(state_carto)[,1]
            state_carto@data$ycentroid <- sp::coordinates(state_carto)[,2]
            state_carto@data$rate <- state_carto@data[,paste0("uninsured_pct_",input$yr)]
            return(state_carto)
        } else {
            states.shp@data$xcentroid <- sp::coordinates(states.shp)[,1]
            states.shp@data$ycentroid <- sp::coordinates(states.shp)[,2]
            states.shp@data$rate <- states.shp@data[,paste0("uninsured_pct_",input$yr)]
            return(states.shp)
        } 
    },ignoreNULL = FALSE)
    
    output$uninsured_tb <- renderDT(
        states.shp@data %>% select(state_abb=st,state_name=statename,starts_with("uninsured")),
        filter="top",
        options=list(pageLength = 5, autoWidth = TRUE)
    )
    
    output$uninsured <-  renderLeaflet({
        leaflet(data=dtplot()) %>%
            addPolylines(stroke = TRUE, weight = 1, color = "#444444", fill = FALSE) %>%
            addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity =0.5, fillColor = ~pall(rate)) %>%
            addLabelOnlyMarkers(lng=~xcentroid, lat=~ycentroid, label =  ~as.character(st),
                                labelOptions = labelOptions(noHide = TRUE, textOnly = TRUE,
                                                            style=list("font-size" = "6px"))) %>% 
            addMarkers(lng=~xcentroid, lat=~ycentroid, label =  ~as.character(percent(rate)),
                       options = markerOptions(riseOnHover=TRUE,opacity=0)) %>% 
            addLegend("bottomright",pal = pall,values = seq(0,0.2,0.01),#~rate,
                      labFormat = labelFormat(suffix = "%", between = ", ",transform = function(x) 100 * x),
                      title = "Uninsured Rate %"
            ) %>% setView(-99.9,40.7,zoom = 3)
    })
    
    output$downloadData <- downloadHandler(
        filename = "KFF_uninsured_state_2013_16.csv",
        content = function(file) {
            write.csv(states.shp@data %>% select(state_abb=st,state_name=statename,starts_with("uninsured")), file, row.names = FALSE)
        }
    )
    
    #### P3 ####
    observe({
        updateCheckboxGroupInput(
            session, 'cat', choices = rescat,
            selected = if (input$bar1) rescat
        )
    })
    
    observe({
        updateCheckboxGroupInput(
            session, 'cat2', choices = rescat2,
            selected = if (input$bar2) rescat2,
            inline = TRUE
        )
    })

    
    #restaurants to map
    res <- reactive({
        if("restaurant" %in% input$cat) {
            new %>% filter(category %in% input$cat | category2 %in% input$cat, sub %in% c(NA,input$cat2))
        } else {
            new %>% filter(category %in% input$cat | category2 %in% input$cat)
        }
    })
    
    #pop up feature
    myloc <- reactiveVal(NULL)
    #observeEvent(input$locate,{
    #    new <- geocode_OSM(paste0(input$loc,",USA"))
    #    if(!is.null(new)) {
    #        myloc(new$coords %>% t() %>% tbl_df())
    #    } else {
    #        myloc(NULL)
    #        showNotification("Failed to geocode your location",type = "error")
    #    }
    #})
    
    #observeEvent(input$reset,{
    #    myloc(NULL)
    #})
    
    greenLeafIcon <- makeIcon(
        iconUrl = "http://leafletjs.com/examples/custom-icons/leaf-green.png",
        iconWidth = 38, iconHeight = 95,
        iconAnchorX = 22, iconAnchorY = 94,
        shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
        shadowWidth = 50, shadowHeight = 64,
        shadowAnchorX = 4, shadowAnchorY = 62
    )
    
    #### KEEP A MINI DEBUGGER####
    # output$check <- renderPrint(
    #     myloc()
    # )
    
    leaf1 <- reactive({
        leaflet() %>% addTiles() %>%
            addMarkers(data=res(),lng=~longitude, lat=~lat, popup = ~paste('<strong>',name,'</strong>',"<br>",dish)) %>% setView(-86.77435,36.16223,11)
    })
    
    output$foodie <-  renderLeaflet({
        if(is.null(myloc())) {
            leaf1() } else {
                leaf1() %>% addMarkers(data=myloc(),lng=~x, lat=~y,icon = greenLeafIcon,popup = "You are Here") %>% setView(myloc()$x,myloc()$y,14)
            }
    })
    
    
})

#### plot size issue
#### https://stackoverflow.com/questions/29179088/flexible-width-and-height-of-pre-rendered-image-using-shiny-and-renderimage

# t0 <- "2525 West End Ave, Nashville, TN 37203"
# t1 <- "48 White Bridge Road, Nashville, TN 37205"
# geocode_OSM(t0)
# geocode_OSM(t1)

