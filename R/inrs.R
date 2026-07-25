#' Daily handled quantity class (INRS method)
#'
#' Classifies the daily quantity of substance handled into one of the 5
#' classes of the INRS method, according to its unit.
#'
#' @param value Numeric. Daily quantity handled.
#' @param unit Character. One of `"g"`, `"ml"`, `"kg"`, `"l"`.
#'
#' @return Character scalar (`"1"` to `"5"`), or `NA_character_` if
#'   `value` is `NA`.
#'
#' @examples
#' inrs_quantity_class(50, "g")
#' inrs_quantity_class(500, "kg")
#'
#' @export
inrs_quantity_class <- function(value, unit = c("g", "ml", "kg", "l")) {
  unit <- match.arg(unit)
  if (is.na(value)) return(NA_character_)

  if (unit %in% c("g", "ml")) {
    if (value < 100) "1" else if (value < 10000) "2" else "3"
  } else {
    if (value < 10) "2" else if (value < 100) "3" else if (value < 1000) "4" else "5"
  }
}

#' Frequency of use class (INRS method)
#'
#' Converts the given frequency of use to the reference units of Table 3
#' of the INRS method (hours/day or days/month or days/year, depending on
#' the input unit) and returns the corresponding class (0 to 4).
#'
#' @param value Numeric. Frequency value. Ignored if `unit = "not_used"`.
#' @param unit Character. One of `"minutes"`, `"hours"`, `"days"`,
#'   `"months"`, `"not_used"` (the latter for substances that are not used
#'   with a periodic frequency, and always returns class `"0"`).
#'
#' @return Character scalar (`"0"` to `"4"`), or `NA_character_` if there
#'   is no match in the reference table.
#'
#' @examples
#' inrs_frequency_class(3, "hours")
#' inrs_frequency_class(unit = "not_used")
#'
#' @export
inrs_frequency_class <- function(value = NA_real_,
                                   unit = c("minutes", "hours", "days", "months", "not_used")) {
  unit <- match.arg(unit)
  if (unit == "not_used") return("0")
  if (is.na(value)) return(NA_character_)

  conv <- switch(unit,
    minutes = list(value = value / 60, unit_cmp = "hours", period = "Day"),
    hours   = list(value = value,      unit_cmp = "hours", period = "Day"),
    days    = list(value = value,      unit_cmp = "days",  period = "Month"),
    months  = list(value = value * 30, unit_cmp = "days",  period = "Year")
  )

  table <- inrs_frequency_table
  row <- table[
    table$unit == conv$unit_cmp &
      table$period == conv$period &
      conv$value >= table$from &
      conv$value <= table$to,
    "class",
    drop = TRUE
  ]

  if (length(row) == 0) NA_character_ else row[1]
}

#' Hazard class of a substance (INRS method)
#'
#' Determines the hazard class (1 to 5) of a substance from its R phrases,
#' its H phrases, its VLA, or the material/process it belongs to, by
#' consulting Table 1 of the INRS method. It is explored from the most
#' hazardous class (5) down to the least hazardous (1), and the first
#' class with a match is returned. If no phrase, VLA or process matches
#' classes 2 to 5, class 1 is assigned by default (catch-all: "has
#' phrases but none of the above"), as established by the INRS
#' methodology.
#'
#' @param r_phrases Character vector of R phrases (optional).
#' @param h_phrases Character vector of H phrases (optional).
#' @param process Character scalar with the material/process (optional).
#'   Compared as a substring (case-insensitive) against the text of
#'   Table 1.
#' @param vla Numeric. VLA in mg/m3 (optional).
#'
#' @return Character scalar (`"1"` to `"5"`). Only returns
#'   `NA_character_` if no criterion at all was supplied (`r_phrases`,
#'   `h_phrases`, `process` and `vla` all empty/`NA`), in which case there
#'   is not enough information to classify.
#'
#' @examples
#' inrs_hazard_class(h_phrases = "H335")
#' inrs_hazard_class(vla = 0.05)
#' inrs_hazard_class(vla = 200) # falls into class 1 by default
#'
#' @export
inrs_hazard_class <- function(r_phrases = character(0),
                                h_phrases = character(0),
                                process = NULL,
                                vla = NA_real_) {
  r_phrases <- toupper(trimws(r_phrases))
  h_phrases <- toupper(trimws(h_phrases))
  process_norm <- if (!is.null(process) && nzchar(trimws(process))) {
    tolower(trimws(process))
  } else {
    NULL
  }

  no_criteria <- length(r_phrases) == 0 && length(h_phrases) == 0 &&
    is.null(process_norm) && is.na(vla)
  if (no_criteria) return(NA_character_)

  table <- inrs_hazard_table

  for (j in 5:2) {
    row <- table[table$hazard_class == as.character(j), ]
    r_list <- toupper(trimws(strsplit(row$r_phrases, ",")[[1]]))
    h_list <- toupper(trimws(strsplit(row$h_phrases, ",")[[1]]))
    process_class <- tolower(row$process_materials)

    match_r <- length(r_phrases) > 0 && any(r_phrases %in% r_list)
    match_h <- length(h_phrases) > 0 && any(h_phrases %in% h_list)
    match_process <- !is.null(process_norm) && grepl(process_norm, process_class, fixed = TRUE)
    match_vla <- if (!is.na(vla)) {
      switch(as.character(j),
        "5" = vla <= 0.1,
        "4" = vla > 0.1 & vla <= 1,
        "3" = vla > 1   & vla <= 10,
        "2" = vla > 10  & vla <= 100
      )
    } else {
      FALSE
    }

    if (match_r || match_h || match_process || match_vla) {
      return(as.character(j))
    }
  }

  # No match in classes 2-5: class 1 by default (catch-all)
  "1"
}

#' Potential exposure class (INRS method)
#'
#' Consults Table 4 of the INRS method (quantity class x frequency class)
#' to obtain the potential exposure class.
#'
#' @param quantity_class Character. See [inrs_quantity_class()].
#' @param frequency_class Character. See [inrs_frequency_class()].
#'
#' @return Character scalar (`"0"` to `"5"`), or `NA_character_` if the
#'   combination is not defined.
#'
#' @examples
#' inrs_potential_exposure_class("3", "2")
#'
#' @export
inrs_potential_exposure_class <- function(quantity_class, frequency_class) {
  if (is.na(quantity_class) || is.na(frequency_class)) return(NA_character_)

  table <- inrs_potential_exposure_table
  row <- table[
    table$quantity_class == quantity_class & table$frequency_class == frequency_class,
    "exposure_class",
    drop = TRUE
  ]

  if (length(row) == 0) NA_character_ else row[1]
}

#' Potential risk class (INRS method)
#'
#' Consults Table 5 of the INRS method (potential exposure class x hazard
#' class) to obtain the potential risk class.
#'
#' @param potential_exposure_class Character. See
#'   [inrs_potential_exposure_class()].
#' @param hazard_class Character. See [inrs_hazard_class()].
#'
#' @return Character scalar (`"1"` to `"5"`), or `NA_character_` if the
#'   combination is not defined.
#'
#' @examples
#' inrs_potential_risk_class("4", "3")
#'
#' @export
inrs_potential_risk_class <- function(potential_exposure_class, hazard_class) {
  if (is.na(potential_exposure_class) || is.na(hazard_class)) return(NA_character_)

  table <- inrs_potential_risk_table
  row <- table[
    table$exposure_class == potential_exposure_class & table$hazard_class == hazard_class,
    "risk_class",
    drop = TRUE
  ]

  if (length(row) == 0) NA_character_ else row[1]
}

#' Potential risk score (INRS method)
#'
#' @param potential_risk_class Character. See [inrs_potential_risk_class()].
#'
#' @return Numeric (1, 10, 100, 1000 or 10000), or `NA_real_`.
#'
#' @examples
#' inrs_potential_risk_score("3")
#'
#' @export
inrs_potential_risk_score <- function(potential_risk_class) {
  if (is.na(potential_risk_class)) return(NA_real_)

  table <- inrs_risk_score_table
  row <- table[table$risk_class == potential_risk_class, "score", drop = TRUE]

  if (length(row) == 0) NA_real_ else as.numeric(row[1])
}

#' Volatility class of a liquid from use temperature and boiling point
#'
#' Classifies the volatility of a liquid by comparing its boiling point
#' with the two class-separating lines of the INRS method graph
#' (Figure 2, use temperature on the X axis, boiling point on the Y
#' axis).
#'
#' @param use_temperature Numeric. Use (process) temperature, in degrees
#'   Celsius. Corresponds to the X axis of the graph.
#' @param boiling_point Numeric. Boiling point, in degrees Celsius.
#'   Corresponds to the Y axis of the graph.
#'
#' @return Character scalar (`"1"` low, `"2"` medium, `"3"` high).
#'
#' @examples
#' inrs_liquid_volatility_graph(use_temperature = 20, boiling_point = 200)
#' inrs_liquid_volatility_graph(use_temperature = 20, boiling_point = 80)
#'
#' @export
inrs_liquid_volatility_graph <- function(use_temperature, boiling_point) {
  if (is.na(use_temperature) || is.na(boiling_point)) {
    return(NA_character_)
  }
  # Class-separating lines of the official INRS graph (Figure 2):
  # line1 separates class 1 (low) from class 2 (medium): through (0,70) and (150,240)
  # line2 separates class 2 (medium) from class 3 (high): through (0,135) and (125,300)
  line1 <- 70 + (240 - 70) / 150 * use_temperature
  line2 <- 135 + (300 - 135) / 125 * use_temperature

  if (boiling_point > line2) {
    "1"
  } else if (boiling_point > line1) {
    "2"
  } else {
    "3"
  }
}

#' Volatility class of a liquid from vapour pressure
#'
#' Classifies the volatility of a liquid according to the official
#' thresholds of Table 8 of the INRS method.
#'
#' @param vapour_pressure Numeric. Vapour pressure at working
#'   temperature, in kPa.
#'
#' @return Character scalar (`"1"` if Pv < 0.5 kPa, `"2"` if
#'   0.5 <= Pv < 25 kPa, `"3"` if Pv >= 25 kPa).
#'
#' @examples
#' inrs_liquid_volatility_pressure(15)
#'
#' @export
inrs_liquid_volatility_pressure <- function(vapour_pressure) {
  if (is.na(vapour_pressure)) return(NA_character_)
  if (vapour_pressure < 0.5) "1" else if (vapour_pressure < 25) "2" else "3"
}

#' Dustiness class of a solid (INRS method)
#'
#' @param description Character. One of `"Dust that generates a lot of
#'   visible dispersion in the air"`, `"Fine dust with little visible
#'   dispersion"` or `"Compact solid with no visible dust"`.
#'
#' @return Character scalar (`"1"` to `"3"`), or `NA_character_` if
#'   `description` does not match any valid option.
#'
#' @examples
#' inrs_solid_dustiness("Fine dust with little visible dispersion")
#'
#' @export
inrs_solid_dustiness <- function(description) {
  switch(description,
    "Dust that generates a lot of visible dispersion in the air" = "3",
    "Fine dust with little visible dispersion" = "2",
    "Compact solid with no visible dust" = "1",
    NA_character_
  )
}

#' Volatility or dustiness score (INRS method)
#'
#' @param volatility_class Character. `"1"`, `"2"` or `"3"`, as returned
#'   by [inrs_liquid_volatility_graph()], [inrs_liquid_volatility_pressure()]
#'   or [inrs_solid_dustiness()].
#'
#' @return Numeric (1, 10 or 100), or `NA_real_`.
#'
#' @examples
#' inrs_volatility_score("2")
#'
#' @export
inrs_volatility_score <- function(volatility_class) {
  if (is.na(volatility_class)) return(NA_real_)
  switch(volatility_class,
    "1" = 1, "2" = 10, "3" = 100,
    NA_real_
  )
}

#' Process class and score (INRS method)
#'
#' @param type Character. One of `"Dispersive"`, `"Open"`,
#'   `"Closed/opened regularly"`, `"Permanently closed"`.
#'
#' @return A one-row `data.frame` with columns `class` and `score`.
#'
#' @examples
#' inrs_process_type("Open")
#'
#' @export
inrs_process_type <- function(type) {
  table <- inrs_process_table
  row <- table[table$type == type, c("class", "score")]
  if (nrow(row) == 0) {
    data.frame(class = NA_character_, score = NA_real_)
  } else {
    row[1, ]
  }
}

#' Collective protection class and score (INRS method)
#'
#' @param situation Character. One of the situations of INRS Figure 4,
#'   e.g. `"Enclosing hood / full enclosure"`.
#'
#' @return A one-row `data.frame` with columns `class` and `score`.
#'
#' @examples
#' inrs_collective_protection("Enclosing hood / full enclosure")
#'
#' @export
inrs_collective_protection <- function(situation) {
  table <- inrs_protection_table
  row <- table[table$situation == situation, c("class", "score")]
  if (nrow(row) == 0) {
    data.frame(class = NA_character_, score = NA_real_)
  } else {
    row[1, ]
  }
}

#' VLA correction factor (INRS method)
#'
#' @param vla Numeric. VLA in mg/m3.
#'
#' @return Numeric (1, 10, 30 or 100), or `NA_real_` if `vla` is `NA`.
#'
#' @examples
#' inrs_oel_correction_factor(0.05)
#'
#' @export
inrs_oel_correction_factor <- function(vla) {
  if (is.na(vla)) return(NA_real_)
  if (vla > 0.1) 1
  else if (vla <= 0.1 && vla > 0.01) 10
  else if (vla <= 0.01 && vla > 0.001) 30
  else 100
}

#' Final inhalation risk score (INRS method)
#'
#' Product of the five partial scores of the INRS method.
#'
#' @param potential_risk_score Numeric. See [inrs_potential_risk_score()].
#' @param volatility_score Numeric. See [inrs_volatility_score()].
#' @param procedure_score Numeric. See [inrs_process_type()].
#' @param protection_score Numeric. See [inrs_collective_protection()].
#' @param vla_correction_factor Numeric. See [inrs_oel_correction_factor()].
#'
#' @return Numeric, or `NA_real_` if any component is missing.
#'
#' @examples
#' inrs_inhalation_risk(100, 10, 0.5, 0.7, 10)
#'
#' @export
inrs_inhalation_risk <- function(potential_risk_score,
                                    volatility_score,
                                    procedure_score,
                                    protection_score,
                                    vla_correction_factor) {
  components <- c(
    potential_risk_score, volatility_score,
    procedure_score, protection_score, vla_correction_factor
  )
  if (anyNA(components)) return(NA_real_)
  Reduce(`*`, components)
}

#' Inhalation risk characterisation (INRS method)
#'
#' @param inhalation_risk Numeric. See [inrs_inhalation_risk()].
#'
#' @return Character scalar describing the action priority, or
#'   `NA_character_` if `inhalation_risk` is `NA`.
#'
#' @examples
#' inrs_risk_characterisation(2500)
#'
#' @export
inrs_risk_characterisation <- function(inhalation_risk) {
  if (is.na(inhalation_risk)) return(NA_character_)
  if (inhalation_risk > 1000) {
    .t("inrs_char_3")
  } else if (inhalation_risk > 100) {
    .t("inrs_char_2")
  } else {
    .t("inrs_char_1")
  }
}

#' Evaluate a chemical product with the INRS method (high-level wrapper)
#'
#' Chains all the steps of the INRS method (hazard class, quantity,
#' frequency, potential exposure, potential risk, volatility or
#' dustiness, process and collective protection) from the raw data of a
#' product, and returns a complete result row. Designed to be used
#' directly from code, without going through the Shiny application.
#'
#' @param name Character. Name of the product.
#' @param r_phrases,h_phrases Character vectors. See [inrs_hazard_class()].
#' @param process Character. See [inrs_hazard_class()].
#' @param vla Numeric. VLA in mg/m3.
#' @param quantity_value,quantity_unit See [inrs_quantity_class()].
#' @param frequency_value,frequency_unit See [inrs_frequency_class()].
#' @param substance_type Character. `"liquid"` or `"solid"`.
#' @param liquid_method Character. `"graph"` or `"pressure"`. Only used
#'   if `substance_type = "liquid"`.
#' @param use_temperature,boiling_point Numeric. Only if
#'   `liquid_method = "graph"`.
#' @param vapour_pressure Numeric. Only if `liquid_method = "pressure"`.
#' @param solid_description Character. Only if `substance_type = "solid"`.
#'   See [inrs_solid_dustiness()].
#' @param procedure Character. See [inrs_process_type()].
#' @param protection Character. See [inrs_collective_protection()].
#'
#' @return A one-row `data.frame` with all the intermediate classes and
#'   scores, the final inhalation risk score and its characterisation.
#'
#' @examples
#' inrs_evaluate(
#'   name = "Solvent X",
#'   h_phrases = "H336",
#'   vla = 50,
#'   quantity_value = 5, quantity_unit = "l",
#'   frequency_value = 3, frequency_unit = "hours",
#'   substance_type = "liquid",
#'   liquid_method = "graph",
#'   use_temperature = 40, boiling_point = 80,
#'   procedure = "Open",
#'   protection = "Moderate dispersion conditions"
#' )
#'
#' @export
inrs_evaluate <- function(name,
                          r_phrases = character(0),
                          h_phrases = character(0),
                          process = NULL,
                          vla = NA_real_,
                          quantity_value = NA_real_,
                          quantity_unit = c("g", "ml", "kg", "l"),
                          frequency_value = NA_real_,
                          frequency_unit = c("minutes", "hours", "days", "months", "not_used"),
                          substance_type = c("liquid", "solid"),
                          liquid_method = c("graph", "pressure"),
                          use_temperature = NA_real_,
                          boiling_point = NA_real_,
                          vapour_pressure = NA_real_,
                          solid_description = NA_character_,
                          procedure,
                          protection) {
  quantity_unit <- match.arg(quantity_unit)
  frequency_unit <- match.arg(frequency_unit)
  substance_type <- match.arg(substance_type)
  liquid_method <- match.arg(liquid_method)

  hazard_class <- inrs_hazard_class(r_phrases, h_phrases, process, vla)
  quantity_class <- inrs_quantity_class(quantity_value, quantity_unit)
  frequency_class <- inrs_frequency_class(frequency_value, frequency_unit)
  potential_exposure_class <- inrs_potential_exposure_class(quantity_class, frequency_class)
  potential_risk_class <- inrs_potential_risk_class(potential_exposure_class, hazard_class)
  potential_risk_score <- inrs_potential_risk_score(potential_risk_class)

  volatility_class <- if (substance_type == "liquid") {
    if (liquid_method == "graph") {
      inrs_liquid_volatility_graph(use_temperature, boiling_point)
    } else {
      inrs_liquid_volatility_pressure(vapour_pressure)
    }
  } else {
    inrs_solid_dustiness(solid_description)
  }
  volatility_score <- inrs_volatility_score(volatility_class)

  proc <- inrs_process_type(procedure)
  prot <- inrs_collective_protection(protection)
  vla_correction_factor <- inrs_oel_correction_factor(vla)

  risk <- inrs_inhalation_risk(
    potential_risk_score, volatility_score, proc$score, prot$score, vla_correction_factor
  )
  characterisation <- inrs_risk_characterisation(risk)

  data.frame(
    product = name,
    hazard_class = hazard_class,
    quantity_class = quantity_class,
    frequency_class = frequency_class,
    potential_exposure_class = potential_exposure_class,
    potential_risk_class = potential_risk_class,
    potential_risk_score = potential_risk_score,
    volatility_dustiness_class = volatility_class,
    volatility_dustiness_score = volatility_score,
    procedure_class = proc$class,
    procedure_score = proc$score,
    protection_class = prot$class,
    protection_score = prot$score,
    vla_correction_factor = vla_correction_factor,
    inhalation_risk = risk,
    risk_characterisation = characterisation,
    stringsAsFactors = FALSE
  )
}
