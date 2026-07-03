test_that("inrs_clase_cantidad classifies by unit", {
  expect_equal(inrs_clase_cantidad(50, "g"), "1")
  expect_equal(inrs_clase_cantidad(5000, "ml"), "2")
  expect_equal(inrs_clase_cantidad(15000, "g"), "3")
  expect_equal(inrs_clase_cantidad(5, "l"), "2")
  expect_equal(inrs_clase_cantidad(500, "kg"), "4")
  expect_equal(inrs_clase_cantidad(5000, "l"), "5")
  expect_true(is.na(inrs_clase_cantidad(NA, "g")))
})

test_that("inrs_clase_frecuencia converts and classifies correctly", {
  expect_equal(inrs_clase_frecuencia(3, "horas"), "3")
  expect_equal(inrs_clase_frecuencia(90, "minutos"), "2")  # 90 min = 1.5 h
  expect_equal(inrs_clase_frecuencia(unidad = "no_se_usa"), "0")
  expect_true(is.na(inrs_clase_frecuencia(NA, "horas")))
})

test_that("inrs_clase_peligro prioritises VLA and H/R phrases, falls back to class 1", {
  expect_equal(inrs_clase_peligro(frases_h = "H336"), "2")
  expect_equal(inrs_clase_peligro(vla = 0.05), "5")
  expect_equal(inrs_clase_peligro(vla = 200), "1")
  expect_true(is.na(inrs_clase_peligro()))
})

test_that("inrs_clase_exposicion_potencial and riesgo_potencial query the tables correctly", {
  expect_equal(inrs_clase_exposicion_potencial("2", "3"), "2")
  expect_equal(inrs_clase_riesgo_potencial("2", "2"), "1")
  expect_equal(inrs_puntuacion_riesgo_potencial("1"), 1)
  expect_equal(inrs_puntuacion_riesgo_potencial("5"), 10000)
})

test_that("inrs_volatilidad_liquido_grafico uses the official INRS graph lines", {
  expect_equal(inrs_volatilidad_liquido_grafico(20, 200), "1")
  expect_equal(inrs_volatilidad_liquido_grafico(20, 130), "2")
  expect_equal(inrs_volatilidad_liquido_grafico(20, 80),  "3")
})

test_that("inrs_volatilidad_liquido_presion uses the official Table 8 thresholds", {
  expect_equal(inrs_volatilidad_liquido_presion(0.2), "1")
  expect_equal(inrs_volatilidad_liquido_presion(15),  "2")
  expect_equal(inrs_volatilidad_liquido_presion(30),  "3")
})

test_that("inrs_pulverulencia_solido maps the three valid descriptions", {
  expect_equal(inrs_pulverulencia_solido("Solido compacto sin polvo visible"), "1")
  expect_true(is.na(inrs_pulverulencia_solido("Invalid description")))
})

test_that("inrs_procedimiento and inrs_proteccion return class and score", {
  proc <- inrs_procedimiento("Abierto")
  expect_equal(proc$clase, "3")
  expect_equal(proc$puntuacion, 0.5)

  prot <- inrs_proteccion("Condiciones moderadas de dispersion")
  expect_equal(prot$clase, "3")
  expect_equal(prot$puntuacion, 0.7)
})

test_that("inrs_fc_vla classifies VLA thresholds correctly", {
  expect_equal(inrs_fc_vla(50),     1)
  expect_equal(inrs_fc_vla(0.05),   10)
  expect_equal(inrs_fc_vla(0.005),  30)
  expect_equal(inrs_fc_vla(0.0005), 100)
})

test_that("inrs_riesgo_inhalacion and inrs_caracterizacion are consistent in English (default)", {
  expect_equal(inrs_riesgo_inhalacion(1, 1, 0.5, 0.7, 1), 0.35)
  expect_true(is.na(inrs_riesgo_inhalacion(1, NA, 0.5, 0.7, 1)))
  expect_match(inrs_caracterizacion(0.35), "low")
  expect_match(inrs_caracterizacion(500),  "Moderate")
  expect_match(inrs_caracterizacion(5000), "Very high")
})

test_that("inrs_caracterizacion returns Spanish text when lang = 'es'", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_match(inrs_caracterizacion(0.35), "bajo")
  expect_match(inrs_caracterizacion(500),  "moderado")
  expect_match(inrs_caracterizacion(5000), "muy elevado")
})

test_that("inrs_evaluar chains the full workflow correctly", {
  res <- inrs_evaluar(
    nombre = "Solvent X",
    frases_h = "H336",
    vla = 50,
    cantidad_valor = 5, cantidad_unidad = "l",
    frecuencia_valor = 3, frecuencia_unidad = "horas",
    tipo_sustancia = "liquida",
    metodo_liquido = "grafico",
    temperatura_uso = 40, punto_ebullicion = 80,
    procedimiento = "Abierto",
    proteccion = "Condiciones moderadas de dispersion"
  )

  expect_equal(res$clase_peligro, "2")
  expect_equal(res$clase_cantidad, "2")
  expect_equal(res$clase_frecuencia, "3")
  expect_equal(res$clase_exposicion_potencial, "2")
  expect_equal(res$clase_riesgo_potencial, "1")
  expect_equal(res$clase_volatilidad_pulverulencia, "3")
  expect_equal(res$riesgo_inhalacion, 35)
  expect_match(res$caracterizacion_riesgo, "low")
})
