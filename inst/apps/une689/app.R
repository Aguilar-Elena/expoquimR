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
      h6(textOutput(paste0("titulo_", prefijo, "_ag", ag, "_j", j), inline = TRUE)),
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
    data.frame(day = j + offset,
               concentration = conc, time = tiem)
  })
  datos <- do.call(rbind, filas)
  if (any(xor(is.na(datos$concentration), is.na(datos$time)))) {
    stop(tr("Hay muestras con concentración o tiempo sin completar.",
            "Some samples have an incomplete concentration/time pair."),
         call. = FALSE)
  }
  datos[!is.na(datos$concentration) & !is.na(datos$time), , drop = FALSE]
}

# ---------- UI ---------------------------------------------------------------

ui <- fluidPage(
  useShinyjs(),
  tags$head(tags$script(src = "i18n.js")),
  tags$script(HTML("Shiny.addCustomMessageHandler(\"expoquimr_une689_labels\", function(d) { Object.keys(d).forEach(function(k) { if(k === \"__en\") return; var el=document.getElementById(k); if(!el)return; if(el.tagName===\"BUTTON\")el.textContent=d[k]; else {var group=el.closest(\".form-group\"); var label=group && group.querySelector(\"label\"); if(label)label.textContent=d[k];} }); });")),
  selectInput("idioma_app", "Idioma / Language", choices = c("Español" = "es", "English" = "en"), selected = "es", width = "210px"),
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
          # DIAGNOSTICO_DISTRIBUCIONES_SHINY_V1
          uiOutput("diagnostico_distribuciones_ui"),
          plotOutput("grafico_densidad"),
          textOutput("nota_grafico_ges"),
          plotOutput("grafico_probabilidad")
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

  # La numeracion de las jornadas adicionales continua la preliminar.
  # Los identificadores de los inputs permanecen inalterados.
  for (ag in seq_len(MAX_AGENTES)) {
    for (j in seq_len(MAX_JORNADAS_PRE)) {
      local({
        agent_id <- ag
        day_id <- j
        output[[paste0("titulo_pre_ag", agent_id, "_j", day_id)]] <-
          renderText(paste(texto_grafico("Jornada", "Day"), day_id))
        output[[paste0("titulo_add_ag", agent_id, "_j", day_id)]] <-
          renderText({
            np <- n_pre()[[as.character(agent_id)]] %||% 3L
            paste(texto_grafico("Jornada", "Day"), np + day_id)
          })
      })
    }
  }

  # Textos bilingües de los gráficos; no altera el idioma interno del paquete.
  idioma_graficos <- reactive(input$idioma_app %||% "es")
  texto_grafico <- function(es, en) {
    if (identical(idioma_graficos(), "en")) en else es
  }
  tr <- function(es, en) texto_grafico(es, en)
  clasificar <- function(x) {
    switch(x %||% "", "CONFORMITY" = tr("CONFORMIDAD", "CONFORMITY"),
      "NON-CONFORMITY" = tr("NO CONFORMIDAD", "NON-CONFORMITY"),
      "NO DECISION" = tr("SIN DECISIÓN", "NO DECISION"),
      "INSUFFICIENT DATA" = tr("DATOS INSUFICIENTES", "INSUFFICIENT DATA"),
      x %||% tr("Sin datos suficientes", "Insufficient data"))
  }
  observeEvent(input$idioma_app, {
    es <- !identical(input$idioma_app, "en")
    pares <- list(
      nuevo_agente=c("+ Añadir agente", "+ Add agent"),
      evaluar_estadistica=c("Realizar evaluación", "Run assessment"),
      calcular_periodicidad=c("Calcular periodicidad", "Calculate monitoring interval"),
      opcion_periodicidad=c("Criterio:", "Criterion:"),
      idioma_app=c("Idioma / Language", "Language / Idioma")
    )
    session$sendCustomMessage("expoquimr_une689_labels", c(lapply(pares, function(v) v[if (es) 1 else 2]), list(`__en` = !es)))
  }, ignoreInit = FALSE)
  # Translate only untouched, automatically generated agent names.
  # User-entered names must never be replaced on a language switch.
  observeEvent(input$idioma_app, {
    target <- if (identical(input$idioma_app, "en")) "Agent" else "Agente"
    for (ag in seq_len(n_agentes())) {
      id <- paste0("nombre_ag", ag)
      current <- isolate(input[[id]])
      defaults <- paste(c("Agente", "Agent"), ag)
      if (!is.null(current) && current %in% defaults) {
        session$onFlushed(local({
          input_id <- id
          new_value <- paste(target, ag)
          function() updateTextInput(session, input_id, value = new_value)
        }), once = TRUE)
      }
    }
  }, ignoreInit = FALSE)

  formato_grafico <- function(x, digits = 4L) {
    formatC(x, format = "f", digits = digits, decimal.mark =
              if (identical(idioma_graficos(), "en")) "." else ",")
  }
  output$nota_grafico_ges <- renderText(texto_grafico(
    "Examen gráfico del GES: examine la alineación y posibles valores atípicos. Ni Shapiro-Wilk ni R² acreditan por sí solos la homogeneidad del grupo.",
    "SEG probability plot: inspect point alignment and potential outliers. Neither Shapiro-Wilk nor R² alone establishes group homogeneity."
  ))

  # ---- nuevo agente ---------------------------------------------------------
  observeEvent(input$nuevo_agente, {
    if (n_agentes() >= MAX_AGENTES) {
      showNotification(paste(tr("Máximo", "Maximum"), MAX_AGENTES, tr("agentes.", "agents.")), type = "warning")
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
                paste(tr("Nombre del agente", "Agent name"), ag),
                value = isolate(input[[paste0("nombre_ag", ag)]]) %||%
                        paste(tr("Agente", "Agent"), ag)),
      numericInput(paste0("vla_ag", ag), "VLA (mg/m\u00b3)",
                   value = isolate(input[[paste0("vla_ag", ag)]]) %||% NA_real_,
                   min = 0),
      hr(),
      strong(tr("Jornadas preliminares: ", "Preliminary days: "), np),
      br(),
      actionButton("add_pre",    tr("+ Preliminar", "+ Preliminary"),
                   class = "btn-default btn-sm"),
      actionButton("quitar_pre", tr("− Preliminar", "− Preliminary"),
                   class = "btn-default btn-sm"),
      br(), br(),
      actionButton(paste0("evaluar_pre_ag", ag),
                   paste(tr("Evaluar preliminar — Agente", "Preliminary assessment — Agent"), ag),
                   class = "btn-primary btn-sm", width = "100%"),

      # Jornadas adicionales: solo si n_add > 0
      if (na > 0) tagList(
        hr(),
        strong(tr("Jornadas adicionales: ", "Additional days: "), na),
        br(),
        actionButton("add_add",    tr("+ Adicional", "+ Additional"),
                     class = "btn-info btn-sm"),
        actionButton("quitar_add", tr("− Adicional", "− Additional"),
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
      nombre <- input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag)
      vla    <- input[[paste0("vla_ag", ag)]]
      np     <- n_pre()[[as.character(ag)]] %||% 3L

      if (is.null(vla) || is.na(vla) || vla <= 0) {
        showNotification(paste(tr("VLA inválido para", "Invalid OEL for"), nombre), type = "warning")
        return()
      }
      if (!une689_validate_min_days(np, minimum = 3L)) {
        showNotification(paste(nombre, tr(": mínimo 3 jornadas preliminares.", ": at least 3 preliminary days required.")),
                         type = "warning")
        return()
      }

      res_pre <- res_preliminar()
      res_pre[[as.character(ag)]] <- NULL
      res_preliminar(res_pre)
      datos <- tryCatch(
        recoger_muestras_bloque(input, ag, "pre", np, offset = 0L),
        error = function(e) {
          showNotification(conditionMessage(e), type = "error")
          NULL
        }
      )
      if (is.null(datos)) return()
      if (nrow(datos) == 0) {
        showNotification(paste(tr("Sin datos válidos para", "No valid data for"), nombre), type = "error")
        return()
      }

      res <- tryCatch(
        une689_evaluate_preliminary(datos, vla = vla),
        error = function(e) {
          showNotification(conditionMessage(e), type = "error")
          NULL
        }
      )
      if (is.null(res)) return()

      # Si NO DECISION -> desbloquear jornadas adicionales
      na <- n_add()
      if (!is.na(res$result) && res$result == "NO DECISION") {
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
            paste0(nombre, tr(": SIN DECISIÓN. Se han desbloqueado las jornadas adicionales para completar la evaluación estadística.", ": NO DECISION. Additional days have been unlocked to complete the statistical assessment.")),
            type = "message", duration = 6
          )
        }
      }

      rp <- res_preliminar()
      rp[[as.character(ag)]] <- list(
        name  = nombre, vla = vla,
        table = res$days_table,
        result = res$result
      )
      res_preliminar(rp)
    }, ignoreNULL = TRUE)
  })

  # ---- pestanas dinamicas ---------------------------------------------------
  output$pestanas_agentes <- renderUI({
    # Language changes must not recreate measurement inputs (which would lose data).
    tr_tabs <- function(es, en) isolate(tr(es, en))
    nag <- n_agentes()
    np  <- isolate(n_pre())
    na  <- isolate(n_add())

    tabs <- lapply(seq_len(nag), function(ag) {
      nombre_tab <- isolate(input[[paste0("nombre_ag", ag)]]) %||%
                    paste(tr_tabs("Agente", "Agent"), ag)
      tabPanel(
        title = nombre_tab,
        value = paste0("agente_", ag),
        br(),

        # Bloque preliminar
        div(class = "bloque-pre",
          h5(tr_tabs("Jornadas preliminares", "Preliminary measurement days")),
          bloque_jornadas(ag, "pre", MAX_JORNADAS_PRE)
        ),

        # Resultado preliminar (si existe)
        uiOutput(paste0("resultado_pre_ag", ag)),

        # Bloque adicional (oculto en HTML desde el inicio)
        div(id = paste0("div_add_ag", ag),
          style = "display:none;",
          div(class = "bloque-add",
            h5(tr_tabs("Jornadas adicionales (desbloqueadas tras SIN DECISIÓN)", "Additional days (unlocked after NO DECISION)")),
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
      color <- switch(rp$result %||% "x",
        "CONFORMITY"     = "success",
        "NON-CONFORMITY" = "danger",
        "NO DECISION"    = "warning",
        "default"
      )
      tagList(
        br(),
        h5(paste(tr("Resultado preliminar —", "Preliminary result —"), rp$name)),
        DT::dataTableOutput(paste0("tbl_pre_", ag)),
        div(class = paste0("alert alert-", color),
            strong(tr("Resultado: ", "Result: ")),
            clasificar(rp$result)),
        hr()
      )
    })
    output[[paste0("tbl_pre_", ag)]] <- DT::renderDataTable({
      rp <- res_preliminar()[[as.character(ag)]]
      if (is.null(rp)) return(NULL)
      tabla <- rp$table
      if ("ED" %in% names(tabla)) tabla$ED <- sprintf("%.5f", tabla$ED)
      if ("IE" %in% names(tabla)) tabla$IE <- sprintf("%.3f", tabla$IE)
      if (identical(idioma_graficos(), "en")) {
        names(tabla) <- sub("^Jornada$", "Day", names(tabla))
      }
      DT::datatable(tabla, rownames = FALSE, options = list(dom = "t"))

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
        input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag),
        character(1))
    )

    tagList(
      hr(),
      strong(tr("⊕ Efectos aditivos", "⊕ Additive effects")),
      helpText(tr("Crea grupos de agentes que comparten órgano diana. Cada grupo calcula su propio IE combinado.", "Create groups of agents sharing a target organ. Each group calculates its combined exposure index.")),
      actionButton("nuevo_grupo", tr("+ Nuevo grupo aditivo", "+ New additive group"),
                   class = "btn-warning btn-sm", width = "100%"),
      br(), br(),
      if (ng > 0L) {
        tagList(lapply(seq_len(ng), function(g) {
          div(
            style = "border:1px solid #ffc107; border-radius:4px;
                     padding:8px; margin-bottom:8px; background:#fffdf0;",
            strong(paste(tr("Grupo", "Group"), g)),
            checkboxGroupInput(
              paste0("grupo_", g),
              label = NULL,
              choices  = opciones,
              selected = isolate(input[[paste0("grupo_", g)]])
            ),
            actionButton(paste0("borrar_grupo_", g),
                         tr("Eliminar grupo", "Delete group"), class = "btn-danger btn-xs")
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
        ie_med <- mean(r$table$IE, na.rm = TRUE)
        data.frame(Agente = r$name,
                   `IE medio` = round(ie_med, 4),
                   check.names = FALSE)
      })
      df       <- do.call(rbind, filas)
      ie_total <- sum(df$`IE medio`, na.rm = TRUE)
      color_res <- if (ie_total < 0.1) "success" else if (ie_total > 1) "danger" else "warning"
      texto_res <- if (ie_total < 0.1) "CONFORMITY" else if (ie_total > 1) "NON-CONFORMITY" else "NO DECISION"

      # Guardar df en output independiente para evitar renderTable anidado
      output[[paste0("tbl_aditivo_", g)]] <- renderTable({
        rbind(df, data.frame(
          Agente = tr("SUMA", "TOTAL"),
          `IE medio` = round(ie_total, 4),
          check.names = FALSE
        ))
      }, striped = TRUE, bordered = TRUE)

      div(class = "aditivo-box",
        h5(paste(tr("⊕ Grupo aditivo", "⊕ Additive group"), g)),
        tableOutput(paste0("tbl_aditivo_", g)),
        div(class = paste0("alert alert-", color_res),
            strong(tr("IE combinado = ", "Combined EI = ")), round(ie_total, 4),
            strong("  \u2192  "), clasificar(texto_res))
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
          input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag),
          character(1))
      )
      selectInput(id, label, choices = opciones)
    })
  }
  output$selector_agente_est <- selector_ui("agente_est", tr("Agente a evaluar:", "Agent to assess:"))
  output$selector_agente_per <- selector_ui("agente_per", tr("Agente:", "Agent:"))

  # ---- evaluacion estadistica -----------------------------------------------
  observeEvent(input$evaluar_estadistica, {
    ag  <- as.integer(input$agente_est %||% "1")
    key <- as.character(ag)
    vla <- input[[paste0("vla_ag", ag)]]
    np  <- n_pre()[[key]] %||% 3L
    na  <- n_add()[[key]] %||% 0L

    if (is.null(vla) || is.na(vla) || vla <= 0) {
      showNotification(tr("Introduce un VLA válido en la pestaña 1.", "Enter a valid OEL in tab 1."), type = "error")
      return()
    }

    # jornadas preliminares + adicionales juntas
    re_old <- res_estadistica()
    re_old[[key]] <- NULL
    res_estadistica(re_old)
    datos <- tryCatch({
      datos_pre <- recoger_muestras_bloque(input, ag, "pre", np, offset = 0L)
      datos_add <- if (na > 0L) {
        recoger_muestras_bloque(input, ag, "add", na, offset = np)
      } else {
        data.frame(day = integer(), concentration = numeric(), time = numeric())
      }
      rbind(datos_pre, datos_add)
    }, error = function(e) {
      showNotification(conditionMessage(e), type = "error")
      NULL
    })
    if (is.null(datos)) return()

    if (nrow(datos) == 0) {
      showNotification(tr("Sin datos válidos.", "No valid data."), type = "error")
      return()
    }

    jids <- sort(unique(datos$day))
    eds  <- vapply(jids, function(j) {
      sub <- datos[datos$day == j, ]
      une689_daily_exposure(sub$concentration, sub$time)
    }, numeric(1))
    eds <- eds[!is.na(eds) & eds > 0]

    if (!une689_validate_min_days(length(eds), minimum = 6L)) {
      showNotification(
        paste0(tr("Mínimo 6 jornadas válidas en total (hay ", "At least 6 valid days required (found "), length(eds), ")."),
        type = "error"
      )
      return()
    }

    res <- tryCatch(
      une689_evaluate_statistical(eds, vla = vla),
      error = function(e) {
        showNotification(conditionMessage(e), type = "error")
        NULL
      }
    )
    if (is.null(res)) return()
    re  <- res_estadistica()
    # Diagnostico informativo; no modifica la decision del procedimiento actual.
    diagnostico <- tryCatch(
      une689_compare_distributions(ed = eds, vla = vla),
      error = function(e) {
        showNotification(paste(tr("Diagnostico de distribuciones no disponible:",
                                  "Distribution diagnostics unavailable:"),
                               conditionMessage(e)), type = "warning")
        NULL
      }
    )
    re[[key]] <- c(res, list(eds = eds, vla = vla,
                             diagnostico_distribuciones = diagnostico))
    res_estadistica(re)
  })

  output$resumen_estadistica <- renderPrint({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re)) { cat(tr("Pulsa 'Realizar evaluación'.\n", "Click 'Run assessment'.\n")); return() }

    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag)
    cat(tr("Agente:", "Agent:"), nombre, "\n")
    cat(tr("N.º jornadas totales:", "Total measurement days:"), re$n, "\n")
    if (identical(re$diagnostic_status, "CONSTANT_EXPOSURES")) {
      cat(tr("Distribución: no determinada (exposiciones constantes).\n",
             "Distribution: undetermined (constant exposures).\n"))
      cat(tr("Shapiro-Wilk no es aplicable; la dispersión observada es nula.\n",
             "Shapiro-Wilk is not applicable; observed dispersion is zero.\n"))
      cat(tr("Resultado: NO DETERMINADO. Revise resolución analítica, redondeos y condiciones del GES.\n",
             "Result: UNDETERMINED. Review analytical resolution, rounding and SEG conditions.\n"))
      return(invisible(NULL))
    }
    cat(tr("Distribución seleccionada automáticamente:", "Automatically selected distribution:"), re$distribution_type, "\n\n")
    if (re$distribution_type == "Lognormal") {
      cat("MG =",  round(re$MG,  4), "\n")
      cat("DSG =", round(re$DSG, 4), "\n")
      cat("W (Shapiro-Wilk, log(ED)) =", round(re$W_lognormal,   3), "\n")
      cat(tr("p-valor =", "p-value ="),                    round(re$pval_lognormal, 4), "\n")
    } else if (re$distribution_type == "Normal") {
      cat("MA =", round(re$MA, 4), "\n")
      cat("DS =", round(re$DS, 4), "\n")
      cat("W (Shapiro-Wilk, ED) =", round(re$W_normal,   3), "\n")
      cat(tr("p-valor =", "p-value ="),               round(re$pval_normal, 4), "\n")
    } else {
      cat(tr("Ni normal ni lognormal son adecuados (p <= 0.05 en ambos).\n", "Neither normal nor lognormal distribution is suitable (p <= 0.05 for both).\n"))
    }
    cat(tr("\nUT de referencia:", "\nReference UT:"), round(re$ut, 3), "\n")
    if (!is.na(re$lsc)) cat("LSC\u2089\u2085,\u2087\u2080 =", round(re$lsc, 4), "\n")
    if (!is.na(re$ur))  cat("UR =",              round(re$ur,  3), "\n")
    # TRAZABILIDAD_RESULTADO_ESTADISTICO_V2
    diag <- re$diagnostico_distribuciones
    hay_discordancia <- !is.null(diag) && isTRUE(diag$discordant)
    etiqueta_resultado <- if (hay_discordancia)
      tr("\nResultado del modelo seleccionado automáticamente:",
         "\nResult of the automatically selected model:")
    else tr("\nResultado:", "\nResult:")
    cat(etiqueta_resultado,
        if (is.na(re$conformity)) tr("No determinado", "Undetermined")
        else clasificar(re$conformity), "\n")
    if (hay_discordancia) {
      cat("\n", tr(
        "ADVERTENCIA: los modelos normal y lognormal ofrecen decisiones diferentes. La conclusión técnica definitiva requiere revisar la distribución, los datos y el GES; la selección automática no sustituye esa revisión.",
        "WARNING: normal and lognormal models yield different decisions. The definitive technical conclusion requires review of the distribution, data and SEG; automatic selection does not replace that review."
      ), "\n", sep = "")
    }
  })

  output$diagnostico_distribuciones_ui <- renderUI({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re) || is.null(re$diagnostico_distribuciones)) return(NULL)
    diag <- re$diagnostico_distribuciones
    tagList(
      hr(),
      h4(tr("Comparacion de distribuciones", "Distribution comparison")),
      p(tr("Prueba de Shapiro-Wilk: no rechazar una distribucion no demuestra que sea correcta. La seleccion requiere examen grafico y criterio tecnico del GES.",
           "Shapiro-Wilk test: failure to reject a distribution does not prove it is correct. Selection requires graphical review and professional SEG assessment.")),
      tableOutput("tabla_diagnostico_distribuciones"),
      if (isTRUE(diag$discordant))
        div(class = "alert alert-warning",
            strong(tr("Advertencia: decisiones discordantes. ", "Warning: discordant decisions. ")),
            tr("Los modelos normal y lognormal producen conclusiones matematicas diferentes. Revise la distribucion, el GES y la justificacion tecnica antes de interpretar la conformidad.",
               "Normal and lognormal models yield different mathematical conclusions. Review the distribution, SEG and technical rationale before interpreting conformity."))
      else if (isTRUE(diag$requires_review))
        div(class = "alert alert-warning",
            tr("Se requiere revision tecnica de la distribucion y de los datos.",
               "Technical review of the distribution and data is required.")),
      p(class = "text-muted",
        tr("Este diagnostico es complementario: no modifica el resultado principal ni la periodicidad calculada.",
           "This diagnostic is supplementary: it does not change the main result or the calculated monitoring interval."))
    )
  })

  output$tabla_diagnostico_distribuciones <- renderTable({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re) || is.null(re$diagnostico_distribuciones)) return(NULL)
    m <- re$diagnostico_distribuciones$models
    if (is.null(m) || !nrow(m)) return(NULL)
    es <- !identical(idioma_graficos(), "en")
    fmt <- function(x, n = 4L) ifelse(is.na(x), "—", formato_grafico(x, n))
    data.frame(
      Modelo = as.character(m$model),
      `p (Shapiro-Wilk)` = fmt(m$p_value),
      `No rechazada` = ifelse(m$not_rejected, if (es) "Si" else "Yes", if (es) "No" else "No"),
      UT = fmt(m$ut, 3L),
      LSC = fmt(m$lsc),
      UR = fmt(m$ur),
      Decision = vapply(as.character(m$mathematical_decision), clasificar, character(1)),
      check.names = FALSE
    ) |> setNames(if (es)
      c("Modelo", "p (Shapiro-Wilk)", "No rechazada", "UT", "LSC", "UR", "Decision matematica")
      else c("Model", "p (Shapiro-Wilk)", "Not rejected", "UT", "UCL", "UR", "Mathematical decision"))
  }, striped = TRUE, bordered = TRUE, spacing = "s", rownames = FALSE)

    output$grafico_densidad <- renderPlot({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re) || !re$distribution_type %in% c("Normal", "Lognormal")) return(NULL)

    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag)
    expoquimR:::.une689_parametric_density_plot(
      eds = re$eds, distribution = re$distribution_type,
      ma = re$MA, ds = re$DS, mg = re$MG, dsg = re$DSG,
      vla = re$vla, lsc = re$lsc,
      title = paste0(texto_grafico("Distribución de la ED — ", "Daily exposure distribution — "), nombre),
      subtitle = texto_grafico(
        if (identical(re$distribution_type, "Lognormal")) "Densidad log-normal ajustada" else "Densidad normal ajustada",
        if (identical(re$distribution_type, "Lognormal")) "Fitted lognormal density" else "Fitted normal density"
      ),
      x_label = texto_grafico("ED (mg/m³)", "Daily exposure (mg/m³)"),
      y_label = texto_grafico("Densidad", "Density"),
      vla_label = texto_grafico("VLA", "OEL"),
      lsc_label = texto_grafico("LSC₉₅,₇₀", "UCL₉₅,₇₀")
    )
  })

  output$grafico_probabilidad <- renderPlot({
    ag <- as.integer(input$agente_est %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re)) return(NULL)
    if (re$distribution_type %in% c("Neither", "Ninguna")) {
      plot.new()
      text(0.5, 0.5, texto_grafico("No se seleccionó una distribución normal o lognormal.\nRevise los datos y el GES.", "Neither a normal nor a lognormal distribution was selected.\nReview the data and the SEG."))
      return(invisible(NULL))
    }
    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag)
    papel <- if (identical(re$distribution_type, "Lognormal")) "log-normal" else "normal"
    une689_probability_plot(
      ed = re$eds,
      distribution = re$distribution_type,
      vla = re$vla,
      title = paste0(texto_grafico("Examen gráfico del GES en papel ", "SEG probability plot on "), papel, " — ", nombre),
      x_label = texto_grafico("ED (mg/m³)", "Daily exposure (mg/m³)"),
      y_label = texto_grafico("Probabilidad acumulada P_k (%)", "Cumulative probability P_k (%)"),
      vla_label = texto_grafico("VLA", "OEL")
    )
  })

  # ---- periodicidad ---------------------------------------------------------
  observeEvent(input$calcular_periodicidad, {
    ag <- as.integer(input$agente_per %||% "1")
    re <- res_estadistica()[[as.character(ag)]]
    if (is.null(re)) {
      showNotification(tr("Realiza antes la evaluación estadística.", "Run the statistical assessment first."), type = "error")
      return()
    }
    if (identical(re$diagnostic_status, "CONSTANT_EXPOSURES")) {
      showNotification(tr("Periodicidad no determinada: revise primero las exposiciones constantes.",
                          "Monitoring interval undetermined: review constant exposures first."),
                       type = "warning")
      return()
    }
    texto <- if (input$opcion_periodicidad == "opc1") {
      valor <- if (!is.na(re$MG)) re$MG else re$MA
      une689_monitoring_interval_opt1(valor, vla = re$vla)
    } else {
      une689_monitoring_interval_opt2(re$lsc, vla = re$vla)
    }
    nombre <- input[[paste0("nombre_ag", ag)]] %||% paste(tr("Agente", "Agent"), ag)
    output$resultado_periodicidad <- renderPrint({
      idioma_graficos()
      cat(tr("Agente:", "Agent:"), nombre, "\n\n")
      cat(if (is.na(texto)) tr("No se pudo calcular.", "Could not calculate.") else texto, "\n")
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
