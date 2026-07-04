#' Evaluar sustancias COSHH a partir de un fichero Excel
#'
#' Lee una hoja Excel con el formato de la plantilla COSHH de expoquimR
#' (una fila por sustancia) y devuelve la evaluacion completa de cada
#' una llamando a [coshh_evaluate()].
#'
#' @param ruta Character. Ruta al fichero `.xlsx`. Puede obtenerse con
#'   [system.file()] para la plantilla incluida en el paquete, o ser
#'   cualquier ruta local.
#' @param hoja Character o integer. Nombre o numero de la hoja que
#'   contiene los datos (por defecto `"COSHH_datos"`).
#'
#' @return Un `data.frame` con una fila por sustancia y las columnas
#'   de resultado de [coshh_evaluate()].
#'
#' @examples
#' \dontrun{
#' # Con la plantilla incluida en el paquete:
#' ruta <- system.file("plantillas", "plantilla_coshh.xlsx",
#'                     package = "expoquimR")
#' coshh_from_excel(ruta)
#'
#' # Con un fichero propio:
#' coshh_from_excel("mis_datos_coshh.xlsx")
#' }
#'
#' @export
coshh_from_excel <- function(ruta, hoja = "COSHH_datos") {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  df <- as.data.frame(readxl::read_excel(ruta, sheet = hoja, skip = 2, col_types = "text"))

  cols_req <- c("sustancia", "cantidad", "es_liquido")
  faltan <- setdiff(cols_req, names(df))
  if (length(faltan) > 0) {
    stop(.t("missing_cols", paste(faltan, collapse = ", ")), call. = FALSE)
  }

  resultados <- lapply(seq_len(nrow(df)), function(i) {
    fila <- df[i, ]

    es_liq <- isTRUE(toupper(trimws(fila$es_liquido)) == "TRUE")

    frases_h_str <- trimws(fila$frases_h %||% "")
    frases_r_str <- trimws(fila$frases_r %||% "")
    frases_combinadas <- paste(
      c(frases_h_str, frases_r_str)[nzchar(c(frases_h_str, frases_r_str))],
      collapse = ", "
    )

    coshh_evaluate(
      nombre        = fila$sustancia %||% paste("Sustancia", i),
      frases        = frases_combinadas,
      cantidad      = trimws(fila$cantidad),
      es_liquido    = es_liq,
      t_ebullicion  = suppressWarnings(as.numeric(fila$t_ebullicion)),
      t_proceso     = suppressWarnings(as.numeric(fila$t_proceso)),
      pulverulencia = trimws(fila$pulverulencia %||% NA_character_)
    )
  })

  do.call(rbind, resultados)
}

#' Evaluar productos quimicos INRS a partir de un fichero Excel
#'
#' Lee una hoja Excel con el formato de la plantilla INRS de expoquimR
#' (una fila por producto) y devuelve la evaluacion completa llamando
#' a [inrs_evaluate()].
#'
#' @param ruta Character. Ruta al fichero `.xlsx`.
#' @param hoja Character o integer. Nombre o numero de la hoja (por
#'   defecto `"INRS_datos"`).
#'
#' @return Un `data.frame` con una fila por producto y todas las
#'   columnas de resultado de [inrs_evaluate()].
#'
#' @examples
#' \dontrun{
#' ruta <- system.file("plantillas", "plantilla_inrs.xlsx",
#'                     package = "expoquimR")
#' inrs_from_excel(ruta)
#' }
#'
#' @export
inrs_from_excel <- function(ruta, hoja = "INRS_datos") {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  df <- as.data.frame(readxl::read_excel(ruta, sheet = hoja, skip = 2, col_types = "text"))

  cols_req <- c("producto", "procedimiento", "proteccion")
  faltan <- setdiff(cols_req, names(df))
  if (length(faltan) > 0) {
    stop(.t("missing_cols", paste(faltan, collapse = ", ")), call. = FALSE)
  }

  resultados <- lapply(seq_len(nrow(df)), function(i) {
    fila <- df[i, ]

    frases_h <- if (!is.na(fila$frases_h) && nzchar(trimws(fila$frases_h)))
      trimws(strsplit(fila$frases_h, ",")[[1]]) else character(0)
    frases_r <- if (!is.na(fila$frases_r) && nzchar(trimws(fila$frases_r)))
      trimws(strsplit(fila$frases_r, ",")[[1]]) else character(0)
    proceso  <- if (!is.na(fila$proceso) && nzchar(trimws(fila$proceso)))
      trimws(fila$proceso) else NULL

    inrs_evaluate(
      nombre            = fila$producto %||% paste("Producto", i),
      frases_h          = frases_h,
      frases_r          = frases_r,
      proceso           = proceso,
      vla               = suppressWarnings(as.numeric(fila$vla)),
      cantidad_valor    = suppressWarnings(as.numeric(fila$cantidad_valor)),
      cantidad_unidad   = trimws(fila$cantidad_unidad   %||% "g"),
      frecuencia_valor  = suppressWarnings(as.numeric(fila$frecuencia_valor)),
      frecuencia_unidad = trimws(fila$frecuencia_unidad %||% "horas"),
      tipo_sustancia    = trimws(fila$tipo_sustancia    %||% "liquida"),
      metodo_liquido    = trimws(fila$metodo_liquido    %||% "grafico"),
      temperatura_uso   = suppressWarnings(as.numeric(fila$temperatura_uso)),
      punto_ebullicion  = suppressWarnings(as.numeric(fila$punto_ebullicion)),
      presion_vapor     = suppressWarnings(as.numeric(fila$presion_vapor)),
      descripcion_solida = trimws(fila$descripcion_solida %||% NA_character_),
      procedimiento     = trimws(fila$procedimiento),
      proteccion        = trimws(fila$proteccion)
    )
  })

  do.call(rbind, resultados)
}

#' Evaluar exposicion quimica UNE-EN 689 a partir de un fichero Excel
#'
#' Lee las tres hojas de la plantilla UNE-EN 689 de expoquimR
#' (`Agentes`, `Mediciones` y opcionalmente `Efectos_aditivos`) y
#' devuelve una lista con la evaluacion preliminar de cada agente,
#' y si procede, el calculo de efectos aditivos por grupo.
#'
#' @param ruta Character. Ruta al fichero `.xlsx`.
#'
#' @return Una lista con los elementos:
#'   \describe{
#'     \item{`preliminar`}{Lista con un elemento por agente, cada uno
#'       con `nombre`, `vla`, `tabla_jornadas` y `resultado`.}
#'     \item{`aditivo`}{`data.frame` con columnas `grupo`, `agente`,
#'       `ie_medio` e `ie_combinado`, o `NULL` si no hay hoja de
#'       efectos aditivos.}
#'   }
#'
#' @examples
#' \dontrun{
#' ruta <- system.file("plantillas", "plantilla_une689.xlsx",
#'                     package = "expoquimR")
#' res <- une689_from_excel(ruta)
#' res$preliminar
#' res$aditivo
#' }
#'
#' @export
une689_from_excel <- function(ruta) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  hojas <- readxl::excel_sheets(ruta)

  # ---- Agentes --------------------------------------------------------------
  if (!"Agentes" %in% hojas) {
    stop("No se encontro la hoja 'Agentes' en el fichero.", call. = FALSE)
  }
  ag_df <- as.data.frame(readxl::read_excel(ruta, sheet = "Agentes",
                                              skip = 2, col_types = "text"))
  ag_df$vla_mg_m3 <- suppressWarnings(as.numeric(ag_df$vla_mg_m3))

  # ---- Mediciones -----------------------------------------------------------
  if (!"Mediciones" %in% hojas) {
    stop("No se encontro la hoja 'Mediciones' en el fichero.", call. = FALSE)
  }
  med_df <- as.data.frame(readxl::read_excel(ruta, sheet = "Mediciones",
                                               skip = 2, col_types = "text"))
  med_df$concentracion_mg_m3 <- suppressWarnings(as.numeric(med_df$concentracion_mg_m3))
  med_df$tiempo_h             <- suppressWarnings(as.numeric(med_df$tiempo_h))
  med_df$jornada              <- suppressWarnings(as.integer(med_df$jornada))

  # ---- Evaluacion preliminar por agente -------------------------------------
  preliminar <- lapply(seq_len(nrow(ag_df)), function(i) {
    nombre <- ag_df$agente[i]
    vla    <- ag_df$vla_mg_m3[i]

    # Seleccionar mediciones de este agente (solo tipo "pre")
    sub <- med_df[
      trimws(tolower(med_df$agente)) == trimws(tolower(nombre)) &
        trimws(tolower(med_df$tipo)) == "pre",
    ]
    sub <- sub[!is.na(sub$concentracion_mg_m3) & !is.na(sub$tiempo_h), ]

    if (nrow(sub) == 0 || is.na(vla)) {
      return(list(nombre = nombre, vla = vla,
                  tabla_jornadas = NULL, resultado = NA_character_))
    }

    datos <- data.frame(
      jornada       = sub$jornada,
      concentracion = sub$concentracion_mg_m3,
      tiempo        = sub$tiempo_h
    )

    res <- une689_evaluate_preliminary(datos, vla = vla)

    # Si NO DECISION, intentar evaluacion estadistica con jornadas adicionales
    if (!is.na(res$resultado) && res$resultado == .t("une689_no_decision")) {
      sub_add <- med_df[
        trimws(tolower(med_df$agente)) == trimws(tolower(nombre)) &
          trimws(tolower(med_df$tipo)) == "add",
      ]
      sub_add <- sub_add[!is.na(sub_add$concentracion_mg_m3) &
                           !is.na(sub_add$tiempo_h), ]

      if (nrow(sub_add) > 0) {
        n_pre <- max(datos$jornada, na.rm = TRUE)
        datos_add <- data.frame(
          jornada       = sub_add$jornada + n_pre,
          concentracion = sub_add$concentracion_mg_m3,
          tiempo        = sub_add$tiempo_h
        )
        datos_total <- rbind(datos, datos_add)

        jids <- sort(unique(datos_total$jornada))
        eds  <- vapply(jids, function(j) {
          s <- datos_total[datos_total$jornada == j, ]
          une689_daily_exposure(s$concentracion, s$tiempo)
        }, numeric(1))
        eds <- eds[!is.na(eds) & eds > 0]

        if (une689_validate_min_days(length(eds), minimo = 6L)) {
          est <- une689_evaluate_statistical(eds, vla = vla)
          est$eds <- eds   # needed for density plot in expoquimr_report()
          est$vla <- vla
          return(list(
            nombre         = nombre,
            vla            = vla,
            tabla_jornadas = res$tabla_jornadas,
            resultado      = res$resultado,
            estadistica    = est
          ))
        }
      }
    }

    list(nombre = nombre, vla = vla,
         tabla_jornadas = res$tabla_jornadas,
         resultado = res$resultado)
  })
  names(preliminar) <- ag_df$agente

  # ---- Efectos aditivos -----------------------------------------------------
  aditivo <- NULL
  if ("Efectos_aditivos" %in% hojas) {
    ad_df <- as.data.frame(readxl::read_excel(ruta, sheet = "Efectos_aditivos", skip = 2, col_types = "text"))
    ad_df$grupo <- suppressWarnings(as.integer(ad_df$grupo))

    grupos <- sort(unique(ad_df$grupo[!is.na(ad_df$grupo)]))
    filas_ad <- lapply(grupos, function(g) {
      agentes_g <- trimws(ad_df$agente[ad_df$grupo == g])
      desc_g    <- ad_df$descripcion_grupo[ad_df$grupo == g][1]

      ie_por_agente <- vapply(agentes_g, function(ag) {
        pre <- preliminar[[ag]]
        if (is.null(pre) || is.null(pre$tabla_jornadas)) return(NA_real_)
        mean(pre$tabla_jornadas$IE, na.rm = TRUE)
      }, numeric(1))

      # Solo calcular ie_combinado si TODOS los agentes del grupo tienen datos
      tiene_na <- anyNA(ie_por_agente)
      ie_combinado <- if (tiene_na) NA_real_ else sum(ie_por_agente)

      resultado_grupo <- if (tiene_na) {
        .t("une689_additive_na")
      } else if (ie_combinado < 0.1) {
        .t("une689_conformity")
      } else if (ie_combinado > 1) {
        .t("une689_no_conformity")
      } else {
        .t("une689_no_decision")
      }
      data.frame(
        grupo           = g,
        descripcion     = desc_g %||% "",
        agente          = agentes_g,
        ie_medio        = round(ie_por_agente, 4),
        ie_combinado    = round(ie_combinado, 4),
        resultado_grupo = resultado_grupo,
        stringsAsFactors = FALSE
      )
    })
    aditivo <- do.call(rbind, filas_ad)
  }

  list(preliminar = preliminar, aditivo = aditivo)
}

# Helper interno (evita dependencia de rlang en estas funciones)
`%||%` <- function(a, b) if (is.null(a) || (length(a) == 1 && is.na(a))) b else a
