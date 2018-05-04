library(shiny)
library(shinydashboard)
library(tidyverse)
library(glue)
library(DT)
library(colourpicker)

#topic: uninusred
#kff
#total: https://www.kff.org/other/state-indicator/total-population/?currentTimeframe=0&sortModel=%7B%22colId%22:%22Location%22,%22sort%22:%22asc%22%7D
#how many years
get_yr <- function(dt,key) {
        nam <- names(dt)
        substr(nam[grep(key,nam)],2,5)
}
uninsured.tot.pct <- read.csv("../../data/uninsured_total_pct.csv",skip=2) %>% filter(complete.cases(.))
uninsured.tot.pct <- uninsured.tot.pct %>% select(grep("Location|Uninsured",names(.))) %>% set_names("statename",paste0("uninsured_pct_",get_yr(uninsured.tot.pct,"Uninsured")))


source("helpers.R")

#### dashboard
sidebar <- dashboardSidebar(
includeCSS("www/style.css"),
sidebarMenu(id = "sidebar_menu",
            menuItem("Welcome", tabName = "welcome", icon = icon("home")),
            hr(),
            menuItem("Stories", tabName = "story", icon = icon("eye")),
            menuItem("Statistics", tabName = "studio", icon = icon("th-large")),
            menuItem("Static Map", tabName = "dashboard", icon = icon("map")),
            menuItem("Trend", tabName = "trend", icon = icon("line-chart")),
            hr(), 
            uiOutput("menuItem_specific_ui")
)
)

## |__body ------------------------------------------------------------------------------
body <- dashboardBody(
        tabItems(
                tabItem("welcome",
                        "askjh k"
                        ),
                tabItem("story",
                        "wqj cl k"
                ),
                tabItem("trend",
                        "qdw  cl k"
                ),
                tabItem("dashboard",
                        "jlfj cl k"
                ),
                
                ## |_____studio tab -----------------------------------------------------------------
                tabItem("studio",
                        helpText("A space to dynamically create value boxes corresponding",
                                 "to an aggregate summary of the data by subcategory for the selected", 
                                 "period of time."),
                        fluidRow(
                                column(3, 
                                       selectInput("studio_topic", "Choose topic", c("Uninsured","Price"),"Uninsured")
                                ),
                                column(2, 
                                       selectInput("studio_year", "Choose a year", c(2013:2016),2015)
                                ),
                                column(2, 
                                       selectInput("studio_geo", "Choose a geo unit", uninsured.tot.pct$statename, "United States")
                                ),
                                column(2, 
                                       radioButtons("studio_amount_direction", "Amount qualifier", c("Over", "Under"))
                                ),
                                column(3, 
                                       colourInput("studio_box_color", "Choose a color", palette = "limited",
                                                   allowedCols = c(
                                                           "#db4c3f", "#f19b2c", "#20c1ed", "#1074b5", "#408eba", "#17a55d", "#02203e", "#42cccb", 
                                                           "#419871", "#2afd77", "#fd852f", "#ed25bc", "#605ea6", "#d62161", "#111111"
                                                   ))
                                )
                        ),
                        fluidRow(
                                tags$div(id = "placeholder")
                        )
                )
        )
)

ui <- dashboardPage(skin = "purple",
                    dashboardHeader(title = "Healthcare Primer"), sidebar, body
)


server <- function(input, output, session) {
        
        ## UTILITIES --------------------------------------------------------------------------
        tab_list <- NULL
        
        subsettedData <- reactive({
                uninsured.tot.pct
        })

        subsetData <- function(categoryValues) {
                subsettedData()
        }

        output$menuItem_specific_ui <- renderUI({
                if (input$sidebar_menu == "dashboard") {
                        actionLink("remove_tabs", "Remove detail tabs")
                } else if (input$sidebar_menu == "studio") {
                        tagList(
                                actionButton("create_box", "Create new box", class = "color_btn"),
                                actionLink("remove_boxes", "Delete dynamic boxes")
                        )
                }
        })
        
        
        studioBoxColor <- reactive({
                if (input$studio_box_color == "#DB4C3F") "red"
                else if (input$studio_box_color == "#F19B2C") "yellow"
                else if (input$studio_box_color == "#20C1ED") "aqua"
                else if (input$studio_box_color == "#1074B5") "blue"
                else if (input$studio_box_color == "#408EBA") "light-blue"
                else if (input$studio_box_color == "#17A55D") "green"
                else if (input$studio_box_color == "#02203E") "navy"
                else if (input$studio_box_color == "#42CCCB") "teal"
                else if (input$studio_box_color == "#419871") "olive"
                else if (input$studio_box_color == "#2AFD77") "lime"
                else if (input$studio_box_color == "#FD852F") "orange"
                else if (input$studio_box_color == "#ED25BC") "fuchsia"
                else if (input$studio_box_color == "#605EA6") "purple"
                else if (input$studio_box_color == "#D62161") "maroon"
                else if (input$studio_box_color == "#111111") "black"
        })
        
        ## Add boxes
        observeEvent(input$create_box, {
                divID <- gsub("\\.", "", format(Sys.time(), "%H%M%OS3"))
                divClass <- glue("user-dynamic-box")
                btnID <- glue("remove-{divID}")
                
                sub_dat <- subsettedData() %>% filter(statename==input$studio_geo) %>% select(paste0("uninsured_pct_",input$studio_year))
                val <- prettyNum(sub_dat, big.mark = ",")
                
                direction <- if (input$studio_amount_direction == "Over") ">" else "<"
                
                insertUI(
                        selector = "#placeholder",
                        ui = div(id = divID, class = divClass,
                                 column(4, 
                                        actionButton(btnID, "X", class = "grey_btn pull-right"),
                                        valueBox(width = NULL,
                                                 value = glue("{val}"), 
                                                 subtitle = glue("{input$studio_topic} % in {input$studio_geo} ", 
                                                                 "for {input$studio_year}"), 
                                                 color = studioBoxColor()
                                        )
                                 )
                        )
                )
                
                observeEvent(input[[btnID]], {
                        removeUI(glue("#{divID}"))
                }, ignoreInit = TRUE, once = TRUE)
                
        }, ignoreInit = TRUE)
}

shinyApp(ui, server)


