# Worked example from the UNE-EN 689 teaching material (n = 6):
# concentrations 0.008, 0.012, 0.017, 0.021, 0.034, 0.041 with plotting
# positions P_k = (k - 3/8) / (n + 1/4) = 0.10, 0.26, 0.42, 0.58, 0.74, 0.90.
ed_slide <- c(0.041, 0.008, 0.034, 0.012, 0.017, 0.021)

test_that("plotting positions reproduce the published worked example", {
  pd <- une689_probability_data(ed_slide)

  expect_equal(pd$data$k, 1:6)
  expect_equal(pd$data$ed, sort(ed_slide))
  expect_equal(pd$data$pk, c(0.10, 0.26, 0.42, 0.58, 0.74, 0.90))
  expect_equal(pd$data$pk_percent, c(10, 26, 42, 58, 74, 90))
  expect_equal(pd$data$z, stats::qnorm(c(0.10, 0.26, 0.42, 0.58, 0.74, 0.90)))
})

test_that("plotting positions use (k - 3/8)/(n + 1/4) for any n, not ppoints()", {
  ed <- seq(1, 12)
  pd <- une689_probability_data(ed, distribution = "normal")

  expect_equal(pd$data$pk, (1:12 - 3 / 8) / (12 + 1 / 4))
  # stats::ppoints() switches to a = 1/2 for n > 10, so it must differ here.
  expect_false(isTRUE(all.equal(pd$data$pk, stats::ppoints(12))))
})

test_that("lognormal and normal fits use the right vertical variable", {
  pd_log <- une689_probability_data(ed_slide, distribution = "lognormal")
  pd_nor <- une689_probability_data(ed_slide, distribution = "normal")

  expect_identical(pd_log$distribution, "lognormal")
  expect_equal(pd_log$data$y, log(sort(ed_slide)))
  expect_identical(pd_nor$distribution, "normal")
  expect_equal(pd_nor$data$y, sort(ed_slide))

  fit <- stats::lm(log(sort(ed_slide)) ~ stats::qnorm(pd_log$data$pk))
  expect_equal(pd_log$intercept, unname(stats::coef(fit)[1]))
  expect_equal(pd_log$slope, unname(stats::coef(fit)[2]))
  expect_equal(pd_log$r_squared, summary(fit)$r.squared)
  expect_equal(pd_log$data$fitted + pd_log$data$residual, pd_log$data$y)

  # Reference values for the worked example.
  expect_equal(pd_log$r_squared, 0.9825, tolerance = 1e-4)
  expect_equal(pd_nor$r_squared, 0.9452, tolerance = 1e-4)
})

test_that("Shapiro-Wilk results agree with une689_normality_test()", {
  test <- une689_normality_test(ed_slide)
  pd_log <- une689_probability_data(ed_slide, distribution = "lognormal")
  pd_nor <- une689_probability_data(ed_slide, distribution = "normal")

  expect_equal(pd_log$W, test$W_lognormal)
  expect_equal(pd_log$p_value, test$pval_lognormal)
  expect_equal(pd_nor$W, test$W_normal)
  expect_equal(pd_nor$p_value, test$pval_normal)
})

test_that("distribution = 'auto' follows the Shapiro-Wilk decision", {
  # The worked example is compatible with lognormality.
  expect_identical(une689_probability_data(ed_slide)$distribution, "lognormal")

  # Clearly bimodal data fit neither distribution.
  bimodal <- c(1, 1.1, 1.2, 1.3, 100, 101, 102, 103)
  expect_error(une689_probability_data(bimodal), "Neither the normal nor the lognormal")
  # ...but a paper can still be requested explicitly.
  expect_identical(
    une689_probability_data(bimodal, distribution = "lognormal")$distribution,
    "lognormal"
  )
})

test_that("labels returned by une689_distribution_type() are accepted", {
  expect_identical(
    une689_probability_data(ed_slide, distribution = "Lognormal")$distribution,
    "lognormal"
  )
  expect_identical(
    une689_probability_data(ed_slide, distribution = "Normal")$distribution,
    "normal"
  )
  expect_error(
    une689_probability_data(ed_slide, distribution = "Neither"),
    "No probability paper"
  )
  expect_error(
    une689_probability_data(ed_slide, distribution = "Ninguna"),
    "No probability paper"
  )
})

test_that("une689_probability_data() validates its inputs", {
  expect_error(une689_probability_data(c(1, 2, NA)), "NA")
  expect_error(une689_probability_data(c(1, 2, 0)), "positive")
  expect_error(une689_probability_data(c(-1, 2, 3)), "positive")
  expect_error(une689_probability_data("a"), "numeric")
  expect_error(une689_probability_data(numeric(0)), "empty")
  expect_error(une689_probability_data(c(1, 2)), "at least 3")
  expect_error(une689_probability_data(ed_slide, alpha = 0), "alpha")
  expect_error(une689_probability_data(ed_slide, alpha = 1), "alpha")
  expect_error(une689_probability_data(ed_slide, alpha = c(0.1, 0.2)), "alpha")
  expect_error(une689_probability_data(ed_slide, distribution = "weibull"), "distribution")
  expect_error(une689_probability_data(ed_slide, distribution = 1), "character")
  expect_error(
    une689_probability_data(ed_slide, distribution = c("normal", "lognormal")),
    "distribution"
  )
})

test_that("une689_probability_plot() returns a ggplot with the right scales", {
  skip_if_not_installed("ggplot2")

  p_log <- une689_probability_plot(ed_slide)
  p_nor <- une689_probability_plot(ed_slide, distribution = "normal")

  expect_s3_class(p_log, "ggplot")
  expect_s3_class(p_nor, "ggplot")

  # Logarithmic horizontal axis only for lognormal paper.
  expect_match(p_log$scales$get_scales("x")$trans$name, "log")
  expect_null(p_nor$scales$get_scales("x"))

  # Probability scale: breaks are normal quantiles labelled in per cent.
  y_scale <- p_log$scales$get_scales("y")
  expect_equal(
    y_scale$breaks,
    stats::qnorm(as.numeric(y_scale$labels) / 100)
  )
  expect_true(all(c("1", "50", "99") %in% y_scale$labels))

  expect_equal(p_log$labels$title, "Log-normal probability paper")
  expect_equal(p_nor$labels$title, "Normal probability paper")
  expect_match(p_log$labels$subtitle, "n = 6")
  expect_match(p_log$labels$subtitle, "Shapiro-Wilk W = ")
  expect_equal(p_log$labels$x, "Daily exposure ED (mg/m\u00b3)")
  expect_equal(p_log$labels$y, "Cumulative probability P_k (%)")
})

test_that("une689_probability_plot() draws points, a fitted line and optional OEL", {
  skip_if_not_installed("ggplot2")

  p <- une689_probability_plot(ed_slide)
  expect_length(p$layers, 2L)
  expect_equal(p$layers[[2]]$aes_params$shape, 4)

  p_vla <- une689_probability_plot(ed_slide, vla = 0.1, vla_label = "VLA", digits = 2)
  expect_length(p_vla$layers, 4L)
  expect_equal(p_vla$layers[[3]]$aes_params$colour, "#D55E00")
  expect_equal(p_vla$layers[[4]]$aes_params$label, "VLA = 0.1")

  # The plotted points are the sorted data against the normal quantiles.
  built <- ggplot2::ggplot_build(p)
  pts <- built$data[[2]]
  # The lognormal paper uses a log10 horizontal scale.
  expect_equal(10^pts$x, sort(ed_slide))
  expect_equal(pts$y, stats::qnorm((1:6 - 3 / 8) / (6 + 1 / 4)))
})

test_that("une689_probability_plot() accepts custom labels and builds without warnings", {
  skip_if_not_installed("ggplot2")

  p <- une689_probability_plot(
    ed_slide,
    title = "Mi t\u00edtulo",
    subtitle = "",
    x_label = "ED (mg/m\u00b3)",
    y_label = "Probabilidad acumulada P_k (%)"
  )
  expect_equal(p$labels$title, "Mi t\u00edtulo")
  expect_equal(p$labels$subtitle, "")
  expect_equal(p$labels$x, "ED (mg/m\u00b3)")
  expect_warning(ggplot2::ggplot_build(p), NA)
  expect_warning(
    ggplot2::ggplot_build(une689_probability_plot(ed_slide, vla = 0.1)),
    NA
  )
})

test_that("une689_probability_plot() validates graphical inputs", {
  skip_if_not_installed("ggplot2")

  expect_error(une689_probability_plot(ed_slide, vla = -1), "positive")
  expect_error(une689_probability_plot(ed_slide, vla = "a"), "numeric")
  expect_error(une689_probability_plot(ed_slide, x_label = NA_character_), "x_label")
  expect_error(une689_probability_plot(ed_slide, y_label = ""), "y_label")
  expect_error(une689_probability_plot(ed_slide, title = 1), "title")
  expect_error(une689_probability_plot(ed_slide, digits = -1), "non-negative integer")
  expect_error(une689_probability_plot(c(1, NA, 3)), "NA")
})
