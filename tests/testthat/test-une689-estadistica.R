test_that("une689_ut consulta la tabla y aplica el limite para n > 30", {
  expect_equal(une689_ut(6), 2.187)
  expect_equal(une689_ut(30), 1.820)
  expect_equal(une689_ut(50), 1.820)
  expect_true(is.na(une689_ut(5)))
})

test_that("une689_estadisticos calcula MA/DS/MG/DSG con las formulas correctas", {
  ed <- c(5, 6, 7, 8, 9, 10)
  res <- une689_estadisticos(ed)
  expect_equal(res$MA, mean(ed))
  expect_equal(res$DS, sd(ed))
  expect_equal(res$MG, exp(mean(log(ed))))
  expect_equal(res$DSG, exp(sd(log(ed))))
})

test_that("une689_estadisticos exige valores positivos y sin NA", {
  expect_error(une689_estadisticos(c(5, NA, 7)))
  expect_error(une689_estadisticos(c(5, -1, 7)))
})

test_that("une689_test_normalidad devuelve estadisticos con estructura correcta", {
  ed <- c(5, 6, 7, 8, 9, 10)
  res <- une689_test_normalidad(ed)
  expect_named(res, c("W_normal", "pval_normal", "W_lognormal", "pval_lognormal"))
  expect_true(res$pval_normal >= 0 && res$pval_normal <= 1)
  expect_true(res$pval_lognormal >= 0 && res$pval_lognormal <= 1)
})

test_that("une689_tipo_distribucion prioriza lognormal sobre normal", {
  expect_equal(une689_tipo_distribucion(pval_normal = 0.5, pval_lognormal = 0.5), "Lognormal")
  expect_equal(une689_tipo_distribucion(pval_normal = 0.5, pval_lognormal = 0.01), "Normal")
  expect_equal(une689_tipo_distribucion(pval_normal = 0.01, pval_lognormal = 0.01), "Ninguna")
})

test_that("une689_lsc y une689_ur calculan segun el tipo de distribucion", {
  expect_equal(une689_lsc("Normal", ut = 2, MA = 7.5, DS = 1.87), 7.5 + 2 * 1.87)
  expect_equal(une689_lsc("Lognormal", ut = 2, MG = 7.3, DSG = 1.3), 7.3 * 1.3^2)
  expect_true(is.na(une689_lsc("Ninguna", ut = 2)))

  expect_equal(une689_ur("Normal", vla = 10, MA = 7.5, DS = 1.87), (10 - 7.5) / 1.87)
  expect_equal(une689_ur("Lognormal", vla = 10, MG = 7.3, DSG = 1.3), (log(10) - log(7.3)) / log(1.3))
  expect_true(is.na(une689_ur("Ninguna", vla = 10)))
})

test_that("une689_conformidad_estadistica compara UR contra UT", {
  expect_equal(une689_conformidad_estadistica(ur = 2.5, ut = 2.005), "CONFORMIDAD")
  expect_equal(une689_conformidad_estadistica(ur = 1.5, ut = 2.005), "NO CONFORMIDAD")
  expect_true(is.na(une689_conformidad_estadistica(ur = NA_real_, ut = 2.005)))
})

test_that("une689_evaluar_estadistica exige un minimo de 6 valores de ED", {
  expect_error(une689_evaluar_estadistica(c(5, 6, 7), vla = 10))
})

test_that("une689_evaluar_estadistica devuelve una estructura completa y coherente", {
  ed <- c(5, 6, 7, 8, 9, 10)
  res <- une689_evaluar_estadistica(ed, vla = 10)

  expect_equal(res$n, 6)
  expect_equal(res$ut, une689_ut(6))
  expect_true(res$tipo %in% c("Lognormal", "Normal", "Ninguna"))
  # El UR y el LSC deben ser coherentes con el tipo detectado
  if (res$tipo == "Ninguna") {
    expect_true(is.na(res$ur))
    expect_true(is.na(res$lsc))
    expect_true(is.na(res$conformidad))
  } else {
    expect_false(is.na(res$ur))
    expect_false(is.na(res$lsc))
    expect_true(res$conformidad %in% c("CONFORMIDAD", "NO CONFORMIDAD"))
  }
})

test_that("une689_periodicidad_opcion1 clasifica los 4 tramos", {
  expect_match(une689_periodicidad_opcion1(0.5, vla = 10), "36 meses")
  expect_match(une689_periodicidad_opcion1(2, vla = 10), "24 meses")
  expect_match(une689_periodicidad_opcion1(4, vla = 10), "18 meses")
  expect_match(une689_periodicidad_opcion1(8, vla = 10), "12 meses")
})

test_that("une689_periodicidad_opcion2 clasifica los 3 tramos y el aviso final", {
  expect_match(une689_periodicidad_opcion2(2, vla = 10), "36 meses")
  expect_match(une689_periodicidad_opcion2(4, vla = 10), "30 meses")
  expect_match(une689_periodicidad_opcion2(8, vla = 10), "24 meses")
  expect_match(une689_periodicidad_opcion2(11, vla = 10), "No recomendable")
})
