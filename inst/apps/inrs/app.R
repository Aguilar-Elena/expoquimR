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

ui <- fluidPage(
  titlePanel("Evaluaci\u00f3n del Riesgo por Inhalaci\u00f3n \u00b7 INRS"),
  sidebarLayout(
    sidebarPanel(
      textInput("nombre", "Producto qu\u00edmico"),

      radioButtons(
        "criterio_peligro", "Criterio para la clase de peligro:",
        choices = c("Frases H" = "H", "Frases R" = "R", "Material y proceso" = "PROC"),
        selected = "H", inline = TRUE
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'H'",
        textInput("frasesH", "Frases H (separadas por comas)", "")
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'R'",
        textInput("frasesR", "Frases R (separadas por comas)", "")
      ),
      conditionalPanel(
        condition = "input.criterio_peligro == 'PROC'",
        selectInput("proceso", "Material y proceso", choices = c("", sort(materiales_procesos)))
      ),
      numericInput("vla", "VLA (mg/m\u00b3)", value = NA, min = 0),

      hr(),
      numericInput("cantidad_valor", "Cantidad diaria manipulada:", value = NA, min = 0),
      selectInput("cantidad_unidad", "Unidad", choices = c("g", "ml", "kg", "l")),
      numericInput("frecuencia_valor", "Frecuencia de uso:", value = NA, min = 0),
      selectInput("frecuencia_unidad", "Unidad de frecuencia", choices = unidades_frecuencia),

      hr(),
      radioButtons("tipo_sustancia", "Tipo de sustancia:",
        choices = c("L\u00edquida" = "liquid", "S\u00f3lida" = "solid"), inline = TRUE),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'liquid'",
        radioButtons("metodo_liquido", "M\u00e9todo para la volatilidad:",
          choices = c(
            "Gr\u00e1fico (T\u00ba uso / punto ebullici\u00f3n)" = "graph",
            "Presi\u00f3n de vapor" = "pressure"
          )
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'graph'",
          numericInput("temperatura_uso",   "Temperatura de uso (\u00b0C):",    value = NA),
          numericInput("punto_ebullicion",  "Punto de ebullici\u00f3n (\u00b0C):", value = NA)
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'pressure'",
          numericInput("presion_vapor", "Presi\u00f3n de vapor (kPa):", value = NA)
        )
      ),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'solid'",
        selectInput("descripcion_solida", "Descripci\u00f3n del s\u00f3lido:", choices = descripciones_solido)
      ),

      hr(),
      selectInput("procedimiento", "Tipo de procedimiento:",        choices = procedimientos_validos),
      selectInput("proteccion",    "Protecci\u00f3n colectiva:", choices = protecciones_validas),

      actionButton("evaluar", "Evaluar producto", class = "btn-primary"),
      actionButton("reset",   "Reiniciar")
    ),

    mainPanel(
      h4("Resumen de resultados"),
      DT::dataTableOutput("tabla_resumen"),
      br(),
      tags$details(
        tags$summary(
          style = "cursor:pointer; font-weight:bold; font-size:1em; margin-bottom:6px;",
          "\u25b6 Ver puntuaciones intermedias (detalle del c\u00e1lculo)"
        ),
        DT::dataTableOutput("tabla_detalle")
      )
    )
  )
)

server <- function(input, output, session) {

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
      showNotification("Ya se han evaluado 10 productos.", type = "warning")
      return()
    }
    if (!nzchar(trimws(input$nombre))) {
      showNotification("Introduce un nombre para el producto.", type = "error")
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
    colnames(df) <- labels_resumen
    DT::datatable(
      df, rownames = FALSE,
      options = list(dom = "t", pageLength = 10, autoWidth = TRUE)
    )
  })

  # Tabla de DETALLE: puntuaciones intermedias, colapsada por defecto
  output$tabla_detalle <- DT::renderDataTable({
    df <- productos()[, cols_detalle, drop = FALSE]
    colnames(df) <- labels_detalle
    DT::datatable(
      df, rownames = FALSE,
      options = list(dom = "t", pageLength = 10, scrollX = TRUE)
    )
  })
}

shinyApp(ui, server)
