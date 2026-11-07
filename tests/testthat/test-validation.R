# ---- rOpenSci statistical standards ----
#' @srrstats {G5.3} Tests explicitly verify that representative valid outputs from the core COSHH, INRS, and UNE-EN 689 computational routines contain no unexpected NA, NaN, Inf, or -Inf values.
#' @srrstats {G5.8} Edge-condition behaviour is explicitly tested for unsupported input types, empty vectors, non-finite values, and out-of-domain numeric values.
#' @srrstats {G5.8a} Zero-length numeric input is explicitly tested and rejected where unsupported.
#' @srrstats {G5.8b} Unsupported input types are explicitly tested and rejected for core numeric routines.
#' @srrstats {G5.8c} All-NA and all-identical exposure vectors are explicitly tested. All-NA exposure data are rejected, while identical valid observations produce the expected zero-variance summary; statistical evaluation of identical observations produces an explicit diagnostic.
#' @srrstats {G5.8d} Inputs outside the methodological domain are explicitly tested, including insufficient sample sizes and non-positive occupational exposure values.
#' @srrstats {G5.9} Numerical noise susceptibility is explicitly tested for deterministic occupational-hygiene calculations.
#' @srrstats {G5.9a} Tests verify that perturbations at approximately machine-precision scale do not materially alter UNE-EN 689 numerical summaries or COSHH categorical classifications.
# ---- end rOpenSci statistical standards ----

test_that("numeric scalar validation handles invalid inputs", {
  expect_invisible(
    expoquimR:::.assert_numeric_scalar(1, "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(c(1, 2), "x"),
    "numeric scalar"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar("1", "x"),
    "numeric scalar"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(NA_real_, "x"),
    "must not be NA"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_scalar(
      NA_real_,
      "x",
      allow_na = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(Inf, "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(-Inf, "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(NaN, "x")
  )
})


test_that("numeric vector validation handles edge conditions", {
  expect_invisible(
    expoquimR:::.assert_numeric_vector(c(1, 2, 3), "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(character(), "x"),
    "numeric"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(numeric(), "x"),
    "must not be empty"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_vector(
      numeric(),
      "x",
      allow_empty = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, NA), "x"),
    "must not contain NA"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_vector(
      c(1, NA),
      "x",
      allow_na = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, Inf), "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, -Inf), "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, NaN), "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(
      c(1, 0),
      "x",
      positive = TRUE
    ),
    "positive"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(
      c(1, -1),
      "x",
      positive = TRUE
    ),
    "positive"
  )
})

test_that("COSHH volatility rejects non-finite and non-scalar inputs", {
  expect_error(
    coshh_classify_volatility(Inf, 20),
    "finite"
  )

  expect_error(
    coshh_classify_volatility(111, -Inf),
    "finite"
  )

  expect_error(
    coshh_classify_volatility(c(100, 111), 20),
    "numeric scalar"
  )
})


test_that("UNE-EN 689 statistics rejects unsupported edge cases", {
  expect_error(
    une689_statistics(numeric()),
    "must not be empty"
  )

  expect_error(
    une689_statistics(c(1, 2, Inf)),
    "finite"
  )

  expect_error(
    une689_statistics(c(1, 2, -Inf)),
    "finite"
  )

  expect_error(
    une689_statistics(c(1, 2, NaN))
  )

  expect_error(
    une689_statistics(c(1, 0, 2)),
    "positive"
  )

  expect_error(
    une689_statistics(c(1, -1, 2)),
    "positive"
  )

  expect_error(
    une689_statistics(c("1", "2", "3")),
    "numeric"
  )
})

test_that("UNE-EN 689 handles all-NA and identical exposure vectors", {
  expect_error(
    une689_statistics(rep(NA_real_, 6)),
    "must not contain NA"
  )

  identical_stats <- une689_statistics(rep(0.5, 6))

  expect_equal(identical_stats$MA, 0.5, tolerance = 1e-12)
  expect_equal(identical_stats$DS, 0, tolerance = 1e-12)
  expect_equal(identical_stats$MG, 0.5, tolerance = 1e-12)
  expect_equal(identical_stats$DSG, 1, tolerance = 1e-12)

  resultado_constante <- une689_evaluate_statistical(rep(0.5, 6), vla = 1)
  expect_identical(resultado_constante$diagnostic_status, "CONSTANT_EXPOSURES")
  expect_identical(resultado_constante$distribution_type, "Neither")
  expect_equal(resultado_constante$MA, 0.5, tolerance = 1e-12)
  expect_equal(resultado_constante$DS, 0, tolerance = 1e-12)
  expect_equal(resultado_constante$MG, 0.5, tolerance = 1e-12)
  expect_equal(resultado_constante$DSG, 1, tolerance = 1e-12)
  expect_true(is.na(resultado_constante$pval_normal))
  expect_true(is.na(resultado_constante$pval_lognormal))
  expect_true(is.na(resultado_constante$lsc))
  expect_true(is.na(resultado_constante$ur))
  expect_true(is.na(resultado_constante$conformity))
})

test_that("UNE-EN 689 rejects data outside the statistical evaluation domain", {
  expect_error(
    une689_evaluate_statistical(c(0.4, 0.5, 0.6), vla = 1)
  )

  expect_error(
    une689_statistics(c(0.4, 0, 0.6)),
    "positive"
  )

  expect_error(
    une689_statistics(c(0.4, -0.5, 0.6)),
    "positive"
  )
})


test_that("UNE-EN 689 preliminary assessment validates tabular input", {
  x <- data.frame(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  expect_silent(
    une689_evaluate_preliminary(x, vla = 10)
  )

  expect_error(
    une689_evaluate_preliminary(
      x[, c("day", "concentration")],
      vla = 10
    ),
    "Missing: time"
  )

  expect_error(
    une689_evaluate_preliminary(
      list(
        day = x$day,
        concentration = x$concentration,
        time = x$time
      ),
      vla = 10
    ),
    "data.frame or a two-dimensional matrix"
  )
})


test_that("UNE-EN 689 preliminary assessment accepts named matrices", {
  x <- cbind(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  expect_message(
    result <- une689_evaluate_preliminary(x, vla = 10),
    "Converting matrix"
  )

  expect_type(result, "list")
  expect_s3_class(result$days_table, "data.frame")
})


test_that("UNE-EN 689 preliminary assessment normalises data-frame subclasses", {
  x <- data.frame(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  class(x) <- c("expoquimr_test_table", "data.frame")

  expect_message(
    result <- une689_evaluate_preliminary(x, vla = 10),
    "class-specific attributes"
  )

  expect_s3_class(result$days_table, "data.frame")
})


test_that("UNE-EN 689 preliminary assessment rejects list columns", {
  x <- data.frame(
    day = c(1, 2, 3),
    concentration = c(1, 2, 3),
    time = c(8, 8, 8)
  )

  x$concentration <- I(list(1, 2, 3))

  expect_error(
    une689_evaluate_preliminary(x, vla = 10),
    "list column"
  )
})


test_that("UNE-EN 689 preliminary assessment rejects unsupported column classes", {
  x <- data.frame(
    day = c(1, 2, 3),
    concentration = c(1, 2, 3),
    time = c(8, 8, 8)
  )

  x$concentration <- structure(
    x$concentration,
    class = "expoquimr_test_numeric"
  )

  expect_error(
    une689_evaluate_preliminary(x, vla = 10),
    "unsupported column class"
  )
})


test_that("UNE-EN 689 normality testing validates inputs before Shapiro-Wilk", {
  expect_error(
    une689_normality_test(c(1, NA_real_, 3)),
    "must not contain NA"
  )

  expect_error(
    une689_normality_test(c(1, Inf, 3)),
    "finite"
  )

  expect_error(
    une689_normality_test(c(1, 0, 3)),
    "positive"
  )

  expect_error(
    une689_normality_test(c(1, -1, 3)),
    "positive"
  )

  expect_error(
    une689_normality_test(c(1, 2)),
    "between 3 and 5000"
  )
})


test_that("UNE-EN 689 daily exposure uses tolerant comparison for full-day duration", {
  expect_equal(
    une689_daily_exposure(9, 8),
    9,
    tolerance = 1e-12
  )

  expect_equal(
    une689_daily_exposure(9, 8 + .Machine$double.eps),
    9,
    tolerance = 1e-12
  )

  expect_equal(
    une689_daily_exposure(9, 7),
    7.875,
    tolerance = 1e-12
  )
})


test_that("numeric validators reject unsupported classed vectors", {
  custom <- structure(
    c(1, 2, 3),
    class = "expoquimr_test_numeric"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(custom, "x"),
    "classed numeric objects are not supported"
  )

  expect_error(
    une689_statistics(custom),
    "classed numeric objects are not supported"
  )

  expect_error(
    une689_statistics(factor(c("1", "2", "3"))),
    "must be numeric"
  )

  expect_error(
    une689_statistics(as.Date("2026-01-01") + 0:2),
    "must be numeric"
  )
})


test_that("HTML report output extension is normalised", {
  expect_equal(
    expoquimR:::.ensure_html_extension("report"),
    "report.html"
  )

  expect_equal(
    expoquimR:::.ensure_html_extension("report.html"),
    "report.html"
  )

  expect_equal(
    expoquimR:::.ensure_html_extension("/tmp/my.report.html"),
    "/tmp/my.report.html"
  )

  expect_error(
    expoquimR:::.ensure_html_extension(""),
    "non-empty character scalar"
  )

  expect_error(
    expoquimR:::.ensure_html_extension(NA_character_),
    "non-empty character scalar"
  )
})


test_that("core valid outputs contain no undefined numeric values", {
  s <- une689_statistics(c(5, 6, 7, 8, 9, 10))
  expect_true(all(is.finite(unlist(s))))

  risk <- inrs_inhalation_risk(
    potential_risk_score = 100,
    volatility_score = 10,
    procedure_score = 0.5,
    protection_score = 0.7,
    vla_correction_factor = 10
  )
  expect_true(is.finite(risk))

  vol <- coshh_classify_volatility(
    boiling_point = 111,
    process_temp = 20
  )
  expect_false(is.na(vol))
})


test_that("trivial floating-point noise does not materially change UNE-EN 689 summaries", {
  x <- c(5, 6, 7, 8, 9, 10)
  noise <- seq_along(x) * .Machine$double.eps
  y <- x + noise

  a <- une689_statistics(x)
  b <- une689_statistics(y)

  expect_equal(a$MA, b$MA, tolerance = 1e-12)
  expect_equal(a$DS, b$DS, tolerance = 1e-12)
  expect_equal(a$MG, b$MG, tolerance = 1e-12)
  expect_equal(a$DSG, b$DSG, tolerance = 1e-12)
})


test_that("trivial floating-point noise does not change COSHH volatility classification", {
  base <- coshh_classify_volatility(
    boiling_point = 111,
    process_temp = 20
  )

  perturbed <- coshh_classify_volatility(
    boiling_point = 111 + .Machine$double.eps,
    process_temp = 20 + .Machine$double.eps
  )

  expect_identical(base, perturbed)
})
