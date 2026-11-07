#' Daily exposure (ED) for a measurement day, per UNE-EN 689
#'
#' Calculates the daily exposure from the concentrations and times of the
#' valid samples of a measurement day. If there is a single valid sample
#' taken over the complete 8-hour working day, the ED is directly that
#' concentration. Otherwise, it is calculated as the time-weighted
#' average over an 8-hour day (`sum(concentration * time) / 8`).
#'
#' @param concentration Numeric vector. Measured concentrations (mg/m3),
#'   one per sample.
#' @param time Numeric vector. Time of each sample (hours), same length
#'   as `concentration`.
#'
#' @return Numeric scalar with the ED, or `NA_real_` if there is no valid
#'   (concentration, time) pair.
#'
#' @examples
#' une689_daily_exposure(concentration = c(12, 8), time = c(4, 4))
#' une689_daily_exposure(concentration = 9, time = 8)
#'
#' @export
une689_daily_exposure <- function(concentration, time) {
  stopifnot(length(concentration) == length(time))
  valid <- !is.na(concentration) & !is.na(time)
  conc <- concentration[valid]
  tm   <- time[valid]

  if (length(conc) == 0) return(NA_real_)
  if (
    length(conc) == 1 &&
    isTRUE(all.equal(tm[1], 8, tolerance = sqrt(.Machine$double.eps)))
  ) {
    return(conc[1])
  }

  sum(conc * tm) / 8
}

#' Exposure index (IE) for a measurement day, per UNE-EN 689
#'
#' @param ed Numeric. Daily exposure, see [une689_daily_exposure()].
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#'
#' @return Numeric scalar (`ed / vla`), or `NA_real_` if `ed` or `vla` are
#'   not valid (`vla` must be `> 0`).
#'
#' @examples
#' une689_exposure_index(ed = 9, vla = 10)
#'
#' @export
une689_exposure_index <- function(ed, vla) {
  if (is.na(ed) || is.na(vla) || vla <= 0) return(NA_real_)
  ed / vla
}

#' Classify the conformity of the UNE-EN 689 preliminary assessment
#'
#' From the exposure indices (IE) of all the days evaluated, determines
#' whether exposure is conforming, non-conforming, or whether no decision
#' can be made without further measurements, following the criteria of
#' the UNE-EN 689 preliminary assessment.
#'
#' @param ie Numeric vector. Exposure indices, one per day (see
#'   [une689_exposure_index()]). `NA` values (days without enough data)
#'   are ignored.
#'
#' @return Character scalar: `.t("une689_conformity")` if all IE values
#'   are below 0.1; `.t("une689_no_conformity")` if any IE is above 1;
#'   `.t("une689_no_decision")` if any IE is between 0.1 and 1 (both
#'   inclusive) and none exceeds 1. Returns `NA_character_` if there is
#'   no valid IE at all (not enough data to classify).
#'
#' @section Correction relative to the original app:
#' In the original Shiny app, if all days had IE = `NA` (due to missing
#' data), the check `all(IEs < 0.1, na.rm = TRUE)` returned `TRUE`
#' (because `all()` over an empty vector is `TRUE` in R), and the result
#' was incorrectly reported as **.t("une689_conformity")** with no actual
#' data. This function fixes that case by returning `NA_character_` (not
#' enough data) instead of a false conformity. This change is flagged
#' here because, unlike the INRS points, it was applied without prior
#' confirmation: reporting "conformity" with no data is a safety flaw,
#' not a methodological judgement call.
#'
#' @examples
#' une689_classify_conformity(c(0.02))
#' une689_classify_conformity(c(1, 0.9, 0.56))
#' une689_classify_conformity(c(1.2, 0.05))
#'
#' @export
une689_classify_conformity <- function(ie) {
  if (is.numeric(ie) && length(ie) > 0L && all(is.na(ie))) return(NA_character_)
  .assert_numeric_vector(ie, "ie", allow_na = FALSE, allow_empty = TRUE)
  if (length(ie) == 0L) return(NA_character_)
  if (any(ie < 0)) stop("`ie` must be non-negative.", call. = FALSE)
  # An exceedance has priority over a preliminary conformity decision.
  if (any(ie > 1)) return(.t("une689_no_conformity"))
  n <- length(ie)
  # For 3, 4, and 5 measurements the preliminary conformity
  # thresholds differ. For >=6 use the statistical assessment.
  limite <- switch(as.character(n),
                   "3" = 0.10, "4" = 0.15, "5" = 0.20, NA_real_)
  if (!is.na(limite) && all(ie < limite)) {
    return(.t("une689_conformity"))
  }
  .t("une689_no_decision")
}

#' Check the minimum number of days for the preliminary assessment
#'
#' The UNE-EN 689 preliminary assessment requires a minimum number of
#' evaluated days (usually 3). Helper function to validate this before
#' calculating, both from code and from the Shiny app.
#'
#' @param n_days Integer. Number of days with data entered.
#' @param minimum Integer. Minimum number required (default 3).
#'
#' @return Logical: `TRUE` if `n_days >= minimum`.
#'
#' @examples
#' une689_validate_min_days(2)
#' une689_validate_min_days(3)
#'
#' @export
une689_validate_min_days <- function(n_days, minimum = 3L) {
  .assert_numeric_scalar(n_days, "n_days")
  .assert_numeric_scalar(minimum, "minimum")
  if (n_days < 0 || n_days != floor(n_days) ||
      minimum < 1 || minimum != floor(minimum)) {
    stop("`n_days` and `minimum` must be valid integer counts.", call. = FALSE)
  }
  n_days >= minimum
}

#' Complete UNE-EN 689 preliminary assessment (high-level wrapper)
#'
#' Calculates the ED and IE for each day and classifies the overall
#' conformity, from a set of samples organised by measurement day.
#' Designed to be used directly from code, without going through the
#' Shiny application.
#'
#' @param data A `data.frame` in long format with columns `day`
#'   (day identifier, numeric or character), `concentration` (mg/m3)
#'   and `time` (hours). One row per sample.
#' @param vla Numeric. Valor Limite Ambiental / occupational exposure
#'   limit (mg/m3).
#'
#' @return A list with two elements:
#'   \describe{
#'     \item{`days_table`}{A `data.frame` with columns `day`, `ED` and
#'       `IE`, one row per day.}
#'     \item{`result`}{Character scalar with the overall classification,
#'       see [une689_classify_conformity()].}
#'   }
#'
#' @examples
#' data <- data.frame(
#'   day = c(1, 1, 2, 3, 3),
#'   concentration = c(12, 8, 9, 5, 6),
#'   time = c(4, 4, 8, 3, 5)
#' )
#' une689_evaluate_preliminary(data, vla = 10)
#'
#' @export
une689_evaluate_preliminary <- function(data, vla) {
  .assert_numeric_scalar(vla, "vla")
  if (vla <= 0) stop("`vla` must be strictly positive.", call. = FALSE)
  data <- .normalize_une689_preliminary_data(data)

  # Entirely blank slots do not constitute measurements or measurement days.
  data <- data[!is.na(data$concentration) & !is.na(data$time), , drop = FALSE]
  days <- sort(unique(data$day))
  if (length(days) < 3L) {
    stop("At least 3 measurement days with complete sample pairs are required.",
         call. = FALSE)
  }
  rows <- lapply(days, function(d) {
    subset_d <- data[data$day == d, ]
    ed <- une689_daily_exposure(subset_d$concentration, subset_d$time)
    ie <- une689_exposure_index(ed, vla)
    data.frame(day = d, ED = ed, IE = ie)
  })
  days_table <- do.call(rbind, rows)
  rownames(days_table) <- NULL

  result <- une689_classify_conformity(days_table$IE)

  list(days_table = days_table, result = result)
}

# ---- rOpenSci statistical standards ----
#' @srrstats {G2.0a} Function-level documentation explicitly states relevant input-length requirements, including equal-length concentration/time vectors and minimum ED sample sizes for UNE-EN 689 statistical assessment.
#' @srrstats {G3.0} Floating-point equality is avoided; the UNE-EN 689 full-shift duration comparison uses an explicit numerical tolerance, while exact equality comparisons elsewhere concern integer counts or categorical values.
#' @noRd
NULL
# ---- end rOpenSci statistical standards ----
