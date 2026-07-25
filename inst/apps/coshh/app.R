library(shiny)
library(expoquimR)

# La tabla interna del paquete (expoquimR:::coshh_risk_table) ahora solo
# almacena las claves en ingles ("Small"/"Medium"/"Large",
# "Low"/"Medium"/"High"); coshh_risk() acepta tambien las etiquetas en
# espanol (ver R/coshh.R), asi que la UI en espanol usa directamente esas
# etiquetas.
cantidades_validas <- c("Peque\u00f1a", "Mediana", "Grande")
volatilidades_validas <- c("Baja", "Media", "Alta")

ui <- fluidPage(
  titlePanel("COSHH Essentials \u2014 Evaluaci\u00f3n comparativa de sustancias"),
  sidebarLayout(
    sidebarPanel(
      textInput("nombre", "Nombre de la sustancia", placeholder = "Ej. Tolueno"),
      textInput("frases", "Frases H o R (separadas por comas)", placeholder = "Ej. H315, H336"),
      checkboxInput("liquido", "\u00bfEs l\u00edquida?", value = FALSE),
      conditionalPanel(
        condition = "input.liquido == true",
        numericInput("t_ebullicion", "Punto de ebullici\u00f3n (\u00b0C):", value = NA),
        numericInput("t_proceso", "Temperatura de proceso (\u00b0C):", value = NA)
      ),
      conditionalPanel(
        condition = "input.liquido == false",
        selectInput("pulverulencia", "Pulverulencia:", choices = volatilidades_validas)
      ),
      selectInput("cantidad", "Cantidad manipulada:", choices = cantidades_validas),
      actionButton("add", "A\u00f1adir sustancia", class = "btn-primary"),
      actionButton("reset", "Reiniciar"),
      helpText("M\u00e1ximo 10 sustancias por comparaci\u00f3n.")
    ),
    mainPanel(
      h4("Resultados comparativos"),
      DT::dataTableOutput("tabla_resultados")
    )
  )
)

server <- function(input, output, session) {
  resultados <- reactiveVal(data.frame(
    substance = character(), phrases = character(), grade = character(),
    volatility = character(), quantity = character(),
    risk = integer(), measures = character(),
    stringsAsFactors = FALSE
  ))

  observeEvent(input$add, {
    if (nrow(resultados()) >= 10) {
      showNotification("Se ha alcanzado el m\u00e1ximo de 10 sustancias.", type = "warning")
      return()
    }
    if (!nzchar(trimws(input$nombre))) {
      showNotification("Introduce un nombre para la sustancia.", type = "error")
      return()
    }

    nueva <- coshh_evaluate(
      name = input$nombre,
      phrases = input$frases,
      quantity = input$cantidad,
      is_liquid = input$liquido,
      boiling_point = input$t_ebullicion,
      process_temp = input$t_proceso,
      dustiness = input$pulverulencia
    )

    resultados(rbind(resultados(), nueva))
  })

  observeEvent(input$reset, {
    resultados(resultados()[0, ])
  })

  output$tabla_resultados <- DT::renderDataTable({
    DT::datatable(resultados(), rownames = FALSE, options = list(dom = "t"))
  })
}

shinyApp(ui, server)
