# UI - the front end (what the user sees)
# Common structure of input controls: inputId - which connects the front end with
# the back end.  If UI has an input with ID "name", the server function will access
# it with input$name
    #------------------#
    # Two constrains   #
    #------------------#
      # a. It must be a simple string that contains only letters, numbers, and 
      #     underscores, like a variable in R
      # b. It must be unique. If it's not unique, you'll have no way to refer to
      #     this control in the server function
# Most inputs have a second parameter called a "label" used to create human-readable
#   labels for the control. No restriction on labels
# The third parameter is "value", which lets you set the default value. 

ui <- fluidPage(
  numericInput("num","What's your favorite number",value = 0, min = 0, max = 1e+8), # constrained text box
  sliderInput("term", "Sub-term",value = 8, min = 0, max = 17), # only for small ranges where precision doesn't matter
  sliderInput("age_range","What's your age range?",value = c(18,22), min = 0, max = 100), #length-2 numeric vector, slider w. 2 ends
  textInput("name", "What's your name, buddy?"), # small amounts of text
  passwordInput("password", "Give me your bank account info"), # password info
  textAreaInput("story","Tell me about your dreams",placeholder = "Your dreams here", rows = 4), # paragraphs
  selectInput("state", "What is your favorite state",state.name), # chose from pre-specified set of options
  fileInput("upload",NULL), # file uploads
  actionButton("eat","Eat steak", icon = icon("cocktail"), class = "btn-danger"),
  sliderInput("widget","Select your pay range", min = 30, max = 120, value = 30,step = 5, 
              animate = animationOptions(interval = 1000, loop = T, 
                                         playButton = NULL, pauseButton = NULL)),
  
                                         # Outputs in the UI create placeholders that are later filled by the server function.
                                         # Outputs take unique ID and to access the output, you'll type output$ID
                                         # Three types of outputs:
                                         # a. Text - textOutput for regular text and `verbatimTextOutput` for fixed code
                                         # b. Tables - two options for displaying data frames
                                              # i. tableOutput() and renderTable() render a static table of data - for small, fixed summaries
                                              # ii. dataTableOutput() and renderDataTable() render a dynamic table - exposing complete data frames
                                              #       showing a fixed number of rows along with controls to change visible rows
                                         # c. Plots - all types of R graphics can be displayed (base, ggplot2, lattice, etc.) with plotOutput()
                                         #              and renderPlot()
                                         #              By default, plotOutput will take up the full width of its contained, and will be 400 px high. 
  textOutput("text"),
  verbatimTextOutput("chunky_code"),
  tableOutput("static"),
  dataTableOutput("dynamic"),
  plotOutput("plot",width = "700px", height = "300px")
)


 
server <- function(input,output,session){
  output$text <- renderText({ # `{}` are only required in render functions if need
                              # to run multiple lines of code. You should do as little
                              # computation in your render function as possible. 
    "Hello tiny friend"
  })
  output$chunky_code <- renderPrint({
    summary(log(1):log(25))
  })
  output$static <- renderTable(head(mtcars))
  output$dynamic <- renderDataTable(mtcars, options = list(pageLength = 5))
  output$plot <- renderPlot(plot(1:5), res = 96,
                            alt  = "Scatterplot of 5 random numbers")
}

shinyApp(ui,server)