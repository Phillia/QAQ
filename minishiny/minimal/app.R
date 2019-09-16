#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
#path defaults to where the app file physically sits
load("foodlist.rda")
rescat <- unique(new$category)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("A Personal Food Map For Nashville"),
  p("This real street map marks a list of my favorite restaurants/groceries in Nashville. 
      Click to filter different categories."),
  
  # UI input
  checkboxGroupInput("cat","Category",rescat,"restaurant",inline = TRUE),
  
  # Output
  leafletOutput("foodie"),
  
  #### KEEP A MINI DEBUGGER####
  br(),
  p("I always place a mini debugger in my draft to help debug reactive structure and comment it out later."),
  verbatimTextOutput("check")
  
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  #restaurants to map: 
  #create a reactive object that refreshes every time when the input changes
  res <- reactive({
    new[new$category %in% input$cat | new$category2 %in% input$cat,]
  })
  
  #### KEEP A MINI DEBUGGER####
  output$check <- renderPrint(
    res() %>% head()
  )
  
  #render output taking UI inputs or reactive objects 
  output$foodie <-  renderLeaflet({
    leaflet() %>% addTiles() %>%
      addMarkers(data=res(),lng=~longitude, lat=~lat, popup = ~paste('<strong>',name,'</strong>',"<br>",dish)) %>% 
      setView(-86.77435,36.16223,11)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)
