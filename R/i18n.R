# Internal translation system for expoquimR
# Default language: English ("en")
# Supported languages: "en", "es"
#
# Usage:
#   options(expoquimR.lang = "es")   # switch to Spanish
#   options(expoquimR.lang = "en")   # switch to English (default)
#   .t("coshh_volatility_low")       # get translated string

.translations <- list(

  en = list(

    # ---- General ------------------------------------------------------------
    lang_not_supported    = "Language '%s' is not supported. Use 'en' or 'es'.",
    missing_cols          = "Missing required columns in Excel file: %s",
    no_valid_data         = "No valid data found for agent '%s'.",
    invalid_vla           = "VLA must be a positive number (got: %s).",
    min_jornadas          = "At least %d measurement days are required (got: %d).",
    ed_positive           = "All ED values must be positive numbers without NA.",
    need_readxl           = "Package 'readxl' is required to read Excel files. Install it with: install.packages('readxl')",
    app_not_found         = "App '%s' was not found inside the expoquimR package.",
    need_shiny            = "The following packages are required to run expoquimR apps: %s. Install them with: install.packages(c(%s))",

    # ---- COSHH --------------------------------------------------------------
    coshh_no_frases       = "No hazard phrases (H or R) provided. Substance assigned to hazard group A by default.",
    coshh_grade_a         = "A",
    coshh_grade_b         = "B",
    coshh_grade_c         = "C",
    coshh_grade_d         = "D",
    coshh_grade_e         = "E",
    coshh_qty_small       = "Small",
    coshh_qty_medium      = "Medium",
    coshh_qty_large       = "Large",
    coshh_vol_low         = "Low",
    coshh_vol_medium      = "Medium",
    coshh_vol_high        = "High",
    coshh_risk_1_measures = "General ventilation. Low risk.",
    coshh_risk_2_measures = "Specific prevention and protection measures, e.g. local exhaust ventilation.",
    coshh_risk_3_measures = "Containment or closed systems. Keep process below atmospheric pressure where possible.",
    coshh_risk_4_measures = "Comply with legislation for CMR substances categories 1 and 2. Detailed exposure assessment required. Verify control effectiveness frequently.",

    # ---- INRS ---------------------------------------------------------------
    inrs_char_1           = "1 - Risk appears low a priori (no modifications needed)",
    inrs_char_2           = "2 - Moderate risk (corrective measures and/or more detailed assessment likely needed)",
    inrs_char_3           = "3 - Very high risk (immediate corrective action required)",

    # ---- UNE-EN 689 ---------------------------------------------------------
    une689_conformity     = "CONFORMITY",
    une689_no_conformity  = "NON-CONFORMITY",
    une689_no_decision    = "NO DECISION",
    une689_insufficient   = "INSUFFICIENT DATA",
    une689_indeterminate  = "INDETERMINATE",
    une689_lognormal      = "Lognormal",
    une689_normal         = "Normal",
    une689_neither        = "Neither",
    une689_false_conform  = "No valid IE values available. Cannot classify conformity.",
    une689_period_36      = "Recommended monitoring interval: 36 months",
    une689_period_30      = "Recommended monitoring interval: 30 months",
    une689_period_24      = "Recommended monitoring interval: 24 months",
    une689_period_18      = "Recommended monitoring interval: 18 months",
    une689_period_12      = "Recommended monitoring interval: 12 months",
    une689_period_review  = "Not recommended. Exposure must be reviewed.",
    une689_additive_na    = "INSUFFICIENT DATA (one or more agents in this group have no valid IE)",

    # ---- desde_excel --------------------------------------------------------
    excel_no_sheet_agents = "Sheet 'Agentes' / 'Agents' not found in the file.",
    excel_no_sheet_meas   = "Sheet 'Mediciones' / 'Measurements' not found in the file.",
    excel_agent_col       = "agente",
    excel_vla_col         = "vla_mg_m3",
    excel_type_col        = "tipo",
    excel_jornada_col     = "jornada",
    excel_conc_col        = "concentracion_mg_m3",
    excel_time_col        = "tiempo_h"
  ),

  es = list(

    # ---- General ------------------------------------------------------------
    lang_not_supported    = "El idioma '%s' no está soportado. Usa 'en' o 'es'.",
    missing_cols          = "Faltan columnas obligatorias en el fichero Excel: %s",
    no_valid_data         = "No se encontraron datos válidos para el agente '%s'.",
    invalid_vla           = "El VLA debe ser un número positivo (recibido: %s).",
    min_jornadas          = "Se necesitan al menos %d jornadas (se encontraron: %d).",
    ed_positive           = "Todos los valores de ED deben ser números positivos, sin NA.",
    need_readxl           = "El paquete 'readxl' es necesario para leer ficheros Excel. Instálalo con: install.packages('readxl')",
    app_not_found         = "No se encontró la app '%s' dentro del paquete expoquimR.",
    need_shiny            = "Los siguientes paquetes son necesarios para usar las apps de expoquimR: %s. Instálalos con: install.packages(c(%s))",

    # ---- COSHH --------------------------------------------------------------
    coshh_no_frases       = "No se han proporcionado frases de peligro (H o R). Se asigna el grupo A por defecto.",
    coshh_grade_a         = "A",
    coshh_grade_b         = "B",
    coshh_grade_c         = "C",
    coshh_grade_d         = "D",
    coshh_grade_e         = "E",
    coshh_qty_small       = "Pequeña",
    coshh_qty_medium      = "Mediana",
    coshh_qty_large       = "Grande",
    coshh_vol_low         = "Baja",
    coshh_vol_medium      = "Media",
    coshh_vol_high        = "Alta",
    coshh_risk_1_measures = "Ventilación general. Riesgo leve.",
    coshh_risk_2_measures = "Medidas específicas de prevención y protección, por ejemplo, extracción localizada.",
    coshh_risk_3_measures = "Confinamiento o sistemas cerrados. Mantener el proceso a presión inferior a la atmosférica cuando sea posible.",
    coshh_risk_4_measures = "Cumplir con la legislación para sustancias CMR de categorías 1 y 2. Evaluación detallada de la exposición. Verificar con mayor frecuencia la eficacia de las instalaciones de control.",

    # ---- INRS ---------------------------------------------------------------
    inrs_char_1           = "1 - Riesgo a priori bajo (sin necesidad de modificaciones)",
    inrs_char_2           = "2 - Riesgo moderado (probablemente necesita medidas correctoras y/o evaluación más detallada)",
    inrs_char_3           = "3 - Riesgo muy elevado (medidas correctoras inmediatas requeridas)",

    # ---- UNE-EN 689 ---------------------------------------------------------
    une689_conformity     = "CONFORMIDAD",
    une689_no_conformity  = "NO CONFORMIDAD",
    une689_no_decision    = "NO DECISIÓN",
    une689_insufficient   = "DATOS INSUFICIENTES",
    une689_indeterminate  = "INDETERMINADO",
    une689_lognormal      = "Lognormal",
    une689_normal         = "Normal",
    une689_neither        = "Ninguna",
    une689_false_conform  = "No hay valores de IE válidos. No es posible clasificar la conformidad.",
    une689_period_36      = "Periodicidad recomendada: 36 meses",
    une689_period_30      = "Periodicidad recomendada: 30 meses",
    une689_period_24      = "Periodicidad recomendada: 24 meses",
    une689_period_18      = "Periodicidad recomendada: 18 meses",
    une689_period_12      = "Periodicidad recomendada: 12 meses",
    une689_period_review  = "No recomendable. Revisar la exposición.",
    une689_additive_na    = "DATOS INSUFICIENTES (uno o más agentes del grupo no tienen IE válido)",

    # ---- desde_excel --------------------------------------------------------
    excel_no_sheet_agents = "No se encontró la hoja 'Agentes' en el fichero.",
    excel_no_sheet_meas   = "No se encontró la hoja 'Mediciones' en el fichero.",
    excel_agent_col       = "agente",
    excel_vla_col         = "vla_mg_m3",
    excel_type_col        = "tipo",
    excel_jornada_col     = "jornada",
    excel_conc_col        = "concentracion_mg_m3",
    excel_time_col        = "tiempo_h"
  )
)

#' Get or set the language used by expoquimR
#'
#' expoquimR supports English (`"en"`, default) and Spanish (`"es"`). The
#' active language controls the language of function output messages, column
#' labels returned by high-level wrapper functions, and error/warning
#' messages. It does **not** affect the Shiny apps, which have their own
#' in-app language selector.
#'
#' @param lang Character. `"en"` (English, default) or `"es"` (Spanish).
#'   If `NULL`, returns the currently active language without changing it.
#'
#' @return Invisibly returns the previously active language.
#'
#' @examples
#' expoquimr_lang()          # query current language
#' expoquimr_lang("es")      # switch to Spanish
#' expoquimr_lang("en")      # switch back to English
#'
#' @export
expoquimr_lang <- function(lang = NULL) {
  prev <- getOption("expoquimR.lang", default = "en")
  if (is.null(lang)) {
    message("Current expoquimR language: ", prev)
    return(invisible(prev))
  }
  lang <- tolower(trimws(lang))
  if (!lang %in% names(.translations)) {
    stop(sprintf(.translations[["en"]][["lang_not_supported"]], lang),
         call. = FALSE)
  }
  options(expoquimR.lang = lang)
  invisible(prev)
}

# Internal helper: get a translated string by key
# sprintf-style arguments can be passed via ...
.t <- function(key, ...) {
  lang <- getOption("expoquimR.lang", default = "en")
  if (!lang %in% names(.translations)) lang <- "en"
  txt <- .translations[[lang]][[key]]
  if (is.null(txt)) {
    # Fallback to English if key missing in chosen language
    txt <- .translations[["en"]][[key]]
  }
  if (is.null(txt)) return(paste0("[missing: ", key, "]"))
  if (...length() > 0) sprintf(txt, ...) else txt
}
