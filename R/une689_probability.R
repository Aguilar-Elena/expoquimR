#' Probability-paper data for examining a similar exposure group (UNE-EN 689)
#'
#' Computes the quantities needed to draw the graphical validation of a
#' similar exposure group (SEG, "GES" in Spanish) on probability paper:
#' the daily exposure values are ranked in ascending order and each rank
#' `k` is assigned the plotting position
#' \eqn{P_k = (k - 3/8) / (n + 1/4)}. If the data follow the assumed
#' distribution, the points fall approximately on a straight line when
#' plotted against \eqn{P_k} on log-normal paper (lognormal data) or on
#' normal paper (normal data).
#'
#' @details
#' The vertical coordinate used for the fit is the standard normal quantile
#' \eqn{z_k = \Phi^{-1}(P_k)}, which is what the probability scale of the
#' paper represents. The straight line is the least-squares regression of
#' `log(ED)` (lognormal) or `ED` (normal) on \eqn{z_k}. For lognormal data
#' the intercept and slope estimate `log(MG)` and `log(DSG)`, and for normal
#' data they estimate `MA` and `DS`; these are regression-based graphical
#' estimates and do not replace [une689_statistics()].
#'
#' The coefficient of determination returned in `r_squared` is purely
#' descriptive. The graphical check is a visual one: the group is
#' considered consistent when all points lie close to a straight line and
#' none is exceptionally separated from the rest. This function does not
#' apply any numerical cut-off to that judgement.
#'
#' Note that [stats::ppoints()] uses the same plotting positions only for
#' `n <= 10`; this function always uses \eqn{(k - 3/8)/(n + 1/4)}.
#'
#' @param ed Numeric vector. Daily exposure (ED) values, all strictly
#'   positive; between 3 and 5000 values.
#' @param distribution Character. `"lognormal"`, `"normal"`, or `"auto"`
#'   (default). With `"auto"` the lognormal distribution is used if the
#'   Shapiro-Wilk test on `log(ED)` does not reject it at level `alpha`;
#'   otherwise the normal distribution is used if the test on `ED` does
#'   not reject it; if both are rejected, an error is raised. The labels
#'   returned by [une689_distribution_type()] (English or Spanish) are also
#'   accepted.
#' @param alpha Numeric. Significance level of the Shapiro-Wilk tests used
#'   by `distribution = "auto"` (default 0.05).
#'
#' @return A list with elements:
#'   \describe{
#'     \item{`data`}{A `data.frame` with one row per observation and columns
#'       `k` (rank), `ed` (sorted values), `pk` (plotting position),
#'       `pk_percent` (`100 * pk`), `z` (standard normal quantile of `pk`),
#'       `y` (`log(ed)` for lognormal, `ed` for normal), `fitted` and
#'       `residual` of the straight-line fit.}
#'     \item{`distribution`}{`"lognormal"` or `"normal"`.}
#'     \item{`n`}{Number of observations.}
#'     \item{`intercept`, `slope`}{Coefficients of the straight line
#'       `y = intercept + slope * z`.}
#'     \item{`r_squared`}{Coefficient of determination of the fit.}
#'     \item{`W`, `p_value`}{Shapiro-Wilk statistic and p-value for the
#'       chosen distribution (on `log(ed)` for lognormal, on `ed` for
#'       normal).}
#'     \item{`alpha`}{The significance level used.}
#'   }
#'
#' @seealso [une689_probability_plot()], [une689_normality_test()],
#'   [une689_distribution_type()]
#'
#' @examples
#' ed <- c(0.008, 0.012, 0.017, 0.021, 0.034, 0.041)
#' pd <- une689_probability_data(ed)
#' pd$distribution
#' pd$data[, c("k", "ed", "pk")]
#' pd$r_squared
#'
#' @export
une689_probability_data <- function(ed,
                                    distribution = c("auto", "lognormal", "normal"),
                                    alpha = 0.05) {
  .assert_numeric_vector(
    ed,
    "ed",
    allow_na = FALSE,
    allow_empty = FALSE,
    positive = TRUE
  )
  .assert_numeric_scalar(alpha, "alpha")
  if (alpha <= 0 || alpha >= 1) {
    stop("`alpha` must be strictly between 0 and 1.", call. = FALSE)
  }
  if (length(ed) < 3L) {
    stop(
      "`ed` must contain at least 3 observations to draw a probability paper.",
      call. = FALSE
    )
  }

  key <- .une689_match_distribution(distribution)
  if (identical(key, "neither")) {
    stop(
      "No probability paper can be selected when neither the normal nor the ",
      "lognormal distribution fits the data. Use `distribution = \"lognormal\"` ",
      "or `distribution = \"normal\"` to draw one anyway.",
      call. = FALSE
    )
  }

  # Also validates the number of observations (3 to 5000) and identical values.
  test <- une689_normality_test(ed)

  if (identical(key, "auto")) {
    key <- if (test$pval_lognormal > alpha) {
      "lognormal"
    } else if (test$pval_normal > alpha) {
      "normal"
    } else {
      stop(
        "Neither the normal nor the lognormal distribution fits the data ",
        "(Shapiro-Wilk, p <= alpha). Use `distribution = \"lognormal\"` or ",
        "`distribution = \"normal\"` to draw a probability paper anyway.",
        call. = FALSE
      )
    }
  }

  ed_sorted <- sort(ed)
  n <- length(ed_sorted)
  k <- seq_len(n)
  pk <- (k - 3 / 8) / (n + 1 / 4)
  z <- stats::qnorm(pk)
  y <- if (identical(key, "lognormal")) log(ed_sorted) else ed_sorted

  fit <- stats::lm(y ~ z)
  coefs <- unname(stats::coef(fit))

  list(
    data = data.frame(
      k = k,
      ed = ed_sorted,
      pk = pk,
      pk_percent = 100 * pk,
      z = z,
      y = y,
      fitted = unname(stats::fitted(fit)),
      residual = unname(stats::residuals(fit))
    ),
    distribution = key,
    n = n,
    intercept = coefs[1L],
    slope = coefs[2L],
    r_squared = summary(fit)$r.squared,
    W = if (identical(key, "lognormal")) test$W_lognormal else test$W_normal,
    p_value = if (identical(key, "lognormal")) test$pval_lognormal else test$pval_normal,
    alpha = alpha
  )
}

#' Probability paper plot for examining a similar exposure group (UNE-EN 689)
#'
#' Draws the daily exposure (ED) values of a similar exposure group on
#' probability paper: the vertical axis is the cumulative probability
#' \eqn{P_k} on a normal-probability scale and the horizontal axis is the
#' exposure on a logarithmic scale (log-normal paper) when the data are
#' lognormal, or on a linear scale (normal paper) when the data are normal.
#' A straight line is fitted to the points. If all points lie close to the
#' line and none is exceptionally separated from the others, the group is
#' consistent with the assumed distribution.
#'
#' The default subtitle reports the number of observations, the
#' Shapiro-Wilk statistic and p-value for the chosen distribution, and the
#' coefficient of determination of the line. See [une689_probability_data()]
#' for how the plotting positions and the line are computed.
#'
#' Requires the 'ggplot2' package.
#'
#' @inheritParams une689_probability_data
#' @param vla Optional positive numeric. Occupational exposure limit
#'   (mg/m3, expressed as a daily exposure). If supplied, it is drawn as a
#'   vertical reference line.
#' @param title,subtitle Optional character scalars. If `NULL` (default)
#'   an informative title and subtitle are generated. Use `""` to suppress
#'   the subtitle.
#' @param x_label,y_label Character scalars. Axis labels.
#' @param vla_label Character scalar. Label of the OEL reference line.
#' @param digits Non-negative integer. Number of decimal places used in the
#'   OEL annotation.
#'
#' @return A `ggplot` object.
#'
#' @seealso [une689_probability_data()]
#'
#' @examples
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ed <- c(0.008, 0.012, 0.017, 0.021, 0.034, 0.041)
#'   une689_probability_plot(ed, vla = 0.1)
#' }
#'
#' @export
une689_probability_plot <- function(ed,
                                    distribution = c("auto", "lognormal", "normal"),
                                    alpha = 0.05,
                                    vla = NULL,
                                    title = NULL,
                                    subtitle = NULL,
                                    x_label = "Daily exposure ED (mg/m\u00b3)",
                                    y_label = "Cumulative probability P_k (%)",
                                    vla_label = "OEL",
                                    digits = 3) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop(
      "Package 'ggplot2' is required to draw the probability paper. ",
      "Install it with: install.packages('ggplot2')",
      call. = FALSE
    )
  }

  if (!is.null(vla)) {
    .assert_numeric_scalar(vla, "vla")
    if (vla <= 0) {
      stop("`vla` must be positive.", call. = FALSE)
    }
  }
  for (nm in c("x_label", "y_label", "vla_label")) {
    .assert_label(get(nm), nm)
  }
  .assert_label(title, "title", allow_null = TRUE)
  .assert_label(subtitle, "subtitle", allow_null = TRUE)
  if (!is.numeric(digits) ||
      length(digits) != 1L ||
      is.na(digits) ||
      digits < 0 ||
      digits != floor(digits)) {
    stop("`digits` must be a non-negative integer.", call. = FALSE)
  }

  pd <- une689_probability_data(ed, distribution = distribution, alpha = alpha)
  d <- pd$data
  log_axis <- identical(pd$distribution, "lognormal")

  if (is.null(title)) {
    title <- if (log_axis) {
      "Log-normal probability paper"
    } else {
      "Normal probability paper"
    }
  }
  if (is.null(subtitle)) {
    subtitle <- sprintf(
      "n = %d | Shapiro-Wilk W = %.3f (p = %.3f) | R\u00b2 = %.3f",
      pd$n, pd$W, pd$p_value, pd$r_squared
    )
  }

  # Vertical axis: normal-probability scale (labels in %, positions at qnorm).
  pct <- c(0.1, 1, 5, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 99.9)
  z_lim <- range(c(d$z, stats::qnorm(c(0.01, 0.99)))) + c(-0.15, 0.15)
  z_pct <- stats::qnorm(pct / 100)
  keep <- z_pct >= z_lim[1L] & z_pct <= z_lim[2L]

  # Fitted straight line, drawn over the range of the data.
  z_line <- seq(min(d$z) - 0.4, max(d$z) + 0.4, length.out = 100L)
  y_line <- pd$intercept + pd$slope * z_line
  x_line <- if (log_axis) exp(y_line) else y_line

  point_df <- data.frame(x_val = d$ed, z_val = d$z)
  line_df <- data.frame(x_val = x_line, z_val = z_line)

  # Colour-blind-friendly colours (Okabe-Ito) plus distinct shapes/line types,
  # so interpretation does not depend on colour alone.
  p <- ggplot2::ggplot() +
    ggplot2::geom_line(
      data = line_df,
      mapping = ggplot2::aes(x = x_val, y = z_val),
      colour = "#0072B2",
      linewidth = 0.9
    ) +
    ggplot2::geom_point(
      data = point_df,
      mapping = ggplot2::aes(x = x_val, y = z_val),
      shape = 4,
      size = 3,
      stroke = 1.1,
      colour = "#4D4D4D"
    )

  if (!is.null(vla)) {
    p <- p +
      ggplot2::geom_vline(
        xintercept = vla,
        colour = "#D55E00",
        linetype = "dotdash",
        linewidth = 0.9
      ) +
      ggplot2::annotate(
        "label",
        x = vla,
        y = z_lim[2L],
        hjust = 1,
        vjust = 1,
        label = paste0(vla_label, " = ", round(vla, digits)),
        colour = "#D55E00",
        fill = "white",
        size = 3.5
      )
  }

  if (log_axis) {
    p <- p + ggplot2::scale_x_log10()
  }

  p +
    ggplot2::scale_y_continuous(
      breaks = z_pct[keep],
      labels = as.character(pct[keep])
    ) +
    ggplot2::coord_cartesian(ylim = z_lim) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = x_label,
      y = y_label
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

# Internal: map a user-supplied distribution specification to one of
# "auto", "lognormal", "normal" or "neither".
.une689_match_distribution <- function(distribution) {
  if (!is.character(distribution) || length(distribution) < 1L || anyNA(distribution)) {
    stop("`distribution` must be a character value.", call. = FALSE)
  }
  if (identical(distribution, c("auto", "lognormal", "normal"))) {
    return("auto")
  }
  if (length(distribution) != 1L) {
    stop(
      "`distribution` must be one of \"auto\", \"lognormal\" or \"normal\".",
      call. = FALSE
    )
  }

  key <- switch(
    tolower(trimws(distribution)),
    "auto" = "auto",
    "lognormal" = ,
    "log-normal" = "lognormal",
    "normal" = "normal",
    "neither" = ,
    "ninguna" = "neither",
    NA_character_
  )
  if (is.na(key)) {
    stop(
      "`distribution` must be one of \"auto\", \"lognormal\" or \"normal\".",
      call. = FALSE
    )
  }
  key
}

# Internal: validate a character label (scalar, non-empty, non-missing).
.assert_label <- function(x, name, allow_null = FALSE) {
  if (is.null(x)) {
    if (allow_null) {
      return(invisible(TRUE))
    }
    stop(sprintf("`%s` must be a character scalar.", name), call. = FALSE)
  }
  if (!is.character(x) || length(x) != 1L || is.na(x)) {
    stop(sprintf("`%s` must be a character scalar.", name), call. = FALSE)
  }
  if (!nzchar(x) && !(allow_null && identical(name, "subtitle"))) {
    stop(sprintf("`%s` must be a non-empty character scalar.", name), call. = FALSE)
  }
  invisible(TRUE)
}

utils::globalVariables(c("x_val", "z_val"))

.assert_numeric_scalar <- function(x, name) {
  if (!is.numeric(x) ||
      length(x) != 1L ||
      is.na(x) ||
      !is.finite(x)) {
    stop(
      sprintf("`%s` must be a single finite numeric value.", name),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

.assert_numeric_vector <- function(x, name,
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

  if (any(!is.finite(x[!is.na(x)]))) {
    stop(
      sprintf("`%s` must contain finite values.", name),
      call. = FALSE
    )
  }

  if (positive && any(x[!is.na(x)] <= 0)) {
    stop(
      sprintf("`%s` must contain strictly positive values.", name),
      call. = FALSE
    )
  }

  invisible(TRUE)
}
