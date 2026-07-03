test_that("inrs_clase_cantidad clasifica por unidad", {
  expect_equal(inrs_clase_cantidad(50, "g"), "1")
  expect_equal(inrs_clase_cantidad(5000, "ml"), "2")
  expect_equal(inrs_clase_cantidad(15000, "g"), "3")
  expect_equal(inrs_clase_cantidad(5, "l"), "2")
  expect_equal(inrs_clase_cantidad(500, "kg"), "4")
  expect_equal(inrs_clase_cantidad(5000, "l"), "5")
  expect_true(is.na(inrs_clase_cantidad(NA, "g")))
})

test_that("inrs_clase_frecuencia convierte y clasifica correctamente", {
  expect_equal(inrs_clase_frecuencia(3, "horas"), "3")
  expect_equal(inrs_clase_frecuencia(90, "minutos"), "2")  # 90 min = 1.5 h
  expect_equal(inrs_clase_frecuencia(unidad = "no_se_usa"), "0")
  expect_true(is.na(inrs_clase_frecuencia(NA, "horas")))
})

test_that("inrs_clase_peligro prioriza VLA y frases H/R, y cae en clase 1 por defecto", {
  expect_equal(inrs_clase_peligro(frases_h = "H336"), "2")
  expect_equal(inrs_clase_peligro(vla = 0.05), "5")
  # Nada coincide con las clases 2-5 -> clase 1 por defecto (cajon de sastre)
  expect_equal(inrs_clase_peligro(vla = 200), "1")
  # Sin ningun criterio en absoluto -> no hay info para clasificar
  expect_true(is.na(inrs_clase_peligro()))
})

test_that("inrs_clase_exposicion_potencial y riesgo_potencial consultan bien la tabla", {
  expect_equal(inrs_clase_exposicion_potencial("2", "3"), "2")
  expect_equal(inrs_clase_riesgo_potencial("2", "2"), "1")
  expect_equal(inrs_puntuacion_riesgo_potencial("1"), 1)
  expect_equal(inrs_puntuacion_riesgo_potencial("5"), 10000)
})

test_that("inrs_volatilidad_liquido_grafico usa las rectas oficiales del grafico INRS", {
  # T_proc = 20: linea1 ~= 92.7, linea2 ~= 161.4
  expect_equal(inrs_volatilidad_liquido_grafico(20, 200), "1")  # por encima de linea2 -> baja
  expect_equal(inrs_volatilidad_liquido_grafico(20, 130), "2")  # entre las dos rectas -> media
  expect_equal(inrs_volatilidad_liquido_grafico(20, 80),  "3")  # por debajo de linea1 -> alta
})

test_that("inrs_volatilidad_liquido_presion usa los umbrales oficiales de la Tabla 8", {
  expect_equal(inrs_volatilidad_liquido_presion(0.2), "1")
  expect_equal(inrs_volatilidad_liquido_presion(15), "2")
  expect_equal(inrs_volatilidad_liquido_presion(30), "3")
})

test_that("inrs_pulverulencia_solido mapea las tres descripciones validas", {
  expect_equal(inrs_pulverulencia_solido("Solido compacto sin polvo visible"), "1")
  expect_true(is.na(inrs_pulverulencia_solido("Descripcion inventada")))
})

test_that("inrs_procedimiento e inrs_proteccion devuelven clase y puntuacion", {
  proc <- inrs_procedimiento("Abierto")
  expect_equal(proc$clase, "3")
  expect_equal(proc$puntuacion, 0.5)

  prot <- inrs_proteccion("Condiciones moderadas de dispersion")
  expect_equal(prot$clase, "3")
  expect_equal(prot$puntuacion, 0.7)
})

test_that("inrs_fc_vla clasifica los umbrales de la Tabla 11", {
  expect_equal(inrs_fc_vla(50), 1)
  expect_equal(inrs_fc_vla(0.05), 10)
  expect_equal(inrs_fc_vla(0.005), 30)
  expect_equal(inrs_fc_vla(0.0005), 100)
})

test_that("inrs_riesgo_inhalacion y caracterizacion son consistentes", {
  expect_equal(inrs_riesgo_inhalacion(1, 1, 0.5, 0.7, 1), 0.35)
  expect_true(is.na(inrs_riesgo_inhalacion(1, NA, 0.5, 0.7, 1)))
  expect_match(inrs_caracterizacion(0.35), "bajo")
  expect_match(inrs_caracterizacion(500), "moderado")
  expect_match(inrs_caracterizacion(5000), "muy elevado")
})

test_that("inrs_evaluar encadena todo el flujo correctamente", {
  res <- inrs_evaluar(
    nombre = "Disolvente X",
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
  # T_proc=40: linea1 ~= 115.3, punto_ebullicion=80 -> por debajo -> clase "3" (alta)
  expect_equal(res$clase_volatilidad_pulverulencia, "3")
  expect_equal(res$riesgo_inhalacion, 35)
  expect_match(res$caracterizacion_riesgo, "bajo")
})
