#' Classify the volatility of a liquid using the COSHH Essentials method
#'
#' Compares the boiling point of a substance with its process temperature
#' to assign a volatility class (`"Low"` / `"Medium"` / `"High"` in English,
#' `"Baja"` / `"Media"` / `"Alta"` in Spanish), following the thresholds of
#' the COSHH Essentials method.
#'
#' The active language is controlled by [expoquimr_lang()].
#'
#' @param boiling_point Numeric. Boiling point of the substance, in degrees
#'   Celsius.
#' @param process_temp Numeric. Temperature at which the substance is
#'   handled, in degrees Celsius.
#'
#' @return Character scalar: volatility class in the active language.
#'
#' @examples
#' coshh_classify_volatility(boiling_point = 111, process_temp = 20)
#' expoquimr_lang("es")
#' coshh_classify_volatility(boiling_point = 111, process_temp = 20)
#' expoquimr_lang("en")
#'
#' @export
coshh_classify_volatility <- function(boiling_point, process_temp) {
  stopifnot(is.numeric(boiling_point), is.numeric(process_temp))
  if (anyNA(boiling_point) || anyNA(process_temp)) {
    stop("boiling_point and process_temp must not be NA.", call. = FALSE)
  }
  ifelse(
    boiling_point > 5 * process_temp + 50, .t("coshh_vol_low"),
    ifelse(boiling_point > 2 * process_temp + 10, .t("coshh_vol_medium"),
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
#' @param phrases Character scalar containing one or more phrases separated
#'   by commas, e.g. `"H315, H319"` or `"R20/21/22"`.
#'
#' @return Character scalar with the group (`"A"` to `"E"`), or
#'   `NA_character_` if `phrases` is empty or `NA`.
#'
#' @examples
#' coshh_grade("H315, H319")
#' coshh_grade("R23/24/25")
#'
#' @export
coshh_grade <- function(phrases) {
  if (is.null(phrases) || is.na(phrases) || !nzchar(trimws(phrases))) {
    return(NA_character_)
  }

  tokens <- trimws(toupper(strsplit(phrases, ",")[[1]]))
  tokens <- tokens[nzchar(tokens)]
  if (length(tokens) == 0) return(NA_character_)

  table <- coshh_grade_table
  order <- c("A", "B", "C", "D", "E")

  grade_for_token <- function(token) {
    for (i in seq_len(nrow(table))) {
      r_list <- trimws(toupper(strsplit(table$r_phrases[i], ",")[[1]]))
      h_list <- trimws(toupper(strsplit(table$h_phrases[i], ",")[[1]]))
      if (token %in% r_list || token %in% h_list) {
        return(table$grade[i])
      }
    }
    "A"
  }

  grades <- vapply(tokens, grade_for_token, character(1))
  order[max(match(grades, order))]
}

#' Calculate the COSHH risk level
#'
#' Queries the hazard x quantity x volatility matrix of the COSHH Essentials
#' method to obtain the potential risk level (1 to 4). Substances of grade
#' `"E"` (carcinogenic, mutagenic or similar) always receive the maximum
#' level, regardless of quantity or volatility.
#'
#' @param grade Character. Hazard group (`"A"` to `"E"`), as returned by
#'   [coshh_grade()].
#' @param quantity Character. Quantity class in the active language. Use
#'   `"Small"` / `"Medium"` / `"Large"` (English) or `"Pequeña"` /
#'   `"Mediana"` / `"Grande"` (Spanish).
#' @param volatility Character. Volatility class in the active language.
#'   Use `"Low"` / `"Medium"` / `"High"` (English) or `"Baja"` / `"Media"`
#'   / `"Alta"` (Spanish). For solids, this corresponds to dustiness.
#'
#' @return Integer with the risk level (1 to 4), or `NA_integer_` if the
#'   combination is not defined in the table or `grade` is `NA`.
#'
#' @examples
#' coshh_risk(grade = "C", quantity = "Medium", volatility = "High")
#' coshh_risk(grade = "E", quantity = "Small",  volatility = "Low")
#'
#' @export
coshh_risk <- function(grade, quantity, volatility) {
  if (is.na(grade)) return(NA_integer_)
  if (grade == "E") return(4L)

  # Normalise quantity and volatility to English (internal table keys)
  quantity_en <- switch(quantity,
    "Peque\u00f1a" = "Small", "Mediana" = "Medium", "Grande" = "Large",
    quantity  # already English
  )
  volatility_en <- switch(volatility,
    "Baja" = "Low", "Media" = "Medium", "Alta" = "High",
    volatility  # already English
  )

  result <- coshh_risk_table[
    coshh_risk_table$hazard    == grade &
      coshh_risk_table$quantity   == quantity_en &
      coshh_risk_table$volatility == volatility_en,
    "risk", drop = TRUE
  ]

  if (length(result) == 0) NA_integer_ else as.integer(result[1])
}

#' Get the recommended control measures for a COSHH risk level
#'
#' @param risk_level Integer or character. Risk level (1 to 4), as returned
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
coshh_measures <- function(risk_level) {
  if (is.na(risk_level)) return(NA_character_)
  switch(as.character(risk_level),
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
#' @param name Character. Identifying name of the substance.
#' @param phrases Character. H/R phrases; see [coshh_grade()].
#' @param quantity Character. Quantity class in the active language.
#' @param is_liquid Logical. `TRUE` if the substance is liquid (volatility
#'   will be calculated from `boiling_point` / `process_temp`); `FALSE` if
#'   solid (`dustiness` will be used directly).
#' @param boiling_point,process_temp Numeric. Required only if
#'   `is_liquid = TRUE`. See [coshh_classify_volatility()].
#' @param dustiness Character. Required only if `is_liquid = FALSE`.
#'   Dustiness class in the active language.
#'
#' @return A one-row `data.frame` with columns `substance`, `phrases`,
#'   `grade`, `volatility`, `quantity`, `risk` and `measures`.
#'
#' @examples
#' coshh_evaluate(
#'   name = "Toluene",
#'   phrases = "H315, H336",
#'   quantity = "Medium",
#'   is_liquid = TRUE,
#'   boiling_point = 111,
#'   process_temp = 20
#' )
#'
#' @export
coshh_evaluate <- function(name,
                           phrases,
                           quantity,
                           is_liquid,
                           boiling_point = NA_real_,
                           process_temp  = NA_real_,
                           dustiness     = NA_character_) {
  grade <- coshh_grade(phrases)

  volatility <- if (isTRUE(is_liquid)) {
    coshh_classify_volatility(boiling_point, process_temp)
  } else {
    dustiness
  }

  risk     <- coshh_risk(grade, quantity, volatility)
  measures <- coshh_measures(risk)

  data.frame(
    substance  = name,
    phrases    = phrases,
    grade      = grade,
    volatility = volatility,
    quantity   = quantity,
    risk       = risk,
    measures   = measures,
    stringsAsFactors = FALSE
  )
}
