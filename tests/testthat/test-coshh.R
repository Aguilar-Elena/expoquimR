test_that("coshh_clasificar_volatilidad clasifica correctamente", {
  # Tebullicion > 2*Tproceso + 10 pero <= 5*Tproceso + 50 -> Media
  expect_equal(coshh_clasificar_volatilidad(111, 20), "Media")
  # Tebullicion <= 2*Tproceso + 10 -> Alta
  expect_equal(coshh_clasificar_volatilidad(56, 40), "Alta")
  # Tebullicion > 5*Tproceso + 50 -> Baja
  expect_equal(coshh_clasificar_volatilidad(300, 20), "Baja")
})

test_that("coshh_clasificar_volatilidad exige inputs numericos y sin NA", {
  expect_error(coshh_clasificar_volatilidad(NA, 20))
  expect_error(coshh_clasificar_volatilidad("111", 20))
})

test_that("coshh_grado asigna el grado correcto por frase H o R", {
  expect_equal(coshh_grado("H315, H319"), "A")
  expect_equal(coshh_grado("R23/24/25"), "C")
  # Se queda con el grado mas desfavorable de varias frases
  expect_equal(coshh_grado("H315, R26/27/28"), "D")
})

test_that("coshh_grado aplica la regla por defecto (grado A) a frases no listadas", {
  expect_equal(coshh_grado("H999"), "A")
})

test_that("coshh_grado devuelve NA para entradas vacias", {
  expect_true(is.na(coshh_grado(NA)))
  expect_true(is.na(coshh_grado("")))
})

test_that("coshh_riesgo consulta correctamente la matriz de riesgo", {
  expect_equal(coshh_riesgo("C", "Mediana", "Alta"), 3L)
  # Grado E es siempre riesgo maximo, con independencia de cantidad/volatilidad
  expect_equal(coshh_riesgo("E", "Pequeña", "Baja"), 4L)
})

test_that("coshh_riesgo devuelve NA para combinaciones no definidas o grado NA", {
  expect_true(is.na(coshh_riesgo("A", "Grande", "Baja")))
  expect_true(is.na(coshh_riesgo(NA_character_, "Grande", "Baja")))
})

test_that("coshh_medidas devuelve el texto correcto por nivel de riesgo", {
  expect_match(coshh_medidas(3), "Confinamiento")
  expect_true(is.na(coshh_medidas(NA)))
})

test_that("coshh_evaluar encadena todo el flujo para un liquido", {
  res <- coshh_evaluar(
    nombre = "Tolueno",
    frases = "H315, H336",
    cantidad = "Mediana",
    es_liquido = TRUE,
    t_ebullicion = 111,
    t_proceso = 20
  )
  expect_equal(res$grado, "A")
  expect_equal(res$volatilidad, "Media")
  expect_equal(res$riesgo, 1L)
  expect_match(res$medidas, "Ventilacion general")
})

test_that("coshh_evaluar encadena todo el flujo para un solido", {
  res <- coshh_evaluar(
    nombre = "Cemento en polvo",
    frases = "H315",
    cantidad = "Grande",
    es_liquido = FALSE,
    pulverulencia = "Alta"
  )
  expect_equal(res$grado, "A")
  expect_equal(res$volatilidad, "Alta")
  expect_equal(res$riesgo, 2L)
})
