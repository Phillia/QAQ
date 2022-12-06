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
        menuItem("Animated", icon = icon("chart-line"), tabName = "p1"),
        menuItem("Interactive", icon = icon("heartbeat"), tabName = "p2"),
        menuItem("Street Map", icon = icon("utensils"), tabName = "p3"),
        menuItem("Other", icon = icon("th"), tabName = "p4")
    )
)

body <- dashboardBody(
    tabItems(
        tabItem(tabName = "home",
                h2("About This Page"),
                br(),
                p("This is a Shiny app compiling data visualization examples I programmed in R. 
                The main purpose of this app is to demonstrate my data visualization skills."),
                br(),
                h2("What is Shiny app?"),
                p("A Shiny app is an interactive web app written in R using the \"Shiny\" package. 
                  For more information, please check their website:"),
                tags$a(href="https://shiny.rstudio.com", "Click here",target="_blank"),
                
                h2("About Me"),
                p("My name is Zilu Zhou and I worked as a data analyst at Vanderbilt University Medical Center from 2016 to 2021.
                In that position, I created a variety of graphs for data exploration and academic manuscripts 
                as well as interacitve Shiny Apps to promote dissemination of research findings.
                As a proficient R user, I am familiar with \"ggplot2\", \"leaflet\", and \"shiny\" packages and 
                have experience in plotting geospatial data and designing complicated user interface in Shiny apps."),
                p("Please email zhouzilu.gens@gmail.com with any questions about this web app or my work.")
                #HTML(<ahref="mailto:hello@rshiny.com?"> click here for email! </a>)
                
        ),
        
        tabItem(tabName = "p1",
                h2("Linking Child Health And Female Education"),
                # http://www.user2019.fr/datathon/
                # Note: Plot theme adapted from Christopher Adolph’s code (faculty.washington.edu/cadolph).
                p("These two animated graphs were created for my team submission to the Datathan Challenge 
                  organized by useR! 2019 Conference and the French Statistical Society (SFdS). In the data challenge, my team
                  used a public dataset from the Health Nutrition and Population Statistics database hosted by the World Bank Group to demonstrate
                  an association between child mortality and female education."),
                p("Note: Graphic themes adapted from Dr. Christopher Adolph’s codes (faculty.washington.edu/cadolph)."),
                tags$a(href="http://www.user2019.fr/datathon/","http://www.user2019.fr/datathon/",target="_blank"),
                br(),
                br(),
                fluidRow(
                    column(width=12,imageOutput("animated1"))
                ),
                br(),
                fluidRow(
                    column(width=12,imageOutput("animated2"))
                )
                
        ),
        
        tabItem(tabName = "p2",
                h2("Uninsured Rates Among US Adults, 2013-2017"),
                p("Interactive plots of uninsured rates among US non-elderly adults (age 18-64) using 
                state-level data published by Henry J Kaiser Family Foundation."), 
                p("Feel free to select year of data and un-adjusted/weighted option, and click the \"Update\" button to render the plot.
                The weighting method changes the size of state hexagons to reflect variation in the uninsured population size across states, 
                which adds another layer of data to the map.
            "),
                
                sidebarLayout(
                    sidebarPanel(
                        tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"),
                        sliderInput("yr","Select Year",2013,2017,2013,1,sep=""),
                        radioButtons("carto","Weighted by uninsured number",c("Yes","No"),"No"),
                        actionButton("click","Update")
                    ),
                    mainPanel(leafletOutput("uninsured"))
                ),
                br(),br(),
                h4("View Data"),
                fluidRow(
                    column(7,p("Sorting and filtering are enabled. Click \"Download\" button to save the data as a csv.")),
                    column(2,downloadButton("downloadData", "Download")),
                    column(3,tags$a(href="https://bit.ly/2zQKL3F", "Link to original data source",target="_blank"))
                ),
                br(),
                fluidRow(
                    column(12,DTOutput("uninsured_tb"))
                )
                
        ),
        
        tabItem(tabName = "p3",
                h2("A Personal Food Map For Nashville"),
                p("This real street map marks a list of my favorite restaurants/groceries in Nashville. 
                Click to filter different categories.
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
               # fluidRow(
               #     column(width=7,
               #            textInput("loc","Optional: Pop Up My Location (Street/City/Zip)", "2525 West End Ave, Nashville, TN 37203",width="100%")
               #     ),
               #     column(width=4,
               #            fluidRow("", style = "height:25px;"),
               #            actionButton("locate","Update"),
               #            actionButton("reset","Reset")
               #     )),
                fluidRow(
                    #### KEEP A MINI DEBUGGER####
                    #verbatimTextOutput("check"),
                    leafletOutput("foodie")
                )
        ),
        
        tabItem(tabName = "p4",
                h2("Under Contruction")
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
