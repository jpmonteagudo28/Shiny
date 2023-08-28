# REACTIVE PROGRAMMING - RECIPES and NOT just COMMANDS
# Server function; takes three arguments:
      # 1. The input
            # a. List-like object that contains all the input data sent from browser
            # b. Input objects are read-only. Cannot be modified in the server function
            # c. To read from an input, you must be in a reactive context created by a function
      # 2. The output
            # a. list-like object named according to OutputID
            # b. Used for sending output instead of receiving input
            # Output object always used with a render function
                  # i. The render function sets up a special reactive context that automatically
                  #           tracks what inputs the output uses
                  # ii. converts the output of your R code into HTML suitable for display on HTML
      # 3. The session

# Reactive programming: outputs automatically update as inputs change. You don't need to tell an output when
# to update because Shiny automatically updates is based on the user input as it is happening. 

      # output$greeting <- renderText({
      # paste0("Hello ", input$name, "!")
      # })

# The app works because the code you provided doesn't tell Shiny to create the string and send it to the browser,
# instead, it informs Shiny how it could create the string if it needs to. 
# You're teaching Shiny how to put inputs together to display as outputs if an input is ever entered. 

      # IMPERATIVE PROGRAMMING: issue a specific command and it's carried out immediately. Used in analysis scripts. 
      # DECLARATIVE PROGRAMMING: express a higher-level goals or describe important constrains, and rely on someone
      #       else to decide how and/or when to translate that into action. 
            # One strength of Declarative Programming is that allows apps to be extremely lazy
            # A Shiny app will only do the minimal work needed to update the output controls that you currently use
            # A Shiny app will not throw an error code if the identifiers don't match. It will wait for input that matches
            #     the identifier you provided. 
            # Code is only run when needed
                  # To understand the order of execution, we look at the reactive graphs, which describe
                  # how inputs and outputs are connected. The graph tells you that the output will need 
                  # to be recomputed whenever the input is changed. This relationship of the output
                  # has a REACTIVE DEPENDENCY on the input.
      # REACTIVE EXPRESSIONS: tools that reduce duplication in your reactive code by introducing
      #      additional nodes into the reactive graph. 
          
                # server <- function(input, output, session) {
                # string <- reactive(paste0("Hello ", input$name, "!")) REACTIVE EXPRESSION
                # output$greeting <- renderText(string())
                # }

            # a. Reactive expressions take inputs and produce outputs so they have a shape that combines features
            #       of both inputs and outputs. 
            # b. EXECUTION ORDER: the order the code is run is solely determined by the reactive graph, not the order
            #       of the lines. 
            # c. Like inputs, the result of reactive expressions can be used in an output
            # d. Like outputs, reactive expressions depend on inputs and automatically know
            #       when they need updating
            # e. Outputs are atomic - they're either executed or not as a whole.

# Example (Mastering Shiny 3.4.1)

# I want to compare two simulated datasets with a plot and a hypothesis test. 
# I’ve done a little experimentation and come up with the functions below: freqpoly() 
# visualises the two distributions with frequency polygons12, and t_test() uses a t-test 
# to compare means and summarises the results with a string:

library(ggplot2)

freqpoly <- function(x1, x2, binwidth = 0.1, xlim = c(-3, 3)) {
  df <- data.frame(
    x = c(x1, x2),
    g = c(rep("x1", length(x1)), rep("x2", length(x2)))
  )
  
  ggplot(df, aes(x, colour = g)) +
    geom_freqpoly(binwidth = binwidth, size = 1) +
    coord_cartesian(xlim = xlim)
}

t_test <- function(x1, x2) {
  test <- t.test(x1, x2)
  
  # use sprintf() to format t.test() results compactly
  sprintf(
    "p value: %0.3f\n[%0.2f, %0.2f]",
    test$p.value, test$conf.int[1], test$conf.int[2]
  )
}

x1 <- rnorm(100, mean = 0, sd = 0.5)
x2 <- rnorm(200, mean = 0.15, sd = 0.9)

freqpoly(x1, x2)
cat(t_test(x1, x2))
#> p value: 0.005
#> [-0.39, -0.07]

# This is good software engineering because it helps isolate concerns: 
# the functions outside of the app focus on the computation so that the code 
# inside of the app can focus on responding to user actions.

ui <- fluidPage(
  fluidRow(
    column(4, 
           "Distribution 1",
           numericInput("n1", label = "n", value = 1000, min = 1),
           numericInput("mean1", label = "µ", value = 0, step = 0.1),
           numericInput("sd1", label = "σ", value = 0.5, min = 0.1, step = 0.1)
    ),
    column(4, 
           "Distribution 2",
           numericInput("n2", label = "n", value = 1000, min = 1),
           numericInput("mean2", label = "µ", value = 0, step = 0.1),
           numericInput("sd2", label = "σ", value = 0.5, min = 0.1, step = 0.1)
    ),
    column(4,
           "Frequency polygon",
           numericInput("binwidth", label = "Bin width", value = 0.1, step = 0.1),
           sliderInput("range", label = "range", value = c(-7, 7), min = -12, max = 12)
    )
  ),
  fluidRow(
    column(9, plotOutput("hist")),
    column(3, verbatimTextOutput("ttest"))
  )
)

server <- function(input, output, session) {
  x1 <- reactive(rnorm(input$n1,input$mean1, input$sd1))
  x2 <- reactive(rnorm(input$n2,input$mean2, input$sd2))
  output$hist <- renderPlot({
        freqpoly(x1(), x2(), binwidth = input$binwidth, xlim = input$range)
  }, res = 96)
  
  output$ttest <- renderText({
        t_test(x1(), x2())
  })
}

shinyApp(ui,server)

# Notice that the server function calculates x1 and x2 separately and updates it twice
# id one was to update on element from each variable (n1, and sd2). The freqpoly and t-test
# use separate random draws instead of the same underlying data. 
    # We can fix this by using reactive expressions for x1 and x2

# x1 <- reactive(rnorm(input$n1,input$mean1, input$sd1))
# x2 <- reactive(rnorm(input$n2,input$mean2, input$sd2))

#---------------------------------#
# Controlling timing of evaluation #
#---------------------------------#

ui <- fluidPage(
  fluidRow(
    column(3, 
           numericInput("lambda1", label = "lambda1", value = 3),
           numericInput("lambda2", label = "lambda2", value = 5),
           numericInput("n", label = "n", value = 1e4, min = 0)
    ),
    column(9, plotOutput("hist"))
  )
)
server <- function(input, output, session) {
  timer <- reactiveTimer(500)
  x1 <- reactive({timer() 
    rpois(input$n, input$lambda1)
    }) # only 1 parameter
  x2 <- reactive({timer() 
    rpois(input$n, input$lambda2)
    })
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40)) # both samples share same n
  }, res = 96)
}
shinyApp(ui,server)

# If you wanted to reinforce the fact that this is for simulated data by constantly
# resimulating the data, so that you see an animation rather than a static plot. 
      # We can increase the frequency of the updates with `reactiveTimer()`
            # `reactiveTimer()` - is a reactive expression that has a dependency on a hiden input - the current time
            # You can use this function when you want a reactive expression to invalidate itself more often than it 
            #     otherwise would. 
      # We can require the user to opt-in to performing the calculation by requiring them to click a button
      # when the time to run the code exceeds the frequency of the generated simulations; i.e. the code takes 1 sec to run
      # but we ask Shiny to perform the simulation every .5 seconds, causing a backlog for Shiny.
            # `actionButton()` - used for requiring updates only when the user interacts with the button (click)

ui <- fluidPage(
  fluidRow(
    column(3, 
           numericInput("lambda1", label = "lambda1", value = 3),
           numericInput("lambda2", label = "lambda2", value = 5),
           numericInput("n", label = "n", value = 1e4, min = 0),
           actionButton("simulate", "Simulate!")
    ),
    column(9, plotOutput("hist"))
  )
)
server <- function(input, output, session) {
  x1 <- reactive({
    input$simulate
    rpois(input$n, input$lambda1)
  })
  x2 <- reactive({
    input$simulate
    rpois(input$n, input$lambda2)
  })
  output$hist <- renderPlot({
    freqpoly(x1(), x2(), binwidth = 1, xlim = c(0, 40))
  }, res = 96)
}
shinyApp(ui,server)