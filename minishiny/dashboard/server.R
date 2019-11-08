library(shiny)
library(leaflet)
library(htmltools)
library(dplyr)
library(tmaptools)

new <- readRDS("foodlist.rds")
rescat <- unique(new$category)
rescat2 <- unique(new[!is.na(new$sub),]$sub) 

shinyServer(function(input, output,session) {
    
    output$p1 <- renderImage({list(src = "1.png",width=300,height=300)}, deleteFile = FALSE)
    output$p2 <- renderImage({list(src = "2.png",width=600,height=300)}, deleteFile = FALSE)
    output$p3 <- renderImage({list(src = "3.png",width=800,height=300)}, deleteFile = FALSE)
    output$p4 <- renderImage({list(src = "4.png",width=600,height=300)}, deleteFile = FALSE)
    output$p6 <- renderImage({list(src = "6.png",width=800,height=300)}, deleteFile = FALSE)
    output$p7 <- renderImage({list(src = "7.png",width=900,height=400)}, deleteFile = FALSE)
    output$p8 <- renderImage({list(src = "8.png",width=900,height=450)}, deleteFile = FALSE)
    
    #select/deselect feature to update check boxes in UI
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

    
    #restaurants to map: create a reactive object that refreshes every time when the input changes
    #if concerned with performance, better to use action button to block reactivity before all input changes are made.
    res <- reactive({
        if("restaurant" %in% input$cat) {
            new %>% filter(category %in% input$cat | category2 %in% input$cat, sub %in% c(NA,input$cat2))
        } else {
            new %>% filter(category %in% input$cat | category2 %in% input$cat)
        }
    })
    
    #pop up feature: reactive value object takes a default value and updates upon certain conditions
    myloc <- reactiveVal(NULL)
    observeEvent(input$locate,{
        new <- geocode_OSM(paste0(input$loc,",USA"))
        if(!is.null(new)) {
            myloc(new$coords %>% t() %>% tbl_df())
        } else {
            myloc(NULL)
            #show an error message
            showNotification("Failed to geocode your location",type = "error")
        }
    })
    
    observeEvent(input$reset,{
        myloc(NULL)
    })
    
    #copy from Leaflet sample code
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
    
    #default output as a reactive object to prevent rerendering the entire map when a location is entered
    leaf1 <- reactive({
        leaflet() %>% addTiles() %>%
            addMarkers(data=res(),lng=~longitude, lat=~lat, popup = ~paste('<strong>',name,'</strong>',"<br>",dish)) %>% setView(-86.77435,36.16223,11)
    })
    
    #if location feature not triggered, render the default map, otherwise add one layer to the default
    output$foodie <-  renderLeaflet({
        if(is.null(myloc())) {
            leaf1() } else {
                leaf1() %>% addMarkers(data=myloc(),lng=~x, lat=~y,icon = greenLeafIcon,popup = "You are Here") %>% setView(myloc()$x,myloc()$y,14)
            }
    })
    
    
})


