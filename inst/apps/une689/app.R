library(shiny)
library(shinyjs)
library(expoquimR)
library(ggplot2)

MAX_AGENTES          <- 6L
MAX_JORNADAS_PRE     <- 10L   # maximo por bloque (preliminar o adicional)
MUESTRAS_POR_JORNADA <- 3L

`%||%` <- function(a, b) if (is.null(a)) b else a

# ---------- helpers ----------------------------------------------------------

# Genera un bloque de jornadas fijas (todas en DOM, show/hide con shinyjs)
# prefijo distingue si son preliminares ("pre") o adicionales ("add")
bloque_jornadas <- function(ag, prefijo, max_j) {
  lapply(seq_len(max_j), function(j) {
    div(
      id = paste0(prefijo, "_ag", ag, "_j", j),
      h6(paste("Jornada", j)),
      lapply(seq_len(MUESTRAS_POR_JORNADA), function(k) {
        fluidRow(
          column(6, numericInput(
            paste0(prefijo, "_ag", ag, "_j", j, "_v", k),
            paste("Muestra", k, "[mg/m\u00b3]"), value = NA
          )),
          column(6, numericInput(
            paste0(prefijo, "_ag", ag, "_j", j, "_t", k),
            "Tiempo (h)", value = NA
          ))
        )
      })
    )
  })
}

# Recoge muestras de un bloque en formato largo
recoger_muestras_bloque <- function(input, ag, prefijo, n_j, offset = 0L) {
  filas <- lapply(seq_len(n_j), function(j) {
    conc <- vapply(seq_len(MUESTRAS_POR_JORNADA), function(k)
      input[[paste0(prefijo, "_ag", ag, "_j", j, "_v", k)]] %||% NA_real_,
      numeric(1))
    tiem <- vapply(seq_len(MUESTRAS_POR_JORNADA), function(k)
      input[[paste0(prefijo, "_ag", ag, "_j", j, "_t", k)]] %||% NA_real_,
      numeric(1))
    data.frame(jornada = j + offset,
               concentracion = conc, tiempo = tiem)
  })
  datos <- do.call(rbind, filas)
  datos[!is.na(datos$concentracion) & !is.na(datos$tiempo), ]
}

# ---------- UI ---------------------------------------------------------------

ui <- fluidPage(
  useShinyjs(),
  titlePanel("UNE-EN 689: Evaluaci\u00f3n de la exposici\u00f3n"),

  tags$head(tags$style(HTML("
    .nav-tabs > li.active > a { font-weight:bold; }
    .bloque-pre  { background:#f8f9fa; border:1px solid #dee2e6;
                   border-radius:6px; padding:10px; margin-bottom:10px; }
    .bloque-add  { background:#e8f4f8; border:1px solid #17a2b8;
                   border-radius:6px; padding:10px; margin-bottom:10px; }
    .aditivo-box { background:#fff3cd; border:1px solid #ffc107;
                   border-radius:6px; padding:12px; margin-top:16px; }
    .alert { margin-top:8px; }
  "))),

  tabsetPanel(
    id = "pestanas_principales",

    # ===== PESTANA 1 =========================================================
    tabPanel("1. Evaluaci\u00f3n preliminar",
      fluidRow(
        # sidebar izquierdo
        column(3,
          br(),
          actionButton("nuevo_agente", "\u002b A\u00f1adir agente",
                       class = "btn-success btn-sm", width = "100%"),
          br(), br(),
          uiOutput("sidebar_agente"),
          hr(),
          uiOutput("sidebar_aditivo")
        ),
        # panel principal
        column(9,
          uiOutput("pestanas_agentes"),
          br(),
          uiOutput("bloque_aditivo")
        )
      )
    ),

    # ===== PESTANA 2 =========================================================
    tabPanel("2. Evaluaci\u00f3n estad\u00edstica",
      sidebarLayout(
        sidebarPanel(
          uiOutput("selector_agente_est"),
          helpText("Usa las jornadas preliminares + adicionales de la pesta\u00f1a 1.",
                   "M\u00ednimo 6 v\u00e1lidas en total."),
          actionButton("evaluar_estadistica", "Realizar evaluaci\u00f3n",
                       class = "btn-primary")
        ),
        mainPanel(
          verbatimTextOutput("resumen_estadistica"),
          plotOutput("grafico_densidad")
        )
      )
    ),

    # ===== PESTANA 3 =========================================================
    tabPanel("3. Evaluaci\u00f3n peri\u00f3dica",
      sidebarLayout(
        sidebarPanel(
          uiOutput("selector_agente_per"),
          radioButtons("opcion_periodicidad", "Criterio:",
            choices = c(
              "Opci\u00f3n 1: MG o MA frente al VLA" = "opc1",
              "Opci\u00f3n 2: LSC\u2089\u2085,\u2087\u2080 frente al VLA" = "opc2"
            ), selected = "opc1"
          ),
          actionButton("calcular_periodicidad", "Calcular periodicidad",
                       class = "btn-primary"),
          helpText("Necesita haber ejecutado la evaluaci\u00f3n estad\u00edstica.")
        ),
        mainPanel(verbatimTextOutput("resultado_periodicidad"))
      )
    )
  )
)

# ---------- SERVER -----------------------------------------------------------

server <- function(input, output, session) {

  # ---- estado global --------------------------------------------------------
  n_agentes     <- reactiveVal(1L)
  agente_activo <- reactiveVal(1L)

  # jornadas visibles por agente y bloque
  n_pre <- reactiveVal(setNames(list(3L), "1"))  # preliminares
  n_add <- reactiveVal(setNames(list(0L), "1"))  # adicionales (0 = bloqueadas)

  # resultados
  res_preliminar  <- reactiveVal(list())
  res_estadistica <- reactiveVal(list())

  # grupos aditivos: lista de vectores de ids de agente
  grupos_aditivos <- reactiveVal(list())
  n_grupos        <- reactiveVal(0L)

  pestanas_creadas <- reactiveVal(0L)

  # ---- nuevo agente ---------------------------------------------------------
  observeEvent(input$nuevo_agente, {
    if (n_agentes() >= MAX_AGENTES) {
      showNotification(paste("M\u00e1ximo", MAX_AGENTES, "agentes."), type = "warning")
      return()
    }
    nuevo_id <- n_agentes() + 1L
    n_agentes(nuevo_id)

    np <- n_pre(); np[[as.character(nuevo_id)]] <- 3L; n_pre(np)
    na <- n_add(); na[[as.character(nuevo_id)]] <- 0L; n_add(na)

    agente_activo(nuevo_id)
    updateTabsetPanel(session, "tabs_agentes",
                      selected = paste0("agente_", nuevo_id))
  })

  observeEvent(input$tabs_agentes, {
    ag <- suppressWarnings(as.integer(gsub("agente_", "", input$tabs_agentes)))
    if (!is.na(ag)) agente_activo(ag)
  })

  # ---- sidebar agente activo ------------------------------------------------
  output$sidebar_agente <- renderUI({
    ag  <- agente_activo()
    key <- as.character(ag)
    np  <- n_pre()[[key]] %||% 3L
    na  <- n_add()[[key]] %||% 0L

    tagList(
      textInput(paste0("nombre_ag", ag),
                paste("Nombre agente", ag),
                value = isolate(input[[paste0("nombre_ag", ag)]]) %||%
                        paste("Agente", ag)),
      numericInput(paste0("vla_ag", ag), "VLA (mg/m\u00b3)",
                   value = isolate(input[[paste0("vla_ag", ag)]]) %||% NA_real_,
                   min = 0),
      hr(),
      strong("Jornadas preliminares: ", np),
      br(),
      actionButton("add_pre",    "\u002b Preliminar",
                   class = "btn-default btn-sm"),
      actionButton("quitar_pre", "\u2212 Preliminar",
                   class = "btn-default btn-sm"),
      br(), br(),
      actionButton(paste0("evaluar_pre_ag", ag),
                   paste("Evaluar preliminar \u2014 Agente", ag),
                   class = "btn-primary btn-sm", width = "100%"),

      # Jornadas adicionales: solo si n_add > 0
      if (na > 0) tagList(
        hr(),
        strong("Jornadas adicionales: ", na),
        br(),
        actionButton("add_add",    "\u002b Adicional",
                     class = "btn-info btn-sm"),
        actionButton("quitar_add", "\u2212 Adicional",
                     class = "btn-info btn-sm")
      )
    )
  })

  # add/quitar jornadas preliminares
  observeEvent(input$add_pre, {
    ag  <- agente_activo(); key <- as.character(ag)
    np  <- n_pre(); actual <- np[[key]] %||% 3L
    if (actual >= MAX_JORNADAS_PRE) return()
    np[[key]] <- actual + 1L; n_pre(np)
    shinyjs::show(paste0("pre_ag", ag, "_j", actual + 1L))
  })
  observeEvent(input$quitar_pre, {
    ag  <- agente_activo(); key <- as.character(ag)
    np  <- n_pre(); actual <- np[[key]] %||% 3L
    if (actual <= 1L) return()
    shinyjs::hide(paste0("pre_ag", ag, "_j", actual))
    np[[key]] <- actual - 1L; n_pre(np)
  })

  # add/quitar jornadas adicionales
  observeEvent(input$add_add, {
    ag  <- agente_activo(); key <- as.character(ag)
    na  <- n_add(); actual <- na[[key]] %||% 0L
    if (actual >= MAX_JORNADAS_PRE) return()
    na[[key]] <- actual + 1L; n_add(na)
    shinyjs::show(paste0("add_ag", ag, "_j", actual + 1L))
  })
  observeEvent(input$quitar_add, {
    ag  <- agente_activo(); key <- as.character(ag)
    na  <- n_add(); actual <- na[[key]] %||% 0L
    if (actual <= 0L) return()
    shinyjs::hide(paste0("add_ag", ag, "_j", actual))
    na[[key]] <- actual - 1L; n_add(na)
  })

  # ---- evaluacion preliminar por agente (boton dinamico) --------------------
  lapply(seq_len(MAX_AGENTES), function(ag) {
    observeEvent(input[[paste0("evaluar_pre_ag", ag)]], {
      nombre <- input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag)
      vla    <- input[[paste0("vla_ag", ag)]]
      np     <- n_pre()[[as.character(ag)]] %||% 3L

      if (is.null(vla) || is.na(vla) || vla <= 0) {
        showNotification(paste("VLA inv\u00e1lido para", nombre), type = "warning")
        return()
      }
      if (!une689_validate_min_days(np, minimo = 3L)) {
        showNotification(paste(nombre, ": m\u00ednimo 3 jornadas preliminares."),
                         type = "warning")
        return()
      }

      datos <- recoger_muestras_bloque(input, ag, "pre", np, offset = 0L)
      if (nrow(datos) == 0) {
        showNotification(paste("Sin datos v\u00e1lidos para", nombre), type = "error")
        return()
      }

      res <- une689_evaluate_preliminary(datos, vla = vla)

      # Si NO DECISION -> desbloquear jornadas adicionales
      na <- n_add()
      if (!is.na(res$resultado) && res$resultado == "NO DECISION") {
        if ((na[[as.character(ag)]] %||% 0L) == 0L) {
          na[[as.character(ag)]] <- 3L
          n_add(na)
          # 1. mostrar el div contenedor del bloque adicional
          shinyjs::show(paste0("div_add_ag", ag))
          # 2. mostrar explicitamente las 3 primeras filas adicionales
          for (j in 1:3) shinyjs::show(paste0("add_ag", ag, "_j", j))
          # 3. ocultar las demas por si acaso
          for (j in 4:MAX_JORNADAS_PRE) shinyjs::hide(paste0("add_ag", ag, "_j", j))
          showNotification(
            paste0(nombre, ": NO DECISI\u00d3N. Se han desbloqueado las jornadas
                   adicionales para completar la evaluaci\u00f3n estad\u00edstica."),
            type = "message", duration = 6
          )
        }
      }

      rp <- res_preliminar()
      rp[[as.character(ag)]] <- list(
        nombre    = nombre, vla = vla,
        tabla     = res$tabla_jornadas,
        resultado = res$resultado
      )
      res_preliminar(rp)
    }, ignoreNULL = TRUE)
  })

  # ---- pestanas dinamicas ---------------------------------------------------
  output$pestanas_agentes <- renderUI({
    nag <- n_agentes()
    np  <- isolate(n_pre())
    na  <- isolate(n_add())

    tabs <- lapply(seq_len(nag), function(ag) {
      nombre_tab <- isolate(input[[paste0("nombre_ag", ag)]]) %||%
                    paste("Agente", ag)
      tabPanel(
        title = nombre_tab,
        value = paste0("agente_", ag),
        br(),

        # Bloque preliminar
        div(class = "bloque-pre",
          h5("\ud83d\udccc Jornadas preliminares"),
          bloque_jornadas(ag, "pre", MAX_JORNADAS_PRE)
        ),

        # Resultado preliminar (si existe)
        uiOutput(paste0("resultado_pre_ag", ag)),

        # Bloque adicional (oculto en HTML desde el inicio)
        div(id = paste0("div_add_ag", ag),
          style = "display:none;",
          div(class = "bloque-add",
            h5("\ud83d\udcc5 Jornadas adicionales (desbloqueadas tras NO DECISI\u00d3N)"),
            bloque_jornadas(ag, "add", MAX_JORNADAS_PRE)
          )
        )
      )
    })

    pestanas_creadas(nag)
    do.call(tabsetPanel, c(list(id = "tabs_agentes"), tabs))
  })

  # Ocultar las jornadas que superen el visible (se ejecuta tras crear pestanas)
  observe({
    nag <- pestanas_creadas()
    if (nag == 0L) return()
    np <- n_pre(); na <- n_add()
    for (ag in seq_len(nag)) {
      key <- as.character(ag)
      vis_pre <- np[[key]] %||% 3L
      vis_add <- na[[key]] %||% 0L

      for (j in seq_len(MAX_JORNADAS_PRE)) {
        id_pre <- paste0("pre_ag", ag, "_j", j)
        if (j <= vis_pre) shinyjs::show(id_pre) else shinyjs::hide(id_pre)
        id_add <- paste0("add_ag", ag, "_j", j)
        if (j <= vis_add) shinyjs::show(id_add) else shinyjs::hide(id_add)
      }
    }
  })

  # Resultados preliminares por agente dentro de su pestana
  lapply(seq_len(MAX_AGENTES), function(ag) {
    output[[paste0("resultado_pre_ag", ag)]] <- renderUI({
      rp <- res_preliminar()[[as.character(ag)]]
      if (is.null(rp)) return(NULL)
      color <- switch(rp$resultado %||% "x",
        "CONFORMIDAD"    = "success",
        "NO CONFORMIDAD" = "danger",
        "NO DECISION"    = "warning",
        "default"
      )
      tagList(
        br(),
        h5(paste("Resultado preliminar \u2014", rp$nombre)),
        DT::dataTableOutput(paste0("tbl_pre_", ag)),
        div(class = paste0("alert alert-", color),
            strong("Resultado: "),
            rp$resultado %||% "Sin datos suficientes"),
        hr()
      )
    })
    output[[paste0("tbl_pre_", ag)]] <- DT::renderDataTable({
      rp <- res_preliminar()[[as.character(ag)]]
      if (is.null(rp)) return(NULL)
      DT::datatable(rp$tabla, rownames = FALSE, options = list(dom = "t"))
    })
  })

  # ---- grupos aditivos -------------------------------------------------------
  output$sidebar_aditivo <- renderUI({
    nag <- n_agentes()
    if (nag < 2L) return(NULL)
    ng  <- n_grupos()

    opciones <- setNames(
      as.character(seq_len(nag)),
      vapply(seq_len(nag), function(ag)
        input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag),
        character(1))
    )

    tagList(
      hr(),
      strong("\u2295 Efectos aditivos"),
      helpText("Crea grupos de agentes que comparten \u00f3rgano diana.
                Cada grupo calcula su propio IE combinado."),
      actionButton("nuevo_grupo", "\u002b Nuevo grupo aditivo",
                   class = "btn-warning btn-sm", width = "100%"),
      br(), br(),
      if (ng > 0L) {
        tagList(lapply(seq_len(ng), function(g) {
          div(
            style = "border:1px solid #ffc107; border-radius:4px;
                     padding:8px; margin-bottom:8px; background:#fffdf0;",
            strong(paste("Grupo", g)),
            checkboxGroupInput(
              paste0("grupo_", g),
              label = NULL,
              choices  = opciones,
              selected = isolate(input[[paste0("grupo_", g)]])
            ),
            actionButton(paste0("borrar_grupo_", g),
                         "Eliminar grupo", class = "btn-danger btn-xs")
          )
        }))
      }
    )
  })

  observeEvent(input$nuevo_grupo, {
    if (n_grupos() >= MAX_AGENTES) return()
    n_grupos(n_grupos() + 1L)
  })

  # borrar grupo dinamicamente
  lapply(seq_len(MAX_AGENTES), function(g) {
    observeEvent(input[[paste0("borrar_grupo_", g)]], {
      ga <- grupos_aditivos()
      ga[[as.character(g)]] <- NULL
      grupos_aditivos(ga)
      ng <- n_grupos()
      if (ng > 0L) n_grupos(ng - 1L)
    }, ignoreNULL = TRUE)
  })

  # ---- bloque aditivo (resultados) ------------------------------------------
  output$bloque_aditivo <- renderUI({
    rp <- res_preliminar()
    ng <- n_grupos()
    if (length(rp) < 2 || ng < 1L) return(NULL)

    bloques <- lapply(seq_len(ng), function(g) {
      marcados <- input[[paste0("grupo_", g)]]
      if (is.null(marcados) || length(marcados) < 2) return(NULL)
      ids_validos <- intersect(marcados, names(rp))
      if (length(ids_validos) < 2) return(NULL)

      filas <- lapply(ids_validos, function(ag) {
        r      <- rp[[ag]]
        ie_med <- mean(r$tabla$IE, na.rm = TRUE)
        data.frame(Agente = r$nombre,
                   `IE medio` = round(ie_med, 4),
                   check.names = FALSE)
      })
      df       <- do.call(rbind, filas)
      ie_total <- sum(df$`IE medio`, na.rm = TRUE)
      color_res <- if (ie_total < 0.1) "success" else if (ie_total > 1) "danger" else "warning"
      texto_res <- if (ie_total < 0.1) "CONFORMIDAD" else if (ie_total > 1) "NO CONFORMIDAD" else "NO DECISION"

      # Guardar df en output independiente para evitar renderTable anidado
      output[[paste0("tbl_aditivo_", g)]] <- renderTable({
        rbind(df, data.frame(
          Agente = "SUMA",
          `IE medio` = round(ie_total, 4),
          check.names = FALSE
        ))
      }, striped = TRUE, bordered = TRUE)

      div(class = "aditivo-box",
        h5(paste("\u2295 Grupo aditivo", g)),
        tableOutput(paste0("tbl_aditivo_", g)),
        div(class = paste0("alert alert-", color_res),
            strong("IE combinado = "), round(ie_total, 4),
            strong("  \u2192  "), texto_res)
      )
    })

    do.call(tagList, bloques)
  })

  # ---- selectores pestanas 2 y 3 --------------------------------------------
  selector_ui <- function(id, label) {
    renderUI({
      nag <- n_agentes()
      opciones <- setNames(
        as.character(seq_len(nag)),
        vapply(seq_len(nag), function(ag)
          input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag),
          character(1))
      )
      selectInput(id, label, choices = opciones)
    })
  }
  output$selector_agente_est <- selector_ui("agente_est", "Agente a evaluar:")
  output$selector_agente_per <- selector_ui("agente_per", "Agente:")

  # ---- evaluacion estadistica -----------------------------------------------
  observeEvent(input$evaluar_estadistica, {
    ag  <- as.integer(input$agente_est %||% "1")
    key <- as.character(ag)
    vla <- input[[paste0("vla_ag", ag)]]
    np  <- n_pre()[[key]] %||% 3L
    na  <- n_add()[[key]] %||% 0L

    if (is.null(vla) || is.na(vla) || vla <= 0) {
      showNotification("Introduce un VLA v\u00e1lido en la pesta\u00f1a 1.", type = "error")
      return()
    }

    # jornadas preliminares + adicionales juntas
    datos_pre <- recoger_muestras_bloque(input, ag, "pre", np, offset = 0L)
    datos_add <- if (na > 0L) {
      recoger_muestras_bloque(input, ag, "add", na, offset = np)
    } else {
      data.frame(jornada = integer(), concentracion = numeric(), tiempo = numeric())
    }
    datos <- rbind(datos_pre, datos_add)

    if (nrow(datos) == 0) {
      showNotification("Sin datos v\u00e1lidos.", type = "error")
      return()
    }

    jids <- sort(unique(datos$jornada))
    eds  <- vapply(jids, function(j) {
      sub <- datos[datos$jornada == j, ]
      une689_daily_exposure(sub$concentracion, sub$tiempo)
    }, numeric(1))
    eds <- eds[!is.na(eds) & eds > 0]

    if (!une689_validate_min_days(length(eds), minimo = 6L)) {
      showNotification(
        paste0("M\u00ednimo 6 jornadas v\u00e1lidas en total (hay ", length(eds), ")."),
        type = "error"
      )
      return()
    }

    res <- une689_evaluate_statistical(eds, vla = vla)
    re  <- res_estadistica()
    re[[key]] <- c(res, list(eds = eds, vla = vla))
    res_estadistica(re)
  })

  output$resumen_estadistica <- renderPrint({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re)) { cat("Pulsa 'Realizar evaluaci\u00f3n'.\n"); return() }

    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag)
    cat("Agente:", nombre, "\n")
    cat("N\u00ba jornadas totales:", re$n, "\n")
    cat("Distribuci\u00f3n inferida:", re$tipo, "\n\n")
    if (re$tipo == "Lognormal") {
      cat("MG =",  round(re$MG,  4), "\n")
      cat("DSG =", round(re$DSG, 4), "\n")
      cat("W (Shapiro-Wilk, log(ED)) =", round(re$W_lognormal,   3), "\n")
      cat("p-valor =",                    round(re$pval_lognormal, 4), "\n")
    } else if (re$tipo == "Normal") {
      cat("MA =", round(re$MA, 4), "\n")
      cat("DS =", round(re$DS, 4), "\n")
      cat("W (Shapiro-Wilk, ED) =", round(re$W_normal,   3), "\n")
      cat("p-valor =",               round(re$pval_normal, 4), "\n")
    } else {
      cat("Ni normal ni lognormal son adecuados (p <= 0.05 en ambos).\n")
    }
    cat("\nUT de referencia:", round(re$ut, 3), "\n")
    if (!is.na(re$lsc)) cat("LSC\u2089\u2085,\u2087\u2080 =", round(re$lsc, 4), "\n")
    if (!is.na(re$ur))  cat("UR =",              round(re$ur,  3), "\n")
    cat("\nResultado:", if (is.na(re$conformidad)) "No determinado" else re$conformidad, "\n")
  })

  output$grafico_densidad <- renderPlot({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re) || re$tipo == "Ninguna") return(NULL)

    df      <- data.frame(ED = re$eds)
    centro  <- if (re$tipo == "Lognormal") re$MG else re$MA
    label_c <- if (re$tipo == "Lognormal") "MG" else "MA"
    nombre  <- input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag)

    ggplot(df, aes(x = ED)) +
      geom_density(color = "orange", fill = "orange", alpha = 0.3) +
      geom_vline(xintercept = centro,  color = "green4",  linetype = "dashed") +
      geom_vline(xintercept = re$vla,  color = "red",     linetype = "dashed") +
      geom_vline(xintercept = re$lsc,  color = "darkred", linetype = "dotted") +
      annotate("text", x = centro, y = 0,
               label = paste0(label_c, ": ", round(centro, 3)),
               color = "green4", vjust = -1) +
      annotate("text", x = re$vla, y = 0,
               label = paste0("VLA: ", round(re$vla, 3)),
               color = "red", vjust = -1) +
      annotate("text", x = re$lsc, y = 0,
               label = paste0("LSC\u2089\u2085,\u2087\u2080: ", round(re$lsc, 3)),
               color = "darkred", vjust = -1) +
      labs(title = paste0("Distribuci\u00f3n de la ED \u2014 ", nombre),
           x = "ED (mg/m\u00b3)", y = "Densidad") +
      theme_minimal()
  })

  # ---- periodicidad ---------------------------------------------------------
  observeEvent(input$calcular_periodicidad, {
    ag <- as.integer(input$agente_per %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re)) {
      showNotification("Realiza antes la evaluaci\u00f3n estad\u00edstica.", type = "error")
      return()
    }
    texto <- if (input$opcion_periodicidad == "opc1") {
      valor <- if (!is.na(re$MG)) re$MG else re$MA
      une689_monitoring_interval_opt1(valor, vla = re$vla)
    } else {
      une689_monitoring_interval_opt2(re$lsc, vla = re$vla)
    }
    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste("Agente", ag)
    output$resultado_periodicidad <- renderPrint({
      cat("Agente:", nombre, "\n\n")
      cat(if (is.na(texto)) "No se pudo calcular." else texto, "\n")
    })
  })

  # ---- reiniciar ------------------------------------------------------------
  observeEvent(input$reset_todo, {
    n_agentes(1L)
    agente_activo(1L)
    n_pre(setNames(list(3L), "1"))
    n_add(setNames(list(0L), "1"))
    res_preliminar(list())
    res_estadistica(list())
    grupos_aditivos(list())
    n_grupos(0L)
    pestanas_creadas(0L)
  })
}

shinyApp(ui, server)
