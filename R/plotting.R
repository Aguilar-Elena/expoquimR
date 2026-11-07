#' Build UNE-EN 689 exposure-density plot
#'
#' Internal plotting helper shared by interactive and report outputs.
#'
#' @param eds Numeric vector of daily exposure values.
#' @param center Numeric central value (MA or MG).
#' @param vla Numeric occupational exposure limit.
#' @param lsc Numeric upper confidence limit.
#' @param center_label Character label identifying the central statistic.
#' @param vla_label Character label identifying the occupational exposure limit.
#' @param lsc_label Character label identifying the upper confidence limit.
#' @param title Character plot title.
#' @param subtitle Optional character subtitle.
#' @param x_label Character label for the x axis.
#' @param y_label Character label for the y axis.
#' @param digits Number of decimal places used in annotations.
#'
#' @return A ggplot object.
#' @noRd
.une689_density_plot <- function(
    eds,
    center,
    vla,
    lsc,
    center_label = "MG",
    vla_label = "OEL",
    lsc_label = "LSC",
    title = NULL,
    subtitle = NULL,
    x_label = "Daily exposure ED (mg/m\u00b3)",
    y_label = "Density",
    digits = 3
) {

  .assert_numeric_vector(eds, "eds", positive = TRUE)
  .assert_numeric_scalar(center, "center")
  .assert_numeric_scalar(vla, "vla")
  .assert_numeric_scalar(lsc, "lsc")

  for (nm in c("center_label", "vla_label", "lsc_label")) {
    value <- get(nm)
    if (!is.character(value) ||
        length(value) != 1L ||
        is.na(value) ||
        !nzchar(value)) {
      stop(
        paste0("`", nm, "` must be a non-empty character scalar."),
        call. = FALSE
      )
    }
  }

  if (!is.numeric(digits) ||
      length(digits) != 1L ||
      is.na(digits) ||
      digits < 0 ||
      digits != floor(digits)) {
    stop("`digits` must be a non-negative integer.", call. = FALSE)
  }

  # Colour-blind-friendly palette derived from the Okabe-Ito scheme.
  col_center <- "#0072B2"
  col_vla    <- "#D55E00"
  col_lsc    <- "#CC79A7"

  plot_data <- data.frame(ED = eds)

  ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = ED)
  ) +
    ggplot2::geom_density(
      fill = "#E69F00",
      colour = "#4D4D4D",
      alpha = 0.25,
      linewidth = 0.8
    ) +
    ggplot2::geom_rug(
      colour = "#4D4D4D",
      alpha = 0.6
    ) +
    ggplot2::geom_vline(
      xintercept = center,
      colour = col_center,
      linetype = "dashed",
      linewidth = 0.9
    ) +
    ggplot2::geom_vline(
      xintercept = vla,
      colour = col_vla,
      linetype = "dotdash",
      linewidth = 0.9
    ) +
    ggplot2::geom_vline(
      xintercept = lsc,
      colour = col_lsc,
      linetype = "dotted",
      linewidth = 0.9
    ) +
    ggplot2::annotate(
      "label",
      x = center,
      y = Inf,
      vjust = 1.5,
      label = paste0(
        center_label,
        " = ",
        round(center, digits)
      ),
      colour = col_center,
      fill = "white",
      size = 3.5
    ) +
    ggplot2::annotate(
      "label",
      x = vla,
      y = Inf,
      vjust = 3.5,
      label = paste0(
        vla_label,
        " = ",
        round(vla, digits)
      ),
      colour = col_vla,
      fill = "white",
      size = 3.5
    ) +
    ggplot2::annotate(
      "label",
      x = lsc,
      y = Inf,
      vjust = 5.5,
      label = paste0(
        lsc_label,
        " = ",
        round(lsc, digits)
      ),
      colour = col_lsc,
      fill = "white",
      size = 3.5
    ) +
    ggplot2::labs(
      title = title,
      subtitle = subtitle,
      x = x_label,
      y = y_label
    ) +
    ggplot2::theme_minimal(base_size = 12)
}

#' Plot a fitted normal or lognormal UNE-EN 689 exposure distribution
#'
#' Internal helper used by both Shiny and the R Markdown report. The curve
#' describes the selected parametric model, not a kernel density estimate.
#' Graphical diagnostics do not determine compliance or SEG homogeneity.
#' @noRd
.une689_parametric_density_plot <- function(
    eds, distribution, ma, ds, mg, dsg, vla, lsc = NA_real_,
    title = NULL, subtitle = NULL,
    x_label = "Daily exposure ED (mg/m\u00b3)", y_label = "Density",
    center_label = NULL, vla_label = "OEL", lsc_label = "UCL",
    digits = 4L) {

  .assert_numeric_vector(eds, "eds", positive = TRUE)
  if (length(eds) < 2L) stop("`eds` must contain at least two observations.", call. = FALSE)
  if (!is.character(distribution) || length(distribution) != 1L ||
      is.na(distribution) || !distribution %in% c("Normal", "Lognormal")) {
    stop("`distribution` must be 'Normal' or 'Lognormal'.", call. = FALSE)
  }
  valid_scalar <- function(x) is.numeric(x) && length(x) == 1L &&
    !is.na(x) && is.finite(x)
  if (!valid_scalar(vla) || vla <= 0) {
    stop("`vla` must be a finite positive scalar.", call. = FALSE)
  }
  if (!is.numeric(lsc) || length(lsc) != 1L ||
      (!is.na(lsc) && !is.finite(lsc))) {
    stop("`lsc` must be NA or a finite numeric scalar.", call. = FALSE)
  }
  if (!is.numeric(digits) || length(digits) != 1L || is.na(digits) ||
      !is.finite(digits) || digits < 0 || digits != floor(digits)) {
    stop("`digits` must be a non-negative integer.", call. = FALSE)
  }
  if (identical(distribution, "Lognormal")) {
    if (!valid_scalar(mg) || mg <= 0 || !valid_scalar(dsg) || dsg <= 1) {
      stop("Lognormal model requires finite MG > 0 and DSG > 1.", call. = FALSE)
    }
    center <- mg
    if (is.null(center_label)) center_label <- "MG"
  } else {
    if (!valid_scalar(ma) || !valid_scalar(ds) || ds <= 0) {
      stop("Normal model requires finite MA and DS > 0.", call. = FALSE)
    }
    center <- ma
    if (is.null(center_label)) center_label <- "MA"
  }
  labels <- list(center_label = center_label, vla_label = vla_label,
                 lsc_label = lsc_label)
  if (any(!vapply(labels, function(x) is.character(x) && length(x) == 1L &&
                  !is.na(x) && nzchar(x), logical(1)))) {
    stop("Plot labels must be non-empty character scalars.", call. = FALSE)
  }

  # Display positive exposure concentrations only. A normal model may assign
  # some probability below zero; this display is not a truncated density model.
  x_max <- max(c(eds, vla, lsc, center), na.rm = TRUE) * 1.10
  if (!is.finite(x_max) || x_max <= 0) stop("Invalid plot range.", call. = FALSE)
  x_vals <- seq(0, x_max, length.out = 500L)
  dens <- if (identical(distribution, "Lognormal")) {
    stats::dlnorm(x_vals, meanlog = log(mg), sdlog = log(dsg))
  } else {
    stats::dnorm(x_vals, mean = ma, sd = ds)
  }
  df <- data.frame(ED = x_vals, density = dens)
  p <- ggplot2::ggplot(df, ggplot2::aes(x = ED, y = density)) +
    ggplot2::geom_line(colour = "#E69F00", linewidth = 0.9) +
    ggplot2::geom_area(fill = "#E69F00", alpha = 0.22) +
    ggplot2::geom_rug(data = data.frame(ED = eds),
                      mapping = ggplot2::aes(x = ED), inherit.aes = FALSE,
                      colour = "#4D4D4D", alpha = 0.6) +
    ggplot2::geom_vline(xintercept = center, colour = "#0072B2",
                        linetype = "dashed", linewidth = 0.9) +
    ggplot2::geom_vline(xintercept = vla, colour = "#D55E00",
                        linetype = "dotdash", linewidth = 0.9) +
    ggplot2::annotate("label", x = center, y = Inf, vjust = 1.5,
                      label = paste0(center_label, " = ", round(center, digits)),
                      colour = "#0072B2", fill = "white", size = 3.2) +
    ggplot2::annotate("label", x = vla, y = Inf, vjust = 3.5,
                      label = paste0(vla_label, " = ", round(vla, digits)),
                      colour = "#D55E00", fill = "white", size = 3.2) +
    ggplot2::labs(title = title, subtitle = subtitle,
                  x = x_label, y = y_label) +
    ggplot2::theme_minimal(base_size = 12)
  if (!is.na(lsc)) {
    p <- p +
      ggplot2::geom_vline(xintercept = lsc, colour = "#CC79A7",
                          linetype = "dotted", linewidth = 0.9) +
      ggplot2::annotate("label", x = lsc, y = Inf, vjust = 5.5,
                        label = paste0(lsc_label, " = ", round(lsc, digits)),
                        colour = "#CC79A7", fill = "white", size = 3.2)
  }
  p
}

utils::globalVariables(c("ED", "density"))

# ---- rOpenSci statistical standards ----
#' @srrstats {EA5.0} UNE-EN 689 graphical output is generated through a shared plotting helper designed to provide accessible labels, readable sizing, redundant visual encodings, and explicit units.
#' @srrstats {EA5.0a} UNE-EN 689 plots use a minimum base theme size of 12 and annotation text sized for legibility in both Shiny and rendered reports.
#' @srrstats {EA5.0b} UNE-EN 689 plots use a colour-blind-friendly palette together with distinct line types, so interpretation does not depend on colour alone.
#' @srrstats {EA5.5} UNE-EN 689 graphical axes explicitly report the available exposure units, including mg/m\u00b3 for daily exposure.
#' @noRd
NULL
# ---- end rOpenSci statistical standards ----
