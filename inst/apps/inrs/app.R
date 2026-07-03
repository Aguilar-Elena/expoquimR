library(shiny)
library(expoquimR)

# Pequeno helper local (equivalente a rlang::`%||%`) para no anadir una
# dependencia solo para esto.
`%||%` <- function(a, b) if (is.null(a)) b else a

# Opciones leidas de las tablas internas del paquete, para no desincronizarse
# nunca de lo que aceptan las funciones inrs_procedimiento()/inrs_proteccion().
procedimientos_validos <- expoquimR:::inrs_tabla_procedimiento$tipo
protecciones_validas <- expoquimR:::inrs_tabla_proteccion$situacion
materiales_procesos <- unique(unlist(strsplit(expoquimR:::inrs_tabla_1$materiales_procesos, ",\\s*")))

descripciones_solido <- c(
  "Polvo que genera mucha dispersion visible en el aire",
  "Polvo fino con poca dispersion visible",
  "Solido compacto sin polvo visible"
)

unidades_frecuencia <- c(
  "Minutos" = "minutos", "Horas" = "horas", "D\u00edas" = "dias",
  "Meses" = "meses", "No se usa" = "no_se_usa"
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
        radioButtons("metodo_liquido", "M\u00e9todo para determinar la volatilidad:",
          choices = c("Gr\u00e1fico (temperatura de uso y punto de ebullici\u00f3n)" = "grafico",
                      "Presi\u00f3n de vapor" = "presion")),
        conditionalPanel(
          condition = "input.metodo_liquido == 'grafico'",
          numericInput("temperatura_uso", "Temperatura de uso (\u00b0C):", value = NA),
          numericInput("punto_ebullicion", "Punto de ebullici\u00f3n (\u00b0C):", value = NA)
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
      selectInput("procedimiento", "Tipo de procedimiento:", choices = procedimientos_validos),
      selectInput("proteccion", "Sistema de protecci\u00f3n colectiva:", choices = protecciones_validas),

      actionButton("evaluar", "Evaluar producto", class = "btn-primary"),
      actionButton("reset", "Reiniciar")
    ),
    mainPanel(
      DT::dataTableOutput("tabla_resumen")
    )
  )
)

server <- function(input, output, session) {
  productos <- reactiveVal(data.frame(
    producto = character(), clase_peligro = character(), clase_cantidad = character(),
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

    frases_r <- if (input$criterio_peligro == "R") strsplit(input$frasesR, ",")[[1]] else character(0)
    frases_h <- if (input$criterio_peligro == "H") strsplit(input$frasesH, ",")[[1]] else character(0)
    proceso <- if (input$criterio_peligro == "PROC") input$proceso else NULL

    nuevo <- inrs_evaluar(
      nombre = input$nombre,
      frases_r = frases_r,
      frases_h = frases_h,
      proceso = proceso,
      vla = input$vla,
      cantidad_valor = input$cantidad_valor,
      cantidad_unidad = input$cantidad_unidad,
      frecuencia_valor = input$frecuencia_valor,
      frecuencia_unidad = input$frecuencia_unidad,
      tipo_sustancia = input$tipo_sustancia,
      metodo_liquido = input$metodo_liquido %||% "grafico",
      temperatura_uso = input$temperatura_uso,
      punto_ebullicion = input$punto_ebullicion,
      presion_vapor = input$presion_vapor,
      descripcion_solida = input$descripcion_solida %||% NA_character_,
      procedimiento = input$procedimiento,
      proteccion = input$proteccion
    )

    productos(rbind(productos(), nuevo))
  })

  observeEvent(input$reset, {
    productos(productos()[0, ])
  })

  output$tabla_resumen <- DT::renderDataTable({
    DT::datatable(productos(), rownames = FALSE, options = list(scrollX = TRUE, dom = "t"))
  })
}

shinyApp(ui, server)
