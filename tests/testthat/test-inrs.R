test_that("inrs_quantity_class classifies by unit", {
  expect_equal(inrs_quantity_class(50, "g"), "1")
  expect_equal(inrs_quantity_class(5000, "ml"), "2")
  expect_equal(inrs_quantity_class(15000, "g"), "3")
  expect_equal(inrs_quantity_class(5, "l"), "2")
  expect_equal(inrs_quantity_class(500, "kg"), "4")
  expect_equal(inrs_quantity_class(5000, "l"), "5")
  expect_true(is.na(inrs_quantity_class(NA, "g")))
})

test_that("inrs_frequency_class converts and classifies correctly", {
  expect_equal(inrs_frequency_class(3, "hours"), "3")
  expect_equal(inrs_frequency_class(90, "minutes"), "2")  # 90 min = 1.5 h
  expect_equal(inrs_frequency_class(unit = "not_used"), "0")
  expect_true(is.na(inrs_frequency_class(NA, "hours")))
})

test_that("inrs_hazard_class prioritises VLA and H/R phrases, falls back to class 1", {
  expect_equal(inrs_hazard_class(h_phrases = "H336"), "2")
  expect_equal(inrs_hazard_class(vla = 0.05), "5")
  expect_equal(inrs_hazard_class(vla = 200), "1")
  expect_true(is.na(inrs_hazard_class()))
})

test_that("inrs_potential_exposure_class and potential_risk_class query the tables correctly", {
  expect_equal(inrs_potential_exposure_class("2", "3"), "2")
  expect_equal(inrs_potential_risk_class("2", "2"), "1")
  expect_equal(inrs_potential_risk_score("1"), 1)
  expect_equal(inrs_potential_risk_score("5"), 10000)
})

test_that("inrs_liquid_volatility_graph uses the official INRS graph lines", {
  expect_equal(inrs_liquid_volatility_graph(20, 200), "1")
  expect_equal(inrs_liquid_volatility_graph(20, 130), "2")
  expect_equal(inrs_liquid_volatility_graph(20, 80),  "3")
})

test_that("inrs_liquid_volatility_pressure uses the official Table 8 thresholds", {
  expect_equal(inrs_liquid_volatility_pressure(0.2), "1")
  expect_equal(inrs_liquid_volatility_pressure(15),  "2")
  expect_equal(inrs_liquid_volatility_pressure(30),  "3")
})

test_that("inrs_solid_dustiness maps the three valid descriptions", {
  expect_equal(inrs_solid_dustiness("Compact solid with no visible dust"), "1")
  expect_true(is.na(inrs_solid_dustiness("Invalid description")))
})

test_that("inrs_process_type and inrs_collective_protection return class and score", {
  proc <- inrs_process_type("Open")
  expect_equal(proc$class, "3")
  expect_equal(proc$score, 0.5)

  prot <- inrs_collective_protection("Moderate dispersion conditions")
  expect_equal(prot$class, "3")
  expect_equal(prot$score, 0.7)
})

test_that("inrs_oel_correction_factor classifies VLA thresholds correctly", {
  expect_equal(inrs_oel_correction_factor(50),     1)
  expect_equal(inrs_oel_correction_factor(0.05),   10)
  expect_equal(inrs_oel_correction_factor(0.005),  30)
  expect_equal(inrs_oel_correction_factor(0.0005), 100)
})

test_that("inrs_inhalation_risk and inrs_risk_characterisation are consistent in English (default)", {
  expect_equal(inrs_inhalation_risk(1, 1, 0.5, 0.7, 1), 0.35)
  expect_true(is.na(inrs_inhalation_risk(1, NA, 0.5, 0.7, 1)))
  expect_match(inrs_risk_characterisation(0.35), "low")
  expect_match(inrs_risk_characterisation(500),  "Moderate")
  expect_match(inrs_risk_characterisation(5000), "Very high")
})

test_that("inrs_risk_characterisation returns Spanish text when lang = 'es'", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_match(inrs_risk_characterisation(0.35), "bajo")
  expect_match(inrs_risk_characterisation(500),  "moderado")
  expect_match(inrs_risk_characterisation(5000), "muy elevado")
})

test_that("inrs_evaluate chains the full workflow correctly", {
  res <- inrs_evaluate(
    name = "Solvent X",
    h_phrases = "H336",
    vla = 50,
    quantity_value = 5, quantity_unit = "l",
    frequency_value = 3, frequency_unit = "hours",
    substance_type = "liquid",
    liquid_method = "graph",
    use_temperature = 40, boiling_point = 80,
    procedure = "Open",
    protection = "Moderate dispersion conditions"
  )

  expect_equal(res$hazard_class, "2")
  expect_equal(res$quantity_class, "2")
  expect_equal(res$frequency_class, "3")
  expect_equal(res$potential_exposure_class, "2")
  expect_equal(res$potential_risk_class, "1")
  expect_equal(res$volatility_dustiness_class, "3")
  expect_equal(res$inhalation_risk, 35)
  expect_match(res$risk_characterisation, "low")
})
