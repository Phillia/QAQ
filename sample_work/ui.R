#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# search existing graphs
# 1.animated: size, add words
# 2.interactive: data, plot, words, customize legend
# 3.map: restaurant leaflet? dynamic subcat check, format
# 4.other: simple simulator?


library(shinydashboard)
library(leaflet)
library(DT)

load("foodie.rda")
rescat <- unique(new$category)
rescat2 <- unique(new[!is.na(new$sub),]$sub) 

sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("About", tabName = "home", icon = icon("dashboard")),
        menuItem("Animated graphs", icon = icon("chart-line"), tabName = "p1"),
        menuItem("Interactive", icon = icon("heartbeat"), tabName = "p2"),
        menuItem("Nashville Food Map", icon = icon("utensils"), tabName = "p3"),
        menuItem("Others", icon = icon("th"), tabName = "p4")
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "home",
                h2("About This Page"),
                br(),
                p("This is a Shiny app compiling some data visualization examples I programmed in R. 
                The main purpose of this app to demonstrate my skills and flexibility to present data and make them more accessible to a broader audience.
                I drew on projects at and outside of my work and either directly included the graphic outputs or produced simple examples.
                I hope to apply such skills to promoting effective communication of data, evidence-based decision-making, and country ownership of SDGs.
                  "),
                br(),
                h2("What is Shiny app?"),
                p("A Shiny app is an interactive web app written in R using the \"Shiny\" package. 
                  For more information, please check their website:"),
                tags$a(href="https://shiny.rstudio.com", "Click here"),
                
                h2("About Me"),
                p("My name is Zilu Zhou and I have been working as health policy analyst at Vanderbilt University Medical Center since 2016.
                In my current position, I regularly create a variety of graphs for data exploration and academic manuscripts 
                as well as interacitve Shiny Apps to promote dissemination of research findings.
                As a proficient R user, I am familiar with \"ggplot2\", \"leaflet\", and \"shiny\" packages and 
                have experience in plotting geospatial data and designing complicated user interface for Shiny apps."),
                p("Please email zhouzilu.gens@gmail.com with any questions about this web app or my work.")
                #HTML(<ahref="mailto:hello@rshiny.com?"> click here for email! </a>)
                
        ),
        
        tabItem(tabName = "p1",
                h2("Animated graphs"),
                br(),
                # http://www.user2019.fr/datathon/
                # Note: Plot theme adapted from Christopher Adolph’s code (faculty.washington.edu/cadolph).
                p("Description: I produced these two animated graphs for my team submission to the Datathan Challenge 
                  organized by useR! 2019 Conference  and the French Statistical Society (SFdS). In the data challenge, my team
                  used data from the Health Nutrition and Population Statistics database hosted by the World Bank Group to demonstrate
                  an association between child mortality and female education. Our submission was ranked second."),
                fluidRow(
                    column(width=12,imageOutput("animated1"))
                ),
                br(),
                fluidRow(
                    column(width=12,imageOutput("animated2"))
                )
                
        ),
        
        tabItem(tabName = "p2",
                h2("Interactive graphs on uninsured rates in USA"),
                br(),
                p("Description: Plot uninsured rates among US non-elderly adults (age 18-64) using KFF data. 
                Weighting state hexagon by number of uninsured adds another layer of data to the map.
                Data from KFF PUF:"),
                fluidRow(
                    column(width=3,
                           #numericInput("yr","Select Year",2013,2013,2016,1)),
                           tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"),
                           sliderInput("yr","Select Year",2013,2016,2013,1,sep="")),
                    column(width=3,
                           radioButtons("carto","Weighted by uninsured number",c("Yes","No"),"No")),
                    column(width=3,
                           actionButton("click","Click to apply changes"))
                ),
                fluidRow(
                    leafletOutput("uninsured")
                ),
                p("View the raw data. Sorting and filtering are enabled. Click here to download as csv."),
                fluidRow(
                    downloadButton("downloadData", "Download"),
                    DTOutput("uninsured_tb")
                )
        ),
        
        tabItem(tabName = "p3",
                h2("A Personal Food Map for Nashville"),
                br(),
                p("Description: Geocode and map a list of restaurants in Nashville. Click to filter different categories."),
                fluidRow(
                    textInput("loc","My Location (Enter Street/City/Zip for best results)", "2525 West End Ave, Nashville, TN 37203"),
                    actionButton("locate","Click to pop up your location on map")
                ),
                fluidRow(
                    column(width=3,
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
                    verbatimTextOutput("check"),
                    leafletOutput("foodie")
                )
        ),
        
        tabItem(tabName = "p4",
                h2("Other graphics: TBA")
        )
        
    )
)

# Define UI for application that draws a histogram
shinyUI(
    
    dashboardPage(
        dashboardHeader(title="Sample Data Viz"),
        sidebar,
        body
    )
)
