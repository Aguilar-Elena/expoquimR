# ---- rOpenSci statistical standards ----
#' @srrstats {EA5.4} Numeric values displayed in UNE-EN 689 graphical annotations are explicitly rounded to a controlled number of digits, and this behaviour is tested.
#' @srrstats {EA6.1} Graphical output properties are explicitly tested, including ggplot class, axis labels and units, layer structure, distinct colour and line encodings, annotation rounding, and graphical input validation.
# ---- end rOpenSci statistical standards ----

test_that("UNE-EN 689 density plot returns a stable ggplot object", {

  skip_if_not_installed("ggplot2")

  p <- expoquimR:::.une689_density_plot(
    eds = c(5, 6, 7, 8, 9, 10),
    center = 7.5,
    vla = 10,
    lsc = 11.2,
    center_label = "MA",
    title = "Test distribution",
    subtitle = "n = 6",
    x_label = "Daily exposure ED (mg/m³)",
    y_label = "Density"
  )

  expect_s3_class(p, "ggplot")

  expect_equal(
    p$labels$x,
    "Daily exposure ED (mg/m³)"
  )

  expect_equal(
    p$labels$y,
    "Density"
  )

  expect_equal(
    p$labels$title,
    "Test distribution"
  )

  expect_gte(length(p$layers), 7L)
})


test_that("UNE-EN 689 density plot uses distinct line encodings", {

  skip_if_not_installed("ggplot2")

  p <- expoquimR:::.une689_density_plot(
    eds = c(5, 6, 7, 8, 9, 10),
    center = 7.5,
    vla = 10,
    lsc = 11.2
  )

  line_layers <- p$layers[3:5]

  colours <- vapply(
    line_layers,
    function(x) x$aes_params$colour,
    character(1)
  )

  linetypes <- vapply(
    line_layers,
    function(x) x$aes_params$linetype,
    character(1)
  )

  expect_length(unique(colours), 3L)
  expect_length(unique(linetypes), 3L)
})


test_that("UNE-EN 689 plot annotations use explicit rounding", {

  skip_if_not_installed("ggplot2")

  p <- expoquimR:::.une689_density_plot(
    eds = c(5, 6, 7, 8, 9, 10),
    center = 7.123456,
    vla = 10.123456,
    lsc = 11.234567,
    center_label = "MA",
    digits = 3
  )

  labels <- vapply(
    p$layers[6:8],
    function(x) x$aes_params$label,
    character(1)
  )

  expect_true(any(grepl("7.123", labels, fixed = TRUE)))
  expect_true(any(grepl("10.123", labels, fixed = TRUE)))
  expect_true(any(grepl("11.235", labels, fixed = TRUE)))
})


test_that("UNE-EN 689 density plot validates graphical inputs", {

  skip_if_not_installed("ggplot2")

  expect_error(
    expoquimR:::.une689_density_plot(
      eds = c(5, NA, 7),
      center = 6,
      vla = 10,
      lsc = 12
    ),
    "NA"
  )

  expect_error(
    expoquimR:::.une689_density_plot(
      eds = c(5, 6, 7),
      center = 6,
      vla = 10,
      lsc = 12,
      digits = -1
    ),
    "non-negative integer"
  )
})


test_that("parametric normal curve matches dnorm and exposes fitted model", {
  skip_if_not_installed("ggplot2")
  p <- expoquimR:::.une689_parametric_density_plot(
    eds = c(5, 6, 7, 8, 9, 10), distribution = "Normal",
    ma = 7.5, ds = 1.5, mg = NA_real_, dsg = NA_real_,
    vla = 10, lsc = 11.2)
  expect_s3_class(p, "ggplot")
  expect_equal(p$data$density, stats::dnorm(p$data$ED, 7.5, 1.5))
  expect_equal(length(p$data$ED), 500L)
  expect_equal(p$labels$y, "Density")
})

test_that("parametric lognormal curve matches dlnorm", {
  skip_if_not_installed("ggplot2")
  p <- expoquimR:::.une689_parametric_density_plot(
    eds = c(5, 6, 7, 8, 9, 10), distribution = "Lognormal",
    ma = NA_real_, ds = NA_real_, mg = 7.5, dsg = 1.5,
    vla = 10, lsc = NA_real_)
  expect_equal(p$data$density,
               stats::dlnorm(p$data$ED, log(7.5), log(1.5)))
  expect_equal(length(p$layers), 7L)
})

test_that("parametric density rejects unselected or degenerate models", {
  skip_if_not_installed("ggplot2")
  args <- list(eds = c(5, 6, 7), distribution = "Neither",
               ma = 6, ds = 1, mg = 6, dsg = 1.5, vla = 10)
  expect_error(do.call(expoquimR:::.une689_parametric_density_plot, args),
               "distribution")
  args$distribution <- "Lognormal"
  args$dsg <- 1
  expect_error(do.call(expoquimR:::.une689_parametric_density_plot, args),
               "DSG > 1")
  args$distribution <- "Normal"
  args$ds <- 0
  expect_error(do.call(expoquimR:::.une689_parametric_density_plot, args),
               "DS > 0")
})
