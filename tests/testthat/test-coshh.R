test_that("coshh_classify_volatility classifies correctly in English (default)", {
  expect_equal(coshh_classify_volatility(t_ebullicion = 111, t_proceso = 20), "Medium")
  expect_equal(coshh_classify_volatility(t_ebullicion = 56,  t_proceso = 40), "High")
  expect_equal(coshh_classify_volatility(t_ebullicion = 300, t_proceso = 20), "Low")
})

test_that("coshh_classify_volatility classifies correctly in Spanish", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_equal(coshh_classify_volatility(t_ebullicion = 111, t_proceso = 20), "Media")
  expect_equal(coshh_classify_volatility(t_ebullicion = 56,  t_proceso = 40), "Alta")
  expect_equal(coshh_classify_volatility(t_ebullicion = 300, t_proceso = 20), "Baja")
})

test_that("coshh_classify_volatility requires numeric inputs without NA", {
  expect_error(coshh_classify_volatility(NA, 20))
  expect_error(coshh_classify_volatility("111", 20))
})

test_that("coshh_grade assigns the correct grade from H or R phrases", {
  expect_equal(coshh_grade("H315, H319"), "A")
  expect_equal(coshh_grade("R23/24/25"),  "C")
  expect_equal(coshh_grade("H315, R26/27/28"), "D")
})

test_that("coshh_grade applies the default rule (grade A) for unlisted phrases", {
  expect_equal(coshh_grade("H999"), "A")
})

test_that("coshh_grade returns NA for empty inputs", {
  expect_true(is.na(coshh_grade(NA)))
  expect_true(is.na(coshh_grade("")))
})

test_that("coshh_risk queries the risk matrix correctly in English", {
  expect_equal(coshh_risk("C", "Medium", "High"), 3L)
  expect_equal(coshh_risk("E", "Small",  "Low"),  4L)
})

test_that("coshh_risk accepts Spanish labels too", {
  expect_equal(coshh_risk("C", "Mediana", "Alta"), 3L)
})

test_that("coshh_risk returns NA for undefined combinations or NA grade", {
  expect_true(is.na(coshh_risk("A", "Large", "Low")))
  expect_true(is.na(coshh_risk(NA_character_, "Large", "Low")))
})

test_that("coshh_measures returns the correct text in English and Spanish", {
  expect_match(coshh_measures(3), "Containment")
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_match(coshh_measures(3), "Confinamiento")
})

test_that("coshh_measures returns NA for NA input", {
  expect_true(is.na(coshh_measures(NA)))
})

test_that("coshh_evaluate chains the full workflow for a liquid", {
  res <- coshh_evaluate(
    nombre = "Toluene", frases = "H315, H336",
    cantidad = "Medium", es_liquido = TRUE,
    t_ebullicion = 111, t_proceso = 20
  )
  expect_equal(res$grado,       "A")
  expect_equal(res$volatilidad, "Medium")
  expect_equal(res$riesgo,      1L)
  expect_match(res$medidas,     "ventilation")
})

test_that("coshh_evaluate chains the full workflow for a solid", {
  res <- coshh_evaluate(
    nombre = "Cement dust", frases = "H315",
    cantidad = "Large", es_liquido = FALSE,
    pulverulencia = "High"
  )
  expect_equal(res$grado,       "A")
  expect_equal(res$volatilidad, "High")
  expect_equal(res$riesgo,      2L)
})
