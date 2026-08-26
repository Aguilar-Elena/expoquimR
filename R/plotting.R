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

utils::globalVariables("ED")

# ---- rOpenSci statistical standards ----
#' @srrstats {EA5.0} UNE-EN 689 graphical output is generated through a shared plotting helper designed to provide accessible labels, readable sizing, redundant visual encodings, and explicit units.
#' @srrstats {EA5.0a} UNE-EN 689 plots use a minimum base theme size of 12 and annotation text sized for legibility in both Shiny and rendered reports.
#' @srrstats {EA5.0b} UNE-EN 689 plots use a colour-blind-friendly palette together with distinct line types, so interpretation does not depend on colour alone.
#' @srrstats {EA5.5} UNE-EN 689 graphical axes explicitly report the available exposure units, including mg/m\u00b3 for daily exposure.
#' @noRd
NULL
# ---- end rOpenSci statistical standards ----
