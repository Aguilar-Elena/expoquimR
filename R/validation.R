#' Validate a numeric scalar
#'
#' Internal validation helper for numeric scalar arguments.
#'
#' @param x Object to validate.
#' @param name Parameter name used in diagnostic messages.
#' @param allow_na Whether a single `NA` value is permitted.
#'
#' @return Invisibly returns `TRUE` when validation succeeds.
#' @noRd
.assert_numeric_scalar <- function(x, name, allow_na = FALSE) {
  if (!is.numeric(x) || length(x) != 1L) {
    stop(
      sprintf("`%s` must be a numeric scalar.", name),
      call. = FALSE
    )
  }

  if (is.na(x)) {
    if (allow_na) {
      return(invisible(TRUE))
    }

    stop(
      sprintf("`%s` must not be NA.", name),
      call. = FALSE
    )
  }

  if (!is.finite(x)) {
    stop(
      sprintf("`%s` must be finite.", name),
      call. = FALSE
    )
  }

  invisible(TRUE)
}


#' Validate a numeric vector
#'
#' Internal validation helper for numeric vector arguments.
#'
#' @param x Object to validate.
#' @param name Parameter name used in diagnostic messages.
#' @param allow_na Whether missing values are permitted.
#' @param allow_empty Whether zero-length vectors are permitted.
#' @param positive Whether all non-missing values must be strictly positive.
#'
#' @return Invisibly returns `TRUE` when validation succeeds.
#' @noRd
.assert_numeric_vector <- function(
    x,
    name,
    allow_na = FALSE,
    allow_empty = FALSE,
    positive = FALSE) {

  if (!is.numeric(x)) {
    stop(
      sprintf("`%s` must be numeric.", name),
      call. = FALSE
    )
  }

  if (!allow_empty && length(x) == 0L) {
    stop(
      sprintf("`%s` must not be empty.", name),
      call. = FALSE
    )
  }

  if (!allow_na && anyNA(x)) {
    stop(
      sprintf("`%s` must not contain NA values.", name),
      call. = FALSE
    )
  }

  y <- x[!is.na(x)]

  if (any(!is.finite(y))) {
    stop(
      sprintf("`%s` must contain only finite values.", name),
      call. = FALSE
    )
  }

  if (positive && any(y <= 0)) {
    stop(
      sprintf("`%s` must contain only positive values.", name),
      call. = FALSE
    )
  }

  invisible(TRUE)
}
