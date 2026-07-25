# UT table (one-sided 95%/70% tolerance factor) per UNE-EN 689, for
# sample sizes n = 6 to 30. For n > 30 the limit value 1.820 is used.
# Internal object, not exported (does not need to go through sysdata
# because it does not depend on external data; it is a constant of the
# method).
une689_ut_table <- c(
  `6` = 2.187, `7` = 2.120, `8` = 2.072, `9` = 2.035, `10` = 2.005,
  `11` = 1.981, `12` = 1.961, `13` = 1.944, `14` = 1.929, `15` = 1.917,
  `16` = 1.905, `17` = 1.895, `18` = 1.886, `19` = 1.878, `20` = 1.870,
  `21` = 1.863, `22` = 1.857, `23` = 1.851, `24` = 1.846, `25` = 1.841,
  `26` = 1.836, `27` = 1.832, `28` = 1.828, `29` = 1.824, `30` = 1.820
)

#' UNE-EN 689 UT factor from the sample size
#'
#' Looks up the one-sided tolerance factor (UT) tabulated by UNE-EN 689
#' for a number of days `n` between 6 and 30. For `n > 30` the limit
#' value 1.820 is used, as established by the standard.
#'
#' @param n Integer. Number of days (ED measurements) used in the
#'   statistical assessment. Must be `>= 6`.
#'
#' @return Numeric scalar with the UT value, or `NA_real_` if `n < 6`.
#'
#' @examples
#' une689_ut(6)
#' une689_ut(50)
#'
#' @export
une689_ut <- function(n) {
  if (is.na(n) || n < 6) return(NA_real_)
  if (n > 30) return(1.820)
  unname(une689_ut_table[as.character(round(n))])
}

#' Descriptive statistics of daily exposure (UNE-EN 689)
#'
#' Calculates the arithmetic mean and standard deviation (MA, DS) and the
#' geometric mean and standard deviation (MG, DSG) of a set of daily
#' exposure (ED) values, needed to test the normal and lognormal fits.
#'
#' @param ed Numeric vector. Daily exposure (ED) values, all strictly
#'   positive.
#'
#' @return A list with elements `MA`, `DS`, `MG`, `DSG`.
#'
#' @examples
#' une689_statistics(c(5, 6, 7, 8, 9, 10))
#'
#' @export
une689_statistics <- function(ed) {
  if (any(is.na(ed)) || any(ed <= 0)) {
    stop(.t("ed_positive"), call. = FALSE)
  }
  log_ed <- log(ed)
  list(
    MA = mean(ed),
    DS = stats::sd(ed),
    MG = exp(mean(log_ed)),
    DSG = exp(stats::sd(log_ed))
  )
}

#' Normality and lognormality tests (UNE-EN 689)
#'
#' Applies the Shapiro-Wilk test to the ED values (to test normality) and
#' to their logarithm (to test lognormality).
#'
#' @param ed Numeric vector. Daily exposure (ED) values, all strictly
#'   positive. At least 3 values are required (minimum required by
#'   [stats::shapiro.test()]); UNE-EN 689 additionally requires a minimum
#'   of 6 for the full statistical assessment.
#'
#' @return A list with elements `W_normal`, `pval_normal`, `W_lognormal`,
#'   `pval_lognormal`.
#'
#' @examples
#' une689_normality_test(c(5, 6, 7, 8, 9, 10))
#'
#' @export
une689_normality_test <- function(ed) {
  test_normal <- stats::shapiro.test(ed)
  test_lognormal <- stats::shapiro.test(log(ed))

  list(
    W_normal = unname(test_normal$statistic),
    pval_normal = test_normal$p.value,
    W_lognormal = unname(test_lognormal$statistic),
    pval_lognormal = test_lognormal$p.value
  )
}

#' Determine the distribution type (UNE-EN 689)
#'
#' Decides whether the data best fits a lognormal, normal, or neither
#' distribution, from the Shapiro-Wilk p-values. Priority is given to the
#' lognormal fit, following common practice in industrial hygiene
#' (exposure is usually lognormal).
#'
#' @param pval_normal Numeric. p-value of the normality test on ED.
#' @param pval_lognormal Numeric. p-value of the normality test on
#'   log(ED).
#' @param alpha Numeric. Significance level (default 0.05).
#'
#' @return Character scalar: one of `"Lognormal"`, `"Normal"` or
#'   `"Neither"` (in English, the default), or the equivalent Spanish
#'   labels when `expoquimr_lang("es")` is active.
#'
#' @examples
#' une689_distribution_type(pval_normal = 0.03, pval_lognormal = 0.20)
#'
#' @export
une689_distribution_type <- function(pval_normal, pval_lognormal, alpha = 0.05) {
  if (pval_lognormal > alpha) {
    .t("une689_lognormal")
  } else if (pval_normal > alpha) {
    .t("une689_normal")
  } else {
    .t("une689_neither")
  }
}

#' Upper confidence limit LSC(95,70) (UNE-EN 689)
#'
#' @param distribution_type Character. Distribution type as returned by
#'   [une689_distribution_type()]. Accepts both English (`"Lognormal"`,
#'   `"Normal"`, `"Neither"`) and Spanish labels.
#' @param ut Numeric. UT factor, see [une689_ut()].
#' @param MA,DS Numeric. Arithmetic mean and standard deviation (only
#'   needed when `distribution_type = "Normal"`); see [une689_statistics()].
#' @param MG,DSG Numeric. Geometric mean and standard deviation (only
#'   needed when `distribution_type = "Lognormal"`); see
#'   [une689_statistics()].
#'
#' @return Numeric scalar with the LSC(95,70), or `NA_real_` if
#'   `distribution_type = "Neither"` (or `"Ninguna"` in Spanish).
#'
#' @examples
#' une689_lsc("Normal", ut = 2.005, MA = 7.5, DS = 1.87)
#'
#' @export
une689_lsc <- function(distribution_type, ut, MA = NA_real_, DS = NA_real_, MG = NA_real_, DSG = NA_real_) {
  # distribution_type uses internal English keys: "Lognormal", "Normal", "Neither"
  if (identical(distribution_type, .t("une689_lognormal")) || identical(distribution_type, "Lognormal")) {
    MG * DSG^ut
  } else if (identical(distribution_type, .t("une689_normal")) || identical(distribution_type, "Normal")) {
    MA + ut * DS
  } else {
    NA_real_
  }
}

#' One-sided risk index UR (UNE-EN 689)
#'
#' @param distribution_type Character. Distribution type; see [une689_lsc()].
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#' @param MA,DS,MG,DSG Numeric. See [une689_lsc()].
#'
#' @return Numeric scalar, or `NA_real_` if `distribution_type = "Neither"`.
#'
#' @examples
#' une689_ur("Normal", vla = 10, MA = 7.5, DS = 1.87)
#'
#' @export
une689_ur <- function(distribution_type, vla, MA = NA_real_, DS = NA_real_, MG = NA_real_, DSG = NA_real_) {
  # distribution_type uses internal English keys: "Lognormal", "Normal", "Neither"
  if (identical(distribution_type, .t("une689_lognormal")) || identical(distribution_type, "Lognormal")) {
    (log(vla) - log(MG)) / log(DSG)
  } else if (identical(distribution_type, .t("une689_normal")) || identical(distribution_type, "Normal")) {
    (vla - MA) / DS
  } else {
    NA_real_
  }
}

#' Conformity of the statistical assessment (UNE-EN 689)
#'
#' @param ur Numeric. One-sided risk index, see [une689_ur()].
#' @param ut Numeric. UT factor, see [une689_ut()].
#'
#' @return Character scalar: `"CONFORMITY"` if `ur >= ut`,
#'   `"NON-CONFORMITY"` if `ur < ut`, or `NA_character_` if `ur` is `NA`
#'   (e.g. when neither the normal nor the lognormal fit is adequate).
#'   Labels are returned in the active language; see [expoquimr_lang()].
#'
#' @examples
#' une689_statistical_conformity(ur = 2.1, ut = 2.005)
#'
#' @export
une689_statistical_conformity <- function(ur, ut) {
  if (is.na(ur)) return(NA_character_)
  if (ur >= ut) .t("une689_conformity") else .t("une689_no_conformity")
}

#' Complete UNE-EN 689 statistical assessment (high-level wrapper)
#'
#' Chains the distribution fit, the calculation of UT, LSC(95,70), UR and
#' the statistical conformity from a set of daily exposure (ED) values.
#' Designed to be used directly from code, without going through the
#' Shiny application.
#'
#' @param ed Numeric vector. ED values (one per day), all positive. A
#'   minimum of 6 is required (see [une689_validate_min_days()]).
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#'
#' @return A list with elements `n`, `distribution_type`, `MA`, `DS`,
#'   `MG`, `DSG`, `W_normal`, `pval_normal`, `W_lognormal`,
#'   `pval_lognormal`, `ut`, `lsc`, `ur`, `conformity`.
#'
#' @examples
#' une689_evaluate_statistical(c(5, 6, 7, 8, 9, 10), vla = 10)
#'
#' @export
une689_evaluate_statistical <- function(ed, vla) {
  n <- length(ed)
  if (!une689_validate_min_days(n, minimum = 6L)) {
    stop(.t("min_jornadas", 6L, n), call. = FALSE)
  }

  stats_ed <- une689_statistics(ed)
  test <- une689_normality_test(ed)
  distribution_type <- une689_distribution_type(test$pval_normal, test$pval_lognormal)
  ut <- une689_ut(n)
  lsc <- une689_lsc(distribution_type, ut, MA = stats_ed$MA, DS = stats_ed$DS, MG = stats_ed$MG, DSG = stats_ed$DSG)
  ur <- une689_ur(distribution_type, vla, MA = stats_ed$MA, DS = stats_ed$DS, MG = stats_ed$MG, DSG = stats_ed$DSG)
  conformity <- une689_statistical_conformity(ur, ut)

  list(
    n = n,
    distribution_type = distribution_type,
    MA = stats_ed$MA, DS = stats_ed$DS, MG = stats_ed$MG, DSG = stats_ed$DSG,
    W_normal = test$W_normal, pval_normal = test$pval_normal,
    W_lognormal = test$W_lognormal, pval_lognormal = test$pval_lognormal,
    ut = ut, lsc = lsc, ur = ur, conformity = conformity
  )
}

#' Recommended monitoring interval, option 1 (MG or MA vs VLA)
#'
#' @param reference_value Numeric. MG if the distribution is lognormal,
#'   or MA if normal (see [une689_statistics()]).
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#'
#' @return Character scalar describing the recommended monitoring
#'   interval, in months.
#'
#' @examples
#' une689_monitoring_interval_opt1(reference_value = 0.8, vla = 10)
#'
#' @export
une689_monitoring_interval_opt1 <- function(reference_value, vla) {
  if (is.na(reference_value) || is.na(vla)) {
    return(NA_character_)
  }
  if (reference_value < 0.1 * vla) {
    .t("une689_period_36")
  } else if (reference_value < 0.25 * vla) {
    .t("une689_period_24")
  } else if (reference_value < 0.5 * vla) {
    .t("une689_period_18")
  } else {
    .t("une689_period_12")
  }
}

#' Recommended monitoring interval, option 2 (LSC95,70 vs VLA)
#'
#' @param lsc Numeric. LSC(95,70), see [une689_lsc()].
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#'
#' @return Character scalar describing the recommended monitoring
#'   interval, in months, or a warning that exposure must be reviewed.
#'
#' @examples
#' une689_monitoring_interval_opt2(lsc = 4, vla = 10)
#'
#' @export
une689_monitoring_interval_opt2 <- function(lsc, vla) {
  if (is.na(lsc) || is.na(vla) || vla <= 0) {
    return(NA_character_)
  }
  j <- lsc / vla
  if (j < 0.25) {
    .t("une689_period_36")
  } else if (j < 0.5) {
    .t("une689_period_30")
  } else if (j < 1) {
    .t("une689_period_24")
  } else {
    .t("une689_period_review")
  }
}
