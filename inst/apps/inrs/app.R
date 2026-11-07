library(shiny)
library(expoquimR)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Las tablas internas del paquete (expoquimR:::inrs_process_table,
# expoquimR:::inrs_protection_table) ahora solo almacenan las claves en
# ingles que esperan inrs_process_type()/inrs_collective_protection(); la
# UI en espanol muestra la etiqueta en espanol pero envia el valor en
# ingles (igual patron que ya se usaba para unidades_frecuencia).
procedimientos_validos <- c(
  "Dispersivo" = "Dispersive",
  "Abierto" = "Open",
  "Cerrado/abierto regularmente" = "Closed/opened regularly",
  "Cerrado permanente" = "Permanently closed"
)
protecciones_validas <- c(
  "Espacio confinado sin ventilaci\u00f3n" = "Confined space without ventilation",
  "Sin ventilaci\u00f3n mec\u00e1nica" = "No mechanical ventilation",
  "Condiciones moderadas de dispersi\u00f3n" = "Moderate dispersion conditions",
  "Captaci\u00f3n localizada o cabinas ventiladas" = "Local exhaust or ventilated enclosures",
  "Captaci\u00f3n envolvente" = "Enclosing hood / full enclosure"
)
materiales_procesos <- unique(unlist(strsplit(expoquimR:::inrs_hazard_table$process_materials, ",\\s*")))

descripciones_solido <- c(
  "Polvo que genera mucha dispersi\u00f3n visible en el aire" = "Dust that generates a lot of visible dispersion in the air",
  "Polvo fino con poca dispersi\u00f3n visible" = "Fine dust with little visible dispersion",
  "S\u00f3lido compacto sin polvo visible" = "Compact solid with no visible dust"
)

unidades_frecuencia <- c(
  "Minutos" = "minutes", "Horas" = "hours", "D\u00edas" = "days",
  "Meses" = "months", "No se usa" = "not_used"
)

# Columnas que van en la tabla de RESUMEN (lo que el tecnico necesita de un vistazo)
cols_resumen <- c(
  "product", "hazard_class", "potential_exposure_class",
  "potential_risk_class", "volatility_dustiness_class",
  "procedure_class", "protection_class",
  "inhalation_risk", "risk_characterisation"
)

# Etiquetas legibles para la tabla de resumen
labels_resumen <- c(
  "Producto", "Cl. peligro", "Cl. exp. potencial",
  "Cl. riesgo potencial", "Volatilidad/Pulverul.",
  "Procedimiento", "Protecci\u00f3n colectiva",
  "Riesgo inhalaci\u00f3n", "Caracterizaci\u00f3n"
)

# Columnas que van en la tabla de DETALLE (pasos intermedios para auditar)
cols_detalle <- c(
  "product",
  "quantity_class", "frequency_class",
  "potential_risk_score",
  "volatility_dustiness_score",
  "procedure_score", "protection_score",
  "vla_correction_factor"
)

labels_detalle <- c(
  "Producto",
  "Cl. cantidad", "Cl. frecuencia",
  "Punt. riesgo pot.", "Punt. volatilidad",
  "Punt. procedimiento", "Punt. protecci\u00f3n",
  "FC (VLA)"
)

app_ui <- function(lang, values = list()) {
  t <- function(es, en) if (identical(lang, "es")) es else en
  v <- function(id, default) if (is.null(values[[id]])) default else values[[id]]
  fluidPage(
  titlePanel(t("Evaluaci\u00f3n del Riesgo por Inhalaci\u00f3n \u00b7 INRS", "INRS Inhalation Risk Assessment")),
  sidebarLayout(
    sidebarPanel(
      textInput("nombre", t("Producto qu\u00edmico", "Chemical product"), value = v("nombre", "")),

      radioButtons(
        "criterio_peligro", t("Criterio para la clase de peligro:", "Hazard class criterion:"),
        choices = stats::setNames(c("H", "R", "PROC"), c(t("Frases H", "H statements"), t("Frases R", "R statements"), t("Material y proceso", "Material and process"))),
        selected = v("criterio_peligro", "H"), inline = TRUE
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'H'",
        textInput("frasesH", t("Frases H (separadas por comas)", "H statements (comma-separated)"), value = v("frasesH", ""))
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'R'",
        textInput("frasesR", t("Frases R (separadas por comas)", "R statements (comma-separated)"), value = v("frasesR", ""))
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'PROC'",
        selectInput("proceso", t("Material y proceso", "Material and process"), choices = c("", sort(materiales_procesos)), selected = v("proceso", ""))
      ),
      numericInput("vla", t("VLA (mg/m\u00b3)", "OEL (mg/m³)"), value = v("vla", NA), min = 0),

      hr(),
      numericInput("cantidad_valor", t("Cantidad diaria manipulada:", "Daily quantity handled:"), value = v("cantidad_valor", NA), min = 0),
      selectInput("cantidad_unidad", t("Unidad", "Unit"), choices = c("g", "ml", "kg", "l"), selected = v("cantidad_unidad", "g")),
      numericInput("frecuencia_valor", t("Frecuencia de uso:", "Frequency of use:"), value = v("frecuencia_valor", NA), min = 0),
      selectInput("frecuencia_unidad", t("Unidad de frecuencia", "Frequency unit"), choices = if (lang == "es") unidades_frecuencia else stats::setNames(unname(unidades_frecuencia), c("Minutes", "Hours", "Days", "Months", "Not used")), selected = v("frecuencia_unidad", "minutes")),

      hr(),
      radioButtons("tipo_sustancia", t("Tipo de sustancia:", "Substance type:"),
        choices = stats::setNames(c("liquid", "solid"), c(t("L\u00edquida", "Liquid"), t("S\u00f3lida", "Solid"))), selected = v("tipo_sustancia", "liquid"), inline = TRUE),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'liquid'",
        radioButtons("metodo_liquido", t("M\u00e9todo para la volatilidad:", "Volatility method:"),
          choices = stats::setNames(c("graph", "pressure"), c(
            t("Gr\u00e1fico (T\u00ba uso / punto ebullici\u00f3n)", "Graph (use / boiling temperature)"),
            t("Presi\u00f3n de vapor", "Vapour pressure"))), selected = v("metodo_liquido", "graph")
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'graph'",
          numericInput("temperatura_uso",   t("Temperatura de uso (\u00b0C):", "Use temperature (°C):"),    value = v("temperatura_uso", NA)),
          numericInput("punto_ebullicion",  t("Punto de ebullici\u00f3n (\u00b0C):", "Boiling point (°C):"), value = v("punto_ebullicion", NA))
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'pressure'",
          numericInput("presion_vapor", t("Presi\u00f3n de vapor (kPa):", "Vapour pressure (kPa):"), value = v("presion_vapor", NA))
        )
      ),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'solid'",
        selectInput("descripcion_solida", t("Descripci\u00f3n del s\u00f3lido:", "Solid description:"), choices = if (lang == "es") descripciones_solido else stats::setNames(unname(descripciones_solido), c("Dust that generates a lot of visible dispersion in the air", "Fine dust with little visible dispersion", "Compact solid with no visible dust")), selected = v("descripcion_solida", "Dust that generates a lot of visible dispersion in the air"))
      ),

      hr(),
      selectInput("procedimiento", t("Tipo de procedimiento:", "Process type:"),        choices = if (lang == "es") procedimientos_validos else stats::setNames(unname(procedimientos_validos), c("Dispersive", "Open", "Closed/opened regularly", "Permanently closed")), selected = v("procedimiento", "Dispersive")),
      selectInput("proteccion",    t("Protecci\u00f3n colectiva:", "Collective protection:"), choices = if (lang == "es") protecciones_validas else stats::setNames(unname(protecciones_validas), c("Confined space without ventilation", "No mechanical ventilation", "Moderate dispersion conditions", "Local exhaust or ventilated enclosures", "Enclosing hood / full enclosure")), selected = v("proteccion", "Confined space without ventilation")),

      actionButton("evaluar", t("Evaluar producto", "Assess product"), class = "btn-primary"),
      actionButton("reset",   t("Reiniciar", "Reset"))
    ),

    mainPanel(
      h4(t("Resumen de resultados", "Results summary")),
      DT::dataTableOutput("tabla_resumen"),
      br(),
      tags$details(
        tags$summary(
          style = "cursor:pointer; font-weight:bold; font-size:1em; margin-bottom:6px;",
          t("\u25b6 Ver puntuaciones intermedias (detalle del c\u00e1lculo)", "▶ View intermediate scores (calculation details)")
        ),
        DT::dataTableOutput("tabla_detalle")
      )
    )
  )
)
}

ui <- fluidPage(
  selectInput("app_lang", "Language / Idioma",
    choices = c("English" = "en", "Español" = "es"), selected = "en", width = "180px"),
  uiOutput("app_content")
)

server <- function(input, output, session) {
  lang <- reactive(input$app_lang %||% "en")
  ids <- c("nombre", "frasesH", "frasesR", "vla", "cantidad_valor",
           "cantidad_unidad", "frecuencia_valor", "frecuencia_unidad",
           "tipo_sustancia", "metodo_liquido", "temperatura_uso",
           "punto_ebullicion", "presion_vapor", "descripcion_solida",
           "procedimiento", "proteccion", "criterio_peligro", "proceso")
  output$app_content <- renderUI({
    current <- lang()
    values <- isolate(setNames(lapply(ids, function(id) input[[id]]), ids))
    app_ui(current, values)
  })

  productos <- reactiveVal(data.frame(
    product = character(),
    hazard_class = character(), quantity_class = character(),
    frequency_class = character(), potential_exposure_class = character(),
    potential_risk_class = character(), potential_risk_score = numeric(),
    volatility_dustiness_class = character(), volatility_dustiness_score = numeric(),
    procedure_class = character(), procedure_score = numeric(),
    protection_class = character(), protection_score = numeric(),
    vla_correction_factor = numeric(), inhalation_risk = numeric(), risk_characterisation = character(),
    stringsAsFactors = FALSE
  ))

  observeEvent(input$evaluar, {
    if (nrow(productos()) >= 10) {
      showNotification(if (lang() == "es") "Ya se han evaluado 10 productos." else "A maximum of 10 products can be assessed.", type = "warning")
      return()
    }
    if (!nzchar(trimws(input$nombre))) {
      showNotification(if (lang() == "es") "Introduce un nombre para el producto." else "Enter a product name.", type = "error")
      return()
    }

    r_phrases <- if (input$criterio_peligro == "R")    strsplit(input$frasesR, ",")[[1]] else character(0)
    h_phrases <- if (input$criterio_peligro == "H")    strsplit(input$frasesH, ",")[[1]] else character(0)
    process   <- if (input$criterio_peligro == "PROC") input$proceso                else NULL

    nuevo <- inrs_evaluate(
      name               = input$nombre,
      r_phrases          = r_phrases,
      h_phrases          = h_phrases,
      process            = process,
      vla                = input$vla,
      quantity_value     = input$cantidad_valor,
      quantity_unit      = input$cantidad_unidad,
      frequency_value    = input$frecuencia_valor,
      frequency_unit     = input$frecuencia_unidad,
      substance_type     = input$tipo_sustancia,
      liquid_method      = input$metodo_liquido    %||% "graph",
      use_temperature    = input$temperatura_uso,
      boiling_point      = input$punto_ebullicion,
      vapour_pressure    = input$presion_vapor,
      solid_description  = input$descripcion_solida %||% NA_character_,
      procedure          = input$procedimiento,
      protection         = input$proteccion
    )

    productos(rbind(productos(), nuevo))
  })

  observeEvent(input$reset, {
    productos(productos()[0, ])
  })

  # Tabla de RESUMEN: columnas clave, con etiquetas legibles
  output$tabla_resumen <- DT::renderDataTable({
    df <- productos()[, cols_resumen, drop = FALSE]
    # Translate characterisation without modifying stored evaluations.
    df$risk_characterisation <- expoquimR:::.localize_result_labels(
      df$risk_characterisation, paste0("inrs_char_", 1:3), lang())
    colnames(df) <- if (lang() == "es") labels_resumen else c(
      "Product", "Hazard class", "Potential exposure class", "Potential risk class",
      "Volatility/dustiness", "Process", "Collective protection",
      "Inhalation risk", "Risk characterisation")
    DT::datatable(
      df, rownames = FALSE,
      options = list(dom = "t", pageLength = 10, autoWidth = TRUE)
    )
  })

  # Tabla de DETALLE: puntuaciones intermedias, colapsada por defecto
  output$tabla_detalle <- DT::renderDataTable({
    df <- productos()[, cols_detalle, drop = FALSE]
    colnames(df) <- if (lang() == "es") labels_detalle else c(
      "Product", "Quantity class", "Frequency class", "Potential risk score",
      "Volatility score", "Process score", "Protection score", "OEL factor")
    DT::datatable(
      df, rownames = FALSE,
      options = list(dom = "t", pageLength = 10, scrollX = TRUE)
    )
  })
}

shinyApp(ui, server)
