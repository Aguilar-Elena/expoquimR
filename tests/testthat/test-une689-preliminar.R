test_that("une689_daily_exposure calculates the general case (weighted average / 8h)", {
  expect_equal(une689_daily_exposure(c(12, 8), c(4, 4)), 10)
  expect_equal(une689_daily_exposure(c(5, 6),  c(3, 5)), 45 / 8)
})

test_that("une689_daily_exposure applies the special case for a single 8h sample", {
  expect_equal(une689_daily_exposure(9, 8), 9)
  expect_equal(une689_daily_exposure(9, 4), 9 * 4 / 8)
})

test_that("une689_daily_exposure ignores NA pairs and returns NA with no data", {
  expect_equal(une689_daily_exposure(c(12, NA), c(4, NA)), 12 * 4 / 8)
  expect_true(is.na(une689_daily_exposure(NA_real_, NA_real_)))
})

test_that("une689_exposure_index divides ED by VLA and validates VLA > 0", {
  expect_equal(une689_exposure_index(9, 10), 0.9)
  expect_true(is.na(une689_exposure_index(9,  NA)))
  expect_true(is.na(une689_exposure_index(9,  0)))
  expect_true(is.na(une689_exposure_index(NA, 10)))
})

test_that("une689_classify_conformity classifies the 3 normal cases in English", {
  expect_equal(une689_classify_conformity(c(0.02, 0.05)),
               .t("une689_conformity"))
  expect_equal(une689_classify_conformity(c(1, 0.9, 0.5625)),
               .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(1.2, 0.05)),
               .t("une689_no_conformity"))
})

test_that("une689_classify_conformity returns Spanish labels when lang = 'es'", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_equal(une689_classify_conformity(c(0.02, 0.05)), "CONFORMIDAD")
  expect_equal(une689_classify_conformity(c(1.2, 0.05)),  "NO CONFORMIDAD")
})

test_that("une689_classify_conformity does NOT declare false conformity with no data", {
  expect_true(is.na(une689_classify_conformity(c(NA_real_, NA_real_))))
  expect_true(is.na(une689_classify_conformity(numeric(0))))
})

test_that("une689_validate_min_days enforces the minimum number of days", {
  expect_false(une689_validate_min_days(2))
  expect_true(une689_validate_min_days(3))
  expect_true(une689_validate_min_days(5, minimo = 3))
})

test_that("une689_evaluate_preliminary calculates ED/IE per day and classifies the set", {
  datos <- data.frame(
    jornada       = c(1, 1, 2, 3, 3),
    concentracion = c(12, 8, 9, 5, 6),
    tiempo        = c(4, 4, 8, 3, 5)
  )
  res <- une689_evaluate_preliminary(datos, vla = 10)

  expect_equal(nrow(res$tabla_jornadas), 3)
  expect_equal(res$tabla_jornadas$ED, c(10, 9, 45 / 8))
  expect_equal(res$tabla_jornadas$IE, c(1, 0.9, 45 / 80))
  expect_equal(res$resultado, .t("une689_no_decision"))
})

test_that("une689_evaluate_preliminary detects NON-CONFORMITY", {
  datos <- data.frame(
    jornada       = c(1, 2, 3),
    concentracion = c(15, 8, 6),
    tiempo        = c(8, 8, 8)
  )
  res <- une689_evaluate_preliminary(datos, vla = 10)
  expect_equal(res$resultado, .t("une689_no_conformity"))
})
