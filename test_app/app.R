library(shiny)
library(ggplot2)

datasets <- c("economics", "faithful", "seals","iris","mtcars","ChickWeight","airquality")
UI <- fluidPage( #setting basic visual structure
  selectInput("dataset", label = "Dataset", choices = datasets), #input control
  verbatimTextOutput("summary"), # output controls displays the code
  plotOutput("plot") # displays tables
)
server <- function(input, output, session){#output$ID providing the "recipe" for the output with that ID
  #Creating a reactive expression
  dataset <- reactive({
    get(input$dataset,"package:ggplot2")
  })
  output$summary <- renderPrint({ # renderPrint is paired with verbatimTextOutput to display stat summary
  #Reactive expression used here like a function
    summary(dataset())  # render functions wrap the code I provided
  })  
  
  output$plot <- renderPlot({ # renderPlot paired with tableOutput() to show input data in table
    plot(dataset())
  }, res = 96)
}

shinyApp(UI,server)
