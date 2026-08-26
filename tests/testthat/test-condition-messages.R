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
