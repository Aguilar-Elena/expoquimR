library(shiny)
library(expoquimR)

# The language belongs to each Shiny session, not the package-wide R state.
tr <- function(lang, es, en) if (identical(lang, "es")) es else en

app_ui <- function(lang, values = list()) {
  t <- function(es, en) tr(lang, es, en)
  v <- function(id, default) if (is.null(values[[id]])) default else values[[id]]
  fluidPage(
    titlePanel(t("COSHH Essentials — Evaluación comparativa de sustancias",
                 "COSHH Essentials — Comparative substance assessment")),
    sidebarLayout(
      sidebarPanel(
        textInput("nombre", t("Nombre de la sustancia", "Substance name"),
                  value = v("nombre", ""), placeholder = t("Ej. Tolueno", "e.g. Toluene")),
        textInput("frases", t("Frases H o R (separadas por comas)",
                              "H or R statements (comma-separated)"),
                  value = v("frases", ""), placeholder = "H315, H336"),
        checkboxInput("liquido", t("¿Es líquida?", "Is it a liquid?"),
                      value = isTRUE(v("liquido", FALSE))),
        conditionalPanel("input.liquido == true",
          numericInput("t_ebullicion", t("Punto de ebullición (°C)", "Boiling point (°C)"),
                       value = v("t_ebullicion", NA_real_)),
          numericInput("t_proceso", t("Temperatura de proceso (°C)", "Process temperature (°C)"),
                       value = v("t_proceso", NA_real_))
        ),
        conditionalPanel("input.liquido == false",
          selectInput("pulverulencia", t("Pulverulencia", "Dustiness"),
            choices = stats::setNames(c("Low", "Medium", "High"),
               if (lang == "es") c("Baja", "Media", "Alta") else c("Low", "Medium", "High")),
            selected = v("pulverulencia", "Low"))
        ),
        selectInput("cantidad", t("Cantidad manipulada", "Quantity handled"),
          choices = stats::setNames(c("Small", "Medium", "Large"),
            if (lang == "es") c("Pequeña", "Mediana", "Grande") else c("Small", "Medium", "Large")),
          selected = v("cantidad", "Small")),
        actionButton("add", t("Añadir sustancia", "Add substance"), class = "btn-primary"),
        actionButton("reset", t("Reiniciar", "Reset")),
        helpText(t("Máximo 10 sustancias por comparación.",
                   "Maximum of 10 substances per comparison."))
      ),
      mainPanel(h4(t("Resultados comparativos", "Comparative results")),
                DT::dataTableOutput("tabla_resultados"))
    )
  )
}

ui <- fluidPage(
  selectInput("app_lang", "Language / Idioma",
              choices = c("English" = "en", "Español" = "es"), selected = "en",
              width = "180px"),
  uiOutput("app_content")
)

server <- function(input, output, session) {
  lang <- reactive(input$app_lang %||% "en")
  `%||%` <- function(x, y) if (is.null(x)) y else x
  t <- function(es, en) tr(lang(), es, en)
  ids <- c("nombre", "frases", "liquido", "t_ebullicion", "t_proceso",
           "pulverulencia", "cantidad")
  output$app_content <- renderUI({
    lang()
    values <- isolate(setNames(lapply(ids, function(id) input[[id]]), ids))
    app_ui(lang(), values)
  })
  resultados <- reactiveVal(data.frame(
    substance = character(), phrases = character(), grade = character(),
    volatility = character(), quantity = character(), risk = integer(),
    measures = character(), stringsAsFactors = FALSE
  ))
  observeEvent(input$add, {
    if (nrow(resultados()) >= 10L) {
      showNotification(t("Se ha alcanzado el máximo de 10 sustancias.",
                         "The maximum of 10 substances has been reached."), type = "warning")
      return()
    }
    if (is.null(input$nombre) || !nzchar(trimws(input$nombre))) {
      showNotification(t("Introduce un nombre para la sustancia.",
                         "Enter a substance name."), type = "error")
      return()
    }
    nueva <- coshh_evaluate(
      name = input$nombre, phrases = input$frases,
      quantity = input$cantidad, is_liquid = input$liquido,
      boiling_point = input$t_ebullicion, process_temp = input$t_proceso,
      dustiness = input$pulverulencia
    )
    resultados(rbind(resultados(), nueva))
  })
  observeEvent(input$reset, resultados(resultados()[0, ]))
  output$tabla_resultados <- DT::renderDataTable({
    df <- resultados()
    # Only display strings are localized; calculations and stored data are unchanged.
    translate <- function(x, en, es) {
      if (lang() != "es") return(x)
      i <- match(x, en)
      x[!is.na(i)] <- es[i[!is.na(i)]]
      x
    }
    df$quantity <- translate(df$quantity,
      c("Small", "Medium", "Large"), c("Pequeña", "Mediana", "Grande"))
    df$volatility <- translate(df$volatility,
      c("Low", "Medium", "High"), c("Baja", "Media", "Alta"))
    # Localize control recommendations on display, not in stored results.
    df$measures <- expoquimR:::.localize_result_labels(
      df$measures, paste0("coshh_risk_", 1:4, "_measures"), lang())
    if (lang() == "es") {
      names(df) <- c("Sustancia", "Frases", "Grupo", "Volatilidad",
                     "Cantidad", "Riesgo", "Medidas")
    } else {
      names(df) <- c("Substance", "Statements", "Group", "Volatility",
                     "Quantity", "Risk", "Measures")
    }
    DT::datatable(df, rownames = FALSE, options = list(dom = "t"),
                  extensions = character(0))
  })
}
shinyApp(ui, server)
