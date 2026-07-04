#' Classify the volatility of a liquid using the COSHH Essentials method
#'
#' Compares the boiling point of a substance with its process temperature
#' to assign a volatility class (`"Low"` / `"Medium"` / `"High"` in English,
#' `"Baja"` / `"Media"` / `"Alta"` in Spanish), following the thresholds of
#' the COSHH Essentials method.
#'
#' The active language is controlled by [expoquimr_lang()].
#'
#' @param t_ebullicion Numeric. Boiling point of the substance, in degrees
#'   Celsius.
#' @param t_proceso Numeric. Temperature at which the substance is handled,
#'   in degrees Celsius.
#'
#' @return Character scalar: volatility class in the active language.
#'
#' @examples
#' coshh_classify_volatility(t_ebullicion = 111, t_proceso = 20)
#' expoquimr_lang("es")
#' coshh_classify_volatility(t_ebullicion = 111, t_proceso = 20)
#' expoquimr_lang("en")
#'
#' @export
coshh_classify_volatility <- function(t_ebullicion, t_proceso) {
  stopifnot(is.numeric(t_ebullicion), is.numeric(t_proceso))
  if (anyNA(t_ebullicion) || anyNA(t_proceso)) {
    stop("t_ebullicion and t_proceso must not be NA.", call. = FALSE)
  }
  ifelse(
    t_ebullicion > 5 * t_proceso + 50, .t("coshh_vol_low"),
    ifelse(t_ebullicion > 2 * t_proceso + 10, .t("coshh_vol_medium"),
           .t("coshh_vol_high"))
  )
}

#' Determine the COSHH hazard group from R/H phrases
#'
#' Looks up each risk phrase (R) or hazard phrase (H) in the COSHH Essentials
#' hazard group assignment table (groups A to E) and returns the most
#' unfavourable group found. Any phrase not listed explicitly in groups B-E is
#' assigned to group A, following the default rule of the original method.
#'
#' @param frases Character scalar containing one or more phrases separated by
#'   commas, e.g. `"H315, H319"` or `"R20/21/22"`.
#'
#' @return Character scalar with the group (`"A"` to `"E"`), or
#'   `NA_character_` if `frases` is empty or `NA`.
#'
#' @examples
#' coshh_grade("H315, H319")
#' coshh_grade("R23/24/25")
#'
#' @export
coshh_grade <- function(frases) {
  if (is.null(frases) || is.na(frases) || !nzchar(trimws(frases))) {
    return(NA_character_)
  }

  tokens <- trimws(toupper(strsplit(frases, ",")[[1]]))
  tokens <- tokens[nzchar(tokens)]
  if (length(tokens) == 0) return(NA_character_)

  tabla <- coshh_tabla_grados
  orden <- c("A", "B", "C", "D", "E")

  grado_de_token <- function(token) {
    for (i in seq_len(nrow(tabla))) {
      lista_r <- trimws(toupper(strsplit(tabla$frases_r[i], ",")[[1]]))
      lista_h <- trimws(toupper(strsplit(tabla$frases_h[i], ",")[[1]]))
      if (token %in% lista_r || token %in% lista_h) {
        return(tabla$grado[i])
      }
    }
    "A"
  }

  grados <- vapply(tokens, grado_de_token, character(1))
  orden[max(match(grados, orden))]
}

#' Calculate the COSHH risk level
#'
#' Queries the hazard x quantity x volatility matrix of the COSHH Essentials
#' method to obtain the potential risk level (1 to 4). Substances of grade
#' `"E"` (carcinogenic, mutagenic or similar) always receive the maximum
#' level, regardless of quantity or volatility.
#'
#' @param grado Character. Hazard group (`"A"` to `"E"`), as returned by
#'   [coshh_grade()].
#' @param cantidad Character. Quantity class in the active language. Use
#'   `"Small"` / `"Medium"` / `"Large"` (English) or `"Pequeña"` /
#'   `"Mediana"` / `"Grande"` (Spanish). See [expoquimr_lang()].
#' @param volatilidad Character. Volatility class in the active language.
#'   Use `"Low"` / `"Medium"` / `"High"` (English) or `"Baja"` / `"Media"`
#'   / `"Alta"` (Spanish). For solids, this corresponds to dustiness.
#'
#' @return Integer with the risk level (1 to 4), or `NA_integer_` if the
#'   combination is not defined in the table or `grado` is `NA`.
#'
#' @examples
#' coshh_risk(grado = "C", cantidad = "Medium", volatilidad = "High")
#' coshh_risk(grado = "E", cantidad = "Small",  volatilidad = "Low")
#'
#' @export
coshh_risk <- function(grado, cantidad, volatilidad) {
  if (is.na(grado)) return(NA_integer_)
  if (grado == "E") return(4L)

  # Normalise quantity and volatility to Spanish (internal table keys)
  cantidad_es <- switch(cantidad,
    "Small"  = "Peque\u00f1a", "Medium" = "Mediana", "Large" = "Grande",
    cantidad  # already Spanish
  )
  volatilidad_es <- switch(volatilidad,
    "Low"    = "Baja", "Medium" = "Media", "High"  = "Alta",
    volatilidad  # already Spanish
  )

  resultado <- coshh_tabla_riesgo[
    coshh_tabla_riesgo$peligrosidad == grado &
      coshh_tabla_riesgo$cantidad    == cantidad_es &
      coshh_tabla_riesgo$volatilidad == volatilidad_es,
    "riesgo", drop = TRUE
  ]

  if (length(resultado) == 0) NA_integer_ else as.integer(resultado[1])
}

#' Get the recommended control measures for a COSHH risk level
#'
#' @param nivel_riesgo Integer or character. Risk level (1 to 4), as returned
#'   by [coshh_risk()].
#'
#' @return Character scalar with the recommended control measures in the
#'   active language (see [expoquimr_lang()]), or `NA_character_` if the
#'   level is not defined.
#'
#' @examples
#' coshh_measures(3)
#' expoquimr_lang("es")
#' coshh_measures(3)
#' expoquimr_lang("en")
#'
#' @export
coshh_measures <- function(nivel_riesgo) {
  if (is.na(nivel_riesgo)) return(NA_character_)
  switch(as.character(nivel_riesgo),
    "1" = .t("coshh_risk_1_measures"),
    "2" = .t("coshh_risk_2_measures"),
    "3" = .t("coshh_risk_3_measures"),
    "4" = .t("coshh_risk_4_measures"),
    NA_character_
  )
}

#' Evaluate a substance using the COSHH Essentials method (high-level wrapper)
#'
#' Chains [coshh_grade()], [coshh_classify_volatility()] (if applicable),
#' [coshh_risk()] and [coshh_measures()] to produce a complete result row
#' from the raw data of a substance. Designed to be called directly from code
#' (scripts, reports, `purrr::pmap`, vignettes) without going through the
#' Shiny application.
#'
#' Output labels (volatility class, quantity class, control measures) are
#' returned in the active language; see [expoquimr_lang()].
#'
#' @param nombre Character. Identifying name of the substance.
#' @param frases Character. H/R phrases; see [coshh_grade()].
#' @param cantidad Character. Quantity class in the active language.
#' @param es_liquido Logical. `TRUE` if the substance is liquid (volatility
#'   will be calculated from `t_ebullicion` / `t_proceso`); `FALSE` if solid
#'   (`pulverulencia` will be used directly).
#' @param t_ebullicion,t_proceso Numeric. Required only if
#'   `es_liquido = TRUE`. See [coshh_classify_volatility()].
#' @param pulverulencia Character. Required only if `es_liquido = FALSE`.
#'   Dustiness class in the active language.
#'
#' @return A one-row `data.frame` with columns `sustancia`, `frases`,
#'   `grado`, `volatilidad`, `cantidad`, `riesgo` and `medidas`.
#'
#' @examples
#' coshh_evaluate(
#'   nombre = "Toluene",
#'   frases = "H315, H336",
#'   cantidad = "Medium",
#'   es_liquido = TRUE,
#'   t_ebullicion = 111,
#'   t_proceso = 20
#' )
#'
#' @export
coshh_evaluate <- function(nombre,
                           frases,
                           cantidad,
                           es_liquido,
                           t_ebullicion = NA_real_,
                           t_proceso    = NA_real_,
                           pulverulencia = NA_character_) {
  grado <- coshh_grade(frases)

  volatilidad <- if (isTRUE(es_liquido)) {
    coshh_classify_volatility(t_ebullicion, t_proceso)
  } else {
    pulverulencia
  }

  riesgo  <- coshh_risk(grado, cantidad, volatilidad)
  medidas <- coshh_measures(riesgo)

  data.frame(
    sustancia   = nombre,
    frases      = frases,
    grado       = grado,
    volatilidad = volatilidad,
    cantidad    = cantidad,
    riesgo      = riesgo,
    medidas     = medidas,
    stringsAsFactors = FALSE
  )
}
