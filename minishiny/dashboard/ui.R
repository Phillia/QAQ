library(shinydashboard)
library(leaflet)

load("foodlist.rda")
rescat <- unique(new$category)
rescat2 <- unique(new[!is.na(new$sub),]$sub) 

#Menu sidebar
sidebar <- dashboardSidebar(
    #multiple menu items on the left
    sidebarMenu(
        menuItem("About", tabName = "home", icon = icon("dashboard")),
        menuItem("How to Start", icon = icon("chart-line"), tabName = "p1"),
        menuItem("Simple Case", icon = icon("chart-line"), tabName = "p2"),
        menuItem("Refined Version", icon = icon("utensils"), tabName = "p3")
    )
)

#Main panel contents
body <- dashboardBody(
    tabItems(
        #page body corresponding to each menu item tab
        tabItem(tabName = "home",
                h2("What is Shiny app?"),
                p("A Shiny app is an interactive web app written in R using the \"Shiny\" package. 
                  For more information, please check their website:"),
                tags$a(href="https://shiny.rstudio.com", "Click to learn more",target="_blank"),
                h2("Leaflet in R?"),
                p("Leaflet is very handy when it comes to create interactive maps.
                  It can directly plot shape files. 
                  You can also use the default street map tiles."),
                tags$a(href="https://rstudio.github.io/leaflet/","Click to learn more",target="_blank"),
                h2("Other Resources"),
                tags$a(href="https://rstudio.github.io/shinydashboard/","Easy dashboards with \"shinydashboard\""),
                br(),
                tags$a(href="https://shiny.rstudio.com/articles/cheatsheet.html","Shiny cheat sheet",target="_blank"),
                br(),
                tags$a(href="https://data.boston.gov/showcase/imagine-boston-2030-metrics-dashboard",
                       "Real-world User Case: Imagine Bostion 2030 Metrics Dashboard",target="_blank")
        ),
        
        tabItem(tabName = "p1",
                h3("Start from code template in RStudio"),
                splitLayout(
                    cellWidths = c("320", "600"),
                    imageOutput("p1"),
                    imageOutput("p2")
                ),
                h3("Click \"Run App\" on top right"),
                fluidRow(column(12,imageOutput("p3"))),
                h3("Click \"Publish\" button to publish app on server (2 options)"),
                fluidRow(column(12,imageOutput("p4"))),
                h3("Essentially you just fill the two buckets"),
                fluidRow(column(12,imageOutput("p6")))
                
                
        ),
        
        tabItem(tabName = "p2",
                h3("Example"),
                tags$a(href="https://ziluzhou.shinyapps.io/minimal/","Demo",target="_blank"),
                br(),
                fluidRow(column(12,imageOutput("p7"))),
                fluidRow(style = "padding-top:20px",column(12,imageOutput("p8")))
        ),
        
        tabItem(tabName = "p3",
                h2("A Personal Food Map For Nashville"),
                p("This real street map marks a list of my favorite restaurants/groceries in Nashville. 
                Click to filter different categories.
                  Entering your current location will rezoom the map to show spots close to you.
                  Bon appetit!
                  "),
                fluidRow(
                    column(width=4,
                           checkboxGroupInput("cat","Category",rescat,rescat),
                           checkboxInput('bar1', 'Select/Deselect All',TRUE)
                    ),
                    
                    column(width=6,
                           conditionalPanel(
                               condition="input.cat.includes('restaurant')",
                               checkboxGroupInput("cat2","Cuisine",rescat2,rescat2,inline = TRUE),
                               checkboxInput('bar2', 'Select/Deselect All',TRUE)
                           ))
                ),
                fluidRow(
                    column(width=7,
                           textInput("loc","Optional: Pop Up My Location (Street/City/Zip)", "2525 West End Ave, Nashville, TN 37203",width="100%")
                    ),
                    column(width=4,
                           fluidRow("", style = "height:25px;"),
                           actionButton("locate","Update"),
                           actionButton("reset","Reset")
                    )),
                fluidRow(
                    #### KEEP A MINI DEBUGGER####
                    #verbatimTextOutput("check"),
                    leafletOutput("foodie")
                )
        )
        
    )
)

# Define UI for application that draws a histogram
shinyUI(
    
    dashboardPage(
        dashboardHeader(title="Shiny Dashboard Example"),
        sidebar,
        body
    )
)
