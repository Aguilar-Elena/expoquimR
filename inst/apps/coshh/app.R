library(shiny)
library(expoquimR)

# Los valores validos de cantidad y volatilidad se leen directamente de la
# tabla interna del paquete (expoquimR:::coshh_tabla_riesgo), para que la UI
# nunca se desincronice de lo que aceptan las funciones de calculo.
cantidades_validas <- unique(expoquimR:::coshh_tabla_riesgo$cantidad)
cantidades_validas <- cantidades_validas[cantidades_validas != "Cualquiera"]
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
    sustancia = character(), frases = character(), grado = character(),
    volatilidad = character(), cantidad = character(),
    riesgo = integer(), medidas = character(),
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
      nombre = input$nombre,
      frases = input$frases,
      cantidad = input$cantidad,
      es_liquido = input$liquido,
      t_ebullicion = input$t_ebullicion,
      t_proceso = input$t_proceso,
      pulverulencia = input$pulverulencia
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
