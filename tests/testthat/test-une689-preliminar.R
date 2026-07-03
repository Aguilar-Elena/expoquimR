test_that("une689_ed_jornada calcula el caso general (promedio ponderado / 8h)", {
  expect_equal(une689_ed_jornada(c(12, 8), c(4, 4)), 10)
  expect_equal(une689_ed_jornada(c(5, 6), c(3, 5)), 45 / 8)
})

test_that("une689_ed_jornada aplica el caso especial de muestra unica de 8h", {
  expect_equal(une689_ed_jornada(9, 8), 9)
  # Una unica muestra pero de menos de 8h SI usa la formula general
  expect_equal(une689_ed_jornada(9, 4), 9 * 4 / 8)
})

test_that("une689_ed_jornada ignora parejas con NA y devuelve NA sin datos", {
  expect_equal(une689_ed_jornada(c(12, NA), c(4, NA)), 12 * 4 / 8)
  expect_true(is.na(une689_ed_jornada(NA_real_, NA_real_)))
})

test_that("une689_ie_jornada divide ED entre VLA y valida VLA > 0", {
  expect_equal(une689_ie_jornada(9, 10), 0.9)
  expect_true(is.na(une689_ie_jornada(9, NA)))
  expect_true(is.na(une689_ie_jornada(9, 0)))
  expect_true(is.na(une689_ie_jornada(NA, 10)))
})

test_that("une689_clasificar_conformidad clasifica los 3 casos normales", {
  expect_equal(une689_clasificar_conformidad(c(0.02, 0.05)), "CONFORMIDAD")
  expect_equal(une689_clasificar_conformidad(c(1, 0.9, 0.5625)), "NO DECISION")
  expect_equal(une689_clasificar_conformidad(c(1.2, 0.05)), "NO CONFORMIDAD")
})

test_that("une689_clasificar_conformidad NO declara conformidad falsa sin datos", {
  # Caso corregido respecto a la app original (ver documentacion de la funcion)
  expect_true(is.na(une689_clasificar_conformidad(c(NA_real_, NA_real_))))
  expect_true(is.na(une689_clasificar_conformidad(numeric(0))))
})

test_that("une689_validar_min_jornadas exige el minimo de jornadas", {
  expect_false(une689_validar_min_jornadas(2))
  expect_true(une689_validar_min_jornadas(3))
  expect_true(une689_validar_min_jornadas(5, minimo = 3))
})

test_that("une689_evaluar_preliminar calcula ED/IE por jornada y clasifica el conjunto", {
  datos <- data.frame(
    jornada = c(1, 1, 2, 3, 3),
    concentracion = c(12, 8, 9, 5, 6),
    tiempo = c(4, 4, 8, 3, 5)
  )
  res <- une689_evaluar_preliminar(datos, vla = 10)

  expect_equal(nrow(res$tabla_jornadas), 3)
  expect_equal(res$tabla_jornadas$ED, c(10, 9, 45 / 8))
  expect_equal(res$tabla_jornadas$IE, c(1, 0.9, 45 / 80))
  expect_equal(res$resultado, "NO DECISION")
})

test_that("une689_evaluar_preliminar detecta NO CONFORMIDAD", {
  datos <- data.frame(
    jornada = c(1, 2, 3),
    concentracion = c(15, 8, 6),
    tiempo = c(8, 8, 8)
  )
  res <- une689_evaluar_preliminar(datos, vla = 10)
  expect_equal(res$resultado, "NO CONFORMIDAD")
})
