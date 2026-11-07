# ---- rOpenSci statistical standards ----
#' @srrstats {EA4.0} Analytical functions return stable and predictable types appropriate to their inputs and calculations; scalar classifications, numeric statistics, data-frame outputs, and structured list outputs are explicitly tested for type consistency.
#' @srrstats {EA6.0} Return values from the analytical API are explicitly tested for structure, type, dimensions, names, column types, and numerical values as appropriate.
#' @srrstats {EA6.0a} Tests explicitly verify classes and types of returned lists, data frames, scalar values, and their principal components.
#' @srrstats {EA6.0b} Dimensions of tabular outputs are explicitly tested for the COSHH, INRS, and UNE-EN 689 analytical wrappers.
#' @srrstats {EA6.0c} Column and component names of structured return objects are explicitly tested.
#' @srrstats {EA6.0d} Column types of principal data.frame outputs are explicitly tested to ensure stable return structures.
#' @srrstats {EA6.0e} Tests of single-valued numeric outputs use explicit numerical tolerances; categorical and integer-valued outputs are tested using exact equality as appropriate.
# ---- end rOpenSci statistical standards ----

test_that("COSHH evaluation has stable return structure", {
  res <- coshh_evaluate(
    name = "Toluene",
    phrases = "H315, H336",
    quantity = "Medium",
    is_liquid = TRUE,
    boiling_point = 111,
    process_temp = 20
  )

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)

  expect_named(
    res,
    c(
      "substance",
      "phrases",
      "grade",
      "volatility",
      "quantity",
      "risk",
      "measures"
    )
  )

  expect_type(res$substance, "character")
  expect_type(res$phrases, "character")
  expect_type(res$grade, "character")
  expect_type(res$volatility, "character")
  expect_type(res$quantity, "character")
  expect_type(res$risk, "integer")
  expect_type(res$measures, "character")
})


test_that("INRS evaluation has stable tabular structure", {
  res <- inrs_evaluate(
    name = "Solvent X",
    h_phrases = "H336",
    vla = 50,
    quantity_value = 5000,
    quantity_unit = "ml",
    frequency_value = 3,
    frequency_unit = "hours",
    substance_type = "liquid",
    liquid_method = "graph",
    use_temperature = 20,
    boiling_point = 80,
    procedure = "closed process, periodically opened",
    protection = "local exhaust ventilation"
  )

  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)

  expect_true(all(c(
    "hazard_class",
    "quantity_class",
    "frequency_class",
    "potential_exposure_class",
    "potential_risk_class",
    "volatility_dustiness_class",
    "inhalation_risk"
  ) %in% names(res)))

  expect_type(res$hazard_class, "character")
  expect_type(res$quantity_class, "character")
  expect_type(res$frequency_class, "character")
  expect_type(res$potential_exposure_class, "character")
  expect_type(res$potential_risk_class, "character")
  expect_type(res$volatility_dustiness_class, "character")
  expect_type(res$inhalation_risk, "double")
})


test_that("UNE-EN 689 preliminary wrapper has stable structure", {
  dat <- data.frame(
    day = c(1, 1, 2, 3, 3),
    concentration = c(12, 8, 9, 5, 6),
    time = c(4, 4, 8, 3, 5)
  )

  res <- une689_evaluate_preliminary(dat, vla = 10)

  expect_type(res, "list")
  expect_named(res, c("days_table", "result"))

  expect_s3_class(res$days_table, "data.frame")
  expect_named(res$days_table, c("day", "ED", "IE"))
  expect_equal(nrow(res$days_table), 3L)

  expect_type(res$days_table$day, "double")
  expect_type(res$days_table$ED, "double")
  expect_type(res$days_table$IE, "double")
  expect_type(res$result, "character")
})


test_that("UNE-EN 689 statistical wrapper has stable structure", {
  res <- une689_evaluate_statistical(
    c(5, 6, 7, 8, 9, 10),
    vla = 10
  )

  expect_type(res, "list")

  expect_named(
    res,
    c(
      "n",
      "distribution_type",
      "MA",
      "DS",
      "MG",
      "DSG",
      "W_normal",
      "pval_normal",
      "W_lognormal",
      "pval_lognormal",
      "ut",
      "lsc",
      "ur",
      "conformity"
    )
  )

  expect_type(res$n, "integer")
  expect_type(res$distribution_type, "character")

  numeric_fields <- c(
    "MA", "DS", "MG", "DSG",
    "W_normal", "pval_normal",
    "W_lognormal", "pval_lognormal",
    "ut", "lsc", "ur"
  )

  for (nm in numeric_fields) {
    expect_type(res[[nm]], "double")
  }

  expect_type(res$conformity, "character")
})
