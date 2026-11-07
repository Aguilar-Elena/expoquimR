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

  if (is.object(x)) {
    stop(
      sprintf(
        "`%s` must be an unclassed numeric scalar; classed numeric objects are not supported.",
        name
      ),
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

  if (is.object(x)) {
    stop(
      sprintf(
        "`%s` must be an unclassed numeric vector; classed numeric objects are not supported.",
        name
      ),
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

  # Preserve unused sample slots (both values missing), but reject
  # partially entered rows: silently dropping them can understate ED.
  partial <- xor(is.na(data$concentration), is.na(data$time))
  if (any(partial)) {
    stop("`data` contains incomplete sample pairs (concentration/time).", call. = FALSE)
  }
  .assert_numeric_vector(data$concentration, "data$concentration",
                         allow_na = TRUE, allow_empty = TRUE)
  .assert_numeric_vector(data$time, "data$time",
                         allow_na = TRUE, allow_empty = TRUE)
  if (any(data$concentration[!is.na(data$concentration)] < 0)) {
    stop("`data$concentration` must be non-negative.", call. = FALSE)
  }
  if (any(data$time[!is.na(data$time)] <= 0)) {
    stop("`data$time` must be strictly positive.", call. = FALSE)
  }
  if (anyNA(data$day) ||
      any(is.character(data$day) & !nzchar(trimws(as.character(data$day)))) ||
      (is.numeric(data$day) && any(!is.finite(data$day)))) {
    stop("`data$day` must contain valid non-missing identifiers.", call. = FALSE)
  }
  data
}


#' Ensure an HTML report filename has an extension
#'
#' Internal helper used by [expoquimr_report()] to append `.html` when the
#' supplied output filename has no extension.
#'
#' @param path Character scalar containing an output path.
#'
#' @return Character scalar with an explicit file extension.
#' @noRd
.ensure_html_extension <- function(path) {
  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`output` must be a non-empty character scalar.", call. = FALSE)
  }

  if (!nzchar(tools::file_ext(path))) {
    path <- paste0(path, ".html")
  }

  path
}

# ---- rOpenSci statistical standards ----
#' @srrstats {G2.0} Input lengths are explicitly validated for scalar and vector arguments through internal validation helpers and existing function-specific checks.
#' @srrstats {G2.1} Numeric input types are explicitly validated before statistical calculations are performed.
#' @srrstats {G2.2} Parameters expected to be scalar are explicitly restricted to length one.
#' @srrstats {G2.6} One-dimensional numerical inputs are explicitly checked for unsupported class structures before analytical processing; classed vectors such as Date or domain-specific numeric classes are rejected with informative diagnostics rather than silently stripped of attributes.
#' @srrstats {G2.7} The preliminary UNE-EN 689 interface accepts base data frames, data-frame subclasses, and named two-dimensional matrices as tabular input.
#' @srrstats {G2.8} Tabular inputs are normalised during initial preprocessing to a base data.frame before analytical sub-functions are called.
#' @srrstats {G2.9} Conversion of data-frame subclasses to base data.frame emits an explicit diagnostic message because class-specific attributes may not be preserved.
#' @srrstats {G2.10} Tabular inputs are normalised to base data.frame before column extraction, providing consistent extraction semantics independent of the original supported tabular class.
#' @srrstats {G2.11} Required analytical columns with unsupported class attributes are explicitly detected and rejected with informative diagnostics.
#' @srrstats {G2.12} List columns in required UNE-EN 689 analytical fields are explicitly detected and rejected with informative diagnostics and dedicated tests.
#' @srrstats {G2.13} Missing values are explicitly checked during preprocessing in COSHH, INRS, UNE-EN 689, and Excel-import routines before analytic calculations are performed.
#' @srrstats {G2.15} Inputs are explicitly checked for missing values before statistical routines such as mean(), sd(), and shapiro.test() are called; operations that intentionally omit missing values do so explicitly.
#' @srrstats {G2.16} Numeric inputs used in core statistical calculations are checked for non-finite values including Inf, -Inf and NaN.
#' @srrstats {EA2.6} Vector inputs with additional attributes or class structures are explicitly pre-processed; unsupported classed vectors are rejected with informative diagnostics rather than being silently coerced.
#' @noRd
NULL
# ---- end rOpenSci statistical standards ----
