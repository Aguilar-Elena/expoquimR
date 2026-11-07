# ---- rOpenSci statistical standards ----
#' @srrstats {G5.2} Error and message behaviour is explicitly exercised through the test suite, including validation failures, Excel-import failures, report input validation, Shiny application lookup, graphical argument validation, and UNE-EN 689 statistical preconditions.
#' @srrstats {G5.2a} Package-generated conditions have been audited across the R source tree; 41 stop/message expressions were identified and all 41 are unique, with importer-specific prefixes used where otherwise similar dependency or missing-column errors could be ambiguous.
#' @srrstats {G5.2b} Explicit tests verify expected error or message text for core validation conditions and representative package-generated conditions, including numeric validation, tabular normalisation, graphical arguments, Excel structure, language handling, report validation, Shiny application lookup, and UNE-EN 689 sample-size requirements.
# ---- end rOpenSci statistical standards ----

test_that("plotting helper identifies invalid label arguments", {
  expect_error(
    expoquimR:::.une689_density_plot(
      eds = c(1, 2, 3),
      center = 2,
      vla = 5,
      lsc = 4,
      center_label = ""
    ),
    "`center_label` must be a non-empty character scalar",
    fixed = TRUE
  )

  expect_error(
    expoquimR:::.une689_density_plot(
      eds = c(1, 2, 3),
      center = 2,
      vla = 5,
      lsc = 4,
      vla_label = ""
    ),
    "`vla_label` must be a non-empty character scalar",
    fixed = TRUE
  )

  expect_error(
    expoquimR:::.une689_density_plot(
      eds = c(1, 2, 3),
      center = 2,
      vla = 5,
      lsc = 4,
      lsc_label = ""
    ),
    "`lsc_label` must be a non-empty character scalar",
    fixed = TRUE
  )
})


test_that("Excel readers identify missing required columns", {
  skip_if_not_installed("readxl")

  coshh_path <- system.file(
    "plantillas",
    "plantilla_coshh.xlsx",
    package = "expoquimR"
  )

  inrs_path <- system.file(
    "plantillas",
    "plantilla_inrs.xlsx",
    package = "expoquimR"
  )

  expect_error(
    coshh_from_excel(inrs_path, sheet = "INRS_datos"),
    "coshh_from_excel: Missing required columns"
  )

  expect_error(
    inrs_from_excel(coshh_path, sheet = "COSHH_datos"),
    "inrs_from_excel: Missing required columns"
  )
})


test_that("UNE-EN 689 Excel reader identifies missing Agents sheet", {
  skip_if_not_installed("readxl")

  coshh_path <- system.file(
    "plantillas",
    "plantilla_coshh.xlsx",
    package = "expoquimR"
  )

  expect_error(
    une689_from_excel(coshh_path),
    "Sheet 'Agents' not found"
  )
})


test_that("UNE-EN 689 normality length error is explicit", {
  expect_error(
    une689_normality_test(c(1, 2)),
    "between 3 and 5000 observations"
  )
})
