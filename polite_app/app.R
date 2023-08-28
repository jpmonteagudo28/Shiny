library(shiny)
ui <- fluidPage(
  textInput("name","Hello, what is your name?"),
  textOutput("greeting"),
  numericInput("age", "How old are you?", value = NA),
  textOutput("age")
)

server <- function(input, output,session){
  output$greeting <- renderText({
    paste0("Hello ", input$name)
  })
  output$age <- renderText({
    if(!is.null(input$age))
    paste(input$age,"??", "You look young for your age!")
  })
}

shinyApp(ui,server)

ui <- fluidPage(
  sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
  sliderInput("y",label = "and y is", min = 1, max = 50, value = 5),
  "then x times y is",
  textOutput("product"),
  "and, (x * y) + 5 is", 
  textOutput("product_plus5"),
  "and (x * y) + 10 is", 
  textOutput("product_plus10")
)

server <- function(input, output, session) {
  product <- reactive({input$x * input$y})
  
  output$product <- renderText({ 
    product()
  })
  
  output$product_plus5 <- renderText({
    product() + 5
  })
  
  output$product_plus10 <- renderText({
    product() + 10
  })
}

shinyApp(ui, server)

