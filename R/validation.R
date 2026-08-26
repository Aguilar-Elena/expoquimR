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


#' Normalise UNE-EN 689 preliminary tabular input
#'
#' Internal helper that validates and normalises tabular input used by
#' [une689_evaluate_preliminary()]. Base data frames, data-frame subclasses,
#' and two-dimensional matrices with the required column names are accepted.
#'
#' @param data Tabular object containing `day`, `concentration`, and `time`.
#'
#' @return A base `data.frame` with validated columns.
#' @noRd
.normalize_une689_preliminary_data <- function(data) {
  required <- c("day", "concentration", "time")

  if (is.matrix(data)) {
    if (is.null(colnames(data))) {
      stop(
        "`data` matrices must have named columns.",
        call. = FALSE
      )
    }

    message("Converting matrix `data` to a base data.frame.")
    data <- as.data.frame(data, stringsAsFactors = FALSE)
  } else if (is.data.frame(data)) {
    if (!identical(class(data), "data.frame")) {
      message(
        "Converting `data` to a base data.frame; ",
        "class-specific attributes may not be preserved."
      )
      data <- as.data.frame(data)
    }
  } else {
    stop(
      "`data` must be a data.frame or a two-dimensional matrix.",
      call. = FALSE
    )
  }

  missing_columns <- setdiff(required, names(data))

  if (length(missing_columns) > 0L) {
    stop(
      sprintf(
        "`data` must contain columns: %s. Missing: %s.",
        paste(required, collapse = ", "),
        paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  for (nm in required) {
    if (is.list(data[[nm]])) {
      stop(
        sprintf(
          "`data$%s` must be an atomic vector, not a list column.",
          nm
        ),
        call. = FALSE
      )
    }
  }

  if (is.object(data$concentration)) {
    stop(
      "`data$concentration` has an unsupported column class.",
      call. = FALSE
    )
  }

  if (is.object(data$time)) {
    stop(
      "`data$time` has an unsupported column class.",
      call. = FALSE
    )
  }

  if (!is.numeric(data$concentration)) {
    stop(
      "`data$concentration` must be numeric.",
      call. = FALSE
    )
  }

  if (!is.numeric(data$time)) {
    stop(
      "`data$time` must be numeric.",
      call. = FALSE
    )
  }

  if (!(is.numeric(data$day) || is.character(data$day))) {
    stop(
      "`data$day` must be numeric or character.",
      call. = FALSE
    )
  }

  data
}
