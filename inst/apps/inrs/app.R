library(shiny)
library(expoquimR)

`%||%` <- function(a, b) if (is.null(a)) b else a

procedimientos_validos <- expoquimR:::inrs_tabla_procedimiento$tipo
protecciones_validas   <- expoquimR:::inrs_tabla_proteccion$situacion
materiales_procesos    <- unique(unlist(strsplit(expoquimR:::inrs_tabla_1$materiales_procesos, ",\\s*")))

descripciones_solido <- c(
  "Polvo que genera mucha dispersion visible en el aire",
  "Polvo fino con poca dispersion visible",
  "Solido compacto sin polvo visible"
)

unidades_frecuencia <- c(
  "Minutos" = "minutos", "Horas" = "horas", "D\u00edas" = "dias",
  "Meses" = "meses", "No se usa" = "no_se_usa"
)

# Columnas que van en la tabla de RESUMEN (lo que el tecnico necesita de un vistazo)
cols_resumen <- c(
  "producto", "clase_peligro", "clase_exposicion_potencial",
  "clase_riesgo_potencial", "clase_volatilidad_pulverulencia",
  "clase_procedimiento", "clase_proteccion",
  "riesgo_inhalacion", "caracterizacion_riesgo"
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
  "producto",
  "clase_cantidad", "clase_frecuencia",
  "puntuacion_riesgo_potencial",
  "puntuacion_volatilidad_pulverulencia",
  "puntuacion_procedimiento", "puntuacion_proteccion",
  "fc_vla"
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
        choices = c("L\u00edquida" = "liquida", "S\u00f3lida" = "solida"), inline = TRUE),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'liquida'",
        radioButtons("metodo_liquido", "M\u00e9todo para la volatilidad:",
          choices = c(
            "Gr\u00e1fico (T\u00ba uso / punto ebullici\u00f3n)" = "grafico",
            "Presi\u00f3n de vapor" = "presion"
          )
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'grafico'",
          numericInput("temperatura_uso",   "Temperatura de uso (\u00b0C):",    value = NA),
          numericInput("punto_ebullicion",  "Punto de ebullici\u00f3n (\u00b0C):", value = NA)
        ),
        conditionalPanel(
          condition = "input.metodo_liquido == 'presion'",
          numericInput("presion_vapor", "Presi\u00f3n de vapor (kPa):", value = NA)
        )
      ),
      conditionalPanel(
        condition = "input.tipo_sustancia == 'solida'",
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
    producto = character(),
    clase_peligro = character(), clase_cantidad = character(),
    clase_frecuencia = character(), clase_exposicion_potencial = character(),
    clase_riesgo_potencial = character(), puntuacion_riesgo_potencial = numeric(),
    clase_volatilidad_pulverulencia = character(), puntuacion_volatilidad_pulverulencia = numeric(),
    clase_procedimiento = character(), puntuacion_procedimiento = numeric(),
    clase_proteccion = character(), puntuacion_proteccion = numeric(),
    fc_vla = numeric(), riesgo_inhalacion = numeric(), caracterizacion_riesgo = character(),
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

    frases_r <- if (input$criterio_peligro == "R")    strsplit(input$frasesR, ",")[[1]] else character(0)
    frases_h <- if (input$criterio_peligro == "H")    strsplit(input$frasesH, ",")[[1]] else character(0)
    proceso  <- if (input$criterio_peligro == "PROC") input$proceso               else NULL

    nuevo <- inrs_evaluar(
      nombre            = input$nombre,
      frases_r          = frases_r,
      frases_h          = frases_h,
      proceso           = proceso,
      vla               = input$vla,
      cantidad_valor    = input$cantidad_valor,
      cantidad_unidad   = input$cantidad_unidad,
      frecuencia_valor  = input$frecuencia_valor,
      frecuencia_unidad = input$frecuencia_unidad,
      tipo_sustancia    = input$tipo_sustancia,
      metodo_liquido    = input$metodo_liquido    %||% "grafico",
      temperatura_uso   = input$temperatura_uso,
      punto_ebullicion  = input$punto_ebullicion,
      presion_vapor     = input$presion_vapor,
      descripcion_solida = input$descripcion_solida %||% NA_character_,
      procedimiento     = input$procedimiento,
      proteccion        = input$proteccion
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
