library(shiny)
library(wizardR)
library(future)
library(promises)
future::plan(future::multisession)


ui <- fluidPage(
  "wizardR demo",
  theme = bslib::bs_theme(version = 5L),
  # add button
  actionButton("show_wizard", "Show wizard"),
  wizard(
    modal = TRUE,
    id = "my_modal",
    # start sequence of steps
    wizard_step(
      step_title = "Hello tag",
      step_id = "step-helo",
      shiny::h5("hello, this is step 0.")
    ),
    wizard_step(
      step_title = "Numeric input",
      step_id = "step-input",
      shiny::numericInput("number", "Select a number", value = 30, min = 20, max = 100),
      shiny::selectInput("organism", "Select organism", choices = c("human", "mouse", "rat"))
    ),
    wizard_step(
      step_title = "Plot output from input",
      step_id = "step-output",
      plotOutput("plot")
    ),
    wizard_step(
      shiny::h5("No step title defined. This is the last step."),
      step_id = "step-last"
    )
  )
)

server <- function(input, output, session) {
  ah_task <- ExtendedTask$new(function(organism) {
    future_promise({
      # ah <- AnnotationHub::AnnotationHub()
      # ahDb <- AnnotationHub::query(ah, pattern = c(
      #   organism,
      #   "OrgDb"
      # ))
      # ahDb <- ahDb[which(tolower(ahDb$species) == tolower(organism))]
      # k <- length(ahDb)
      # orgdb <- ahDb[[k]]
      # orgdb

      Sys.sleep(7)
      print(organism)
      print("AnnotationHub queried")
    })
  })

  output$plot <- renderPlot({
    plot(1:input$number, rnorm(input$number))
  })

  output$text <- renderText({
    "hello world"
  })

  # show the wizard
  observeEvent(input$show_wizard, {
    wizard_show("my_modal")
  })

  observeEvent(input$my_modal, {
    print(input$my_modal)
  })

  observeEvent(input$my_modal, {
    req(input$my_modal == "step-input")
    print("Checking probetypes task started")

    ah_task$invoke(input$organism)
  })

  observeEvent(input$my_modal, {
    req(input$my_modal == "step-last")

    print("here we should use orgdb into ah")

    # use ah in detect_probetype
    # uniprot_genes <- c("P31749", "P04637", "Q9Y6K9", "O15111", "Q9UM73", "Q13315", "P55317", "P16070", "P22301")
    # playbase::detect_probetype(organism = input$organism, probes = uniprot_genes, ah=orgdb)
  })
}




shinyApp(ui, server)
