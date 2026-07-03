library(shiny)
library(expoquimR)
library(ggplot2)

MAX_JORNADAS <- 15L
MUESTRAS_POR_JORNADA <- 3L

ui <- navbarPage(
  "UNE-EN 689: Evaluaci\u00f3n de la exposici\u00f3n",

  tabPanel(
    "1. Datos y evaluaci\u00f3n preliminar",
    sidebarLayout(
      sidebarPanel(
        numericInput("vla", "VLA (mg/m\u00b3)", value = NA, min = 0),
        helpText("Introduce al menos 3 jornadas (m\u00ednimo exigido por la evaluaci\u00f3n preliminar).",
                 "Para la evaluaci\u00f3n estad\u00edstica de la pesta\u00f1a 2 se necesitan al menos 6."),
        actionButton("add_jornada", "A\u00f1adir jornada"),
        actionButton("quitar_jornada", "Quitar \u00faltima jornada"),
        hr(),
        uiOutput("jornadas_ui"),
        actionButton("evaluar_preliminar", "Evaluar (preliminar)", class = "btn-primary")
      ),
      mainPanel(
        h4("ED e IE por jornada"),
        DT::dataTableOutput("tabla_preliminar"),
        h4("Resultado"),
        verbatimTextOutput("resultado_preliminar")
      )
    )
  ),

  tabPanel(
    "2. Evaluaci\u00f3n estad\u00edstica",
    sidebarLayout(
      sidebarPanel(
        helpText("Usa las mismas jornadas introducidas en la pesta\u00f1a 1 (m\u00ednimo 6 con datos v\u00e1lidos)."),
        actionButton("evaluar_estadistica", "Realizar evaluaci\u00f3n estad\u00edstica", class = "btn-primary")
      ),
      mainPanel(
        verbatimTextOutput("resumen_estadistica"),
        plotOutput("grafico_densidad")
      )
    )
  ),

  tabPanel(
    "3. Evaluaci\u00f3n peri\u00f3dica",
    sidebarLayout(
      sidebarPanel(
        radioButtons("opcion_periodicidad", "Criterio:",
          choices = c(
            "Opci\u00f3n 1: MG o MA frente al VLA" = "opc1",
            "Opci\u00f3n 2: LSC\u2089\u2085,\u2087\u2080 frente al VLA" = "opc2"
          ),
          selected = "opc1"
        ),
        actionButton("calcular_periodicidad", "Calcular periodicidad", class = "btn-primary"),
        helpText("Necesita haber ejecutado antes la evaluaci\u00f3n estad\u00edstica (pesta\u00f1a 2).")
      ),
      mainPanel(
        verbatimTextOutput("resultado_periodicidad")
      )
    )
  )
)

server <- function(input, output, session) {
  n_jornadas <- reactiveVal(3L)
  resultado_preliminar_val <- reactiveVal(NULL)
  resultado_estadistica_val <- reactiveVal(NULL)

  observeEvent(input$add_jornada, {
    if (n_jornadas() < MAX_JORNADAS) n_jornadas(n_jornadas() + 1L)
  })
  observeEvent(input$quitar_jornada, {
    if (n_jornadas() > 1L) n_jornadas(n_jornadas() - 1L)
  })

  output$jornadas_ui <- renderUI({
    lapply(seq_len(n_jornadas()), function(j) {
      tagList(
        h5(paste("Jornada", j)),
        lapply(seq_len(MUESTRAS_POR_JORNADA), function(k) {
          fluidRow(
            column(6, numericInput(paste0("j", j, "_v", k), paste("Muestra", k, "[mg/m\u00b3]"), value = NA)),
            column(6, numericInput(paste0("j", j, "_t", k), "Tiempo (h)", value = NA))
          )
        })
      )
    })
  })

  # Recoge todas las (jornada, concentracion, tiempo) validas introducidas
  # en la UI dinamica anterior, en formato largo, listas para
  # une689_evaluar_preliminar() / une689_ed_jornada().
  datos_jornadas <- function() {
    filas <- lapply(seq_len(n_jornadas()), function(j) {
      conc <- vapply(seq_len(MUESTRAS_POR_JORNADA), function(k) {
        val <- input[[paste0("j", j, "_v", k)]]
        if (is.null(val)) NA_real_ else val
      }, numeric(1))
      tiem <- vapply(seq_len(MUESTRAS_POR_JORNADA), function(k) {
        val <- input[[paste0("j", j, "_t", k)]]
        if (is.null(val)) NA_real_ else val
      }, numeric(1))
      data.frame(jornada = j, concentracion = conc, tiempo = tiem)
    })
    datos <- do.call(rbind, filas)
    datos[!is.na(datos$concentracion) & !is.na(datos$tiempo), ]
  }

  observeEvent(input$evaluar_preliminar, {
    if (!une689_validar_min_jornadas(n_jornadas(), minimo = 3L)) {
      showNotification("Se necesitan al menos 3 jornadas.", type = "error")
      return()
    }
    if (is.na(input$vla) || input$vla <= 0) {
      showNotification("Introduce un VLA v\u00e1lido (> 0).", type = "error")
      return()
    }

    datos <- datos_jornadas()
    if (nrow(datos) == 0) {
      showNotification("No hay datos v\u00e1lidos en ninguna jornada.", type = "error")
      return()
    }

    resultado_preliminar_val(une689_evaluar_preliminar(datos, vla = input$vla))
  })

  output$tabla_preliminar <- DT::renderDataTable({
    req(resultado_preliminar_val())
    DT::datatable(resultado_preliminar_val()$tabla_jornadas, rownames = FALSE, options = list(dom = "t"))
  })

  output$resultado_preliminar <- renderPrint({
    req(resultado_preliminar_val())
    resultado <- resultado_preliminar_val()$resultado
    if (is.na(resultado)) {
      cat("Sin datos suficientes para clasificar la conformidad.\n")
    } else {
      cat("Resultado global:", resultado, "\n")
    }
  })

  observeEvent(input$evaluar_estadistica, {
    datos <- datos_jornadas()
    jornadas_ids <- sort(unique(datos$jornada))
    eds <- vapply(jornadas_ids, function(j) {
      sub <- datos[datos$jornada == j, ]
      une689_ed_jornada(sub$concentracion, sub$tiempo)
    }, numeric(1))
    eds <- eds[!is.na(eds) & eds > 0]

    if (!une689_validar_min_jornadas(length(eds), minimo = 6L)) {
      showNotification(
        paste0("Se necesitan al menos 6 jornadas con datos v\u00e1lidos (hay ", length(eds), ")."),
        type = "error"
      )
      return()
    }
    if (is.na(input$vla) || input$vla <= 0) {
      showNotification("Introduce un VLA v\u00e1lido (> 0) en la pesta\u00f1a 1.", type = "error")
      return()
    }

    resultado_estadistica_val(une689_evaluar_estadistica(eds, vla = input$vla))
  })

  output$resumen_estadistica <- renderPrint({
    req(resultado_estadistica_val())
    res <- resultado_estadistica_val()

    cat("N\u00ba de jornadas:", res$n, "\n")
    cat("Distribuci\u00f3n inferida:", res$tipo, "\n\n")

    if (res$tipo == "Lognormal") {
      cat("MG =", round(res$MG, 4), "\n")
      cat("DSG =", round(res$DSG, 4), "\n")
      cat("W (Shapiro-Wilk, log(ED)) =", round(res$W_lognormal, 3), "\n")
      cat("p-valor =", round(res$pval_lognormal, 4), "\n")
    } else if (res$tipo == "Normal") {
      cat("MA =", round(res$MA, 4), "\n")
      cat("DS =", round(res$DS, 4), "\n")
      cat("W (Shapiro-Wilk, ED) =", round(res$W_normal, 3), "\n")
      cat("p-valor =", round(res$pval_normal, 4), "\n")
    } else {
      cat("Ni el ajuste normal ni el lognormal son adecuados (p <= 0.05 en ambos).\n")
      cat("Consulta un m\u00e9todo estad\u00edstico no parametrico; esta app no lo cubre.\n")
    }

    cat("\nUT de referencia:", round(res$ut, 3), "\n")
    if (!is.na(res$lsc)) cat("LSC\u2089\u2085,\u2087\u2080 =", round(res$lsc, 4), "\n")
    if (!is.na(res$ur)) cat("UR =", round(res$ur, 3), "\n")
    cat("\nResultado:", if (is.na(res$conformidad)) "No determinado" else res$conformidad, "\n")
  })

  output$grafico_densidad <- renderPlot({
    req(resultado_estadistica_val())
    res <- resultado_estadistica_val()
    if (res$tipo == "Ninguna") return(NULL)

    datos <- datos_jornadas()
    jornadas_ids <- sort(unique(datos$jornada))
    eds <- vapply(jornadas_ids, function(j) {
      sub <- datos[datos$jornada == j, ]
      une689_ed_jornada(sub$concentracion, sub$tiempo)
    }, numeric(1))
    eds <- eds[!is.na(eds) & eds > 0]

    df <- data.frame(ED = eds)
    centro <- if (res$tipo == "Lognormal") res$MG else res$MA

    ggplot(df, aes(x = ED)) +
      geom_density(color = "orange", fill = "orange", alpha = 0.3) +
      geom_vline(xintercept = centro, color = "green4", linetype = "dashed") +
      geom_vline(xintercept = input$vla, color = "red", linetype = "dashed") +
      geom_vline(xintercept = res$lsc, color = "darkred", linetype = "dotted") +
      annotate("text", x = centro, y = 0, label = paste0(if (res$tipo == "Lognormal") "MG: " else "MA: ", round(centro, 3)),
               color = "green4", vjust = -1) +
      annotate("text", x = input$vla, y = 0, label = paste0("VLA: ", round(input$vla, 3)),
               color = "red", vjust = -1) +
      annotate("text", x = res$lsc, y = 0, label = paste0("LSC\u2089\u2085,\u2087\u2080: ", round(res$lsc, 3)),
               color = "darkred", vjust = -1) +
      labs(title = "Distribuci\u00f3n de la exposici\u00f3n diaria (ED)", x = "ED (mg/m\u00b3)", y = "Densidad") +
      theme_minimal()
  })

  observeEvent(input$calcular_periodicidad, {
    res <- resultado_estadistica_val()
    if (is.null(res)) {
      showNotification("Realiza antes la evaluaci\u00f3n estad\u00edstica (pesta\u00f1a 2).", type = "error")
      return()
    }

    texto <- if (input$opcion_periodicidad == "opc1") {
      valor <- if (!is.na(res$MG)) res$MG else res$MA
      une689_periodicidad_opcion1(valor, vla = input$vla)
    } else {
      une689_periodicidad_opcion2(res$lsc, vla = input$vla)
    }

    output$resultado_periodicidad <- renderPrint({
      if (is.na(texto)) {
        cat("No se pudo calcular la periodicidad con los datos disponibles.\n")
      } else {
        cat(texto, "\n")
      }
    })
  })
}

shinyApp(ui, server)
