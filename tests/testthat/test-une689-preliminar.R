test_that("une689_daily_exposure calculates the general case (weighted average / 8h)", {
  expect_equal(une689_daily_exposure(c(12, 8), c(4, 4)), 10, tolerance = 1e-12)
  expect_equal(une689_daily_exposure(c(5, 6),  c(3, 5)), 45 / 8, tolerance = 1e-12)
})

test_that("une689_daily_exposure applies the special case for a single 8h sample", {
  expect_equal(une689_daily_exposure(9, 8), 9, tolerance = 1e-12)
  expect_equal(une689_daily_exposure(9, 4), 9 * 4 / 8, tolerance = 1e-12)
})

test_that("une689_daily_exposure ignores NA pairs and returns NA with no data", {
  expect_equal(une689_daily_exposure(c(12, NA), c(4, NA)), 12 * 4 / 8, tolerance = 1e-12)
  expect_true(is.na(une689_daily_exposure(NA_real_, NA_real_)))
})

test_that("une689_exposure_index divides ED by VLA and validates VLA > 0", {
  expect_equal(une689_exposure_index(9, 10), 0.9, tolerance = 1e-12)
  expect_true(is.na(une689_exposure_index(9,  NA)))
  expect_true(is.na(une689_exposure_index(9,  0)))
  expect_true(is.na(une689_exposure_index(NA, 10)))
})

test_that("une689_classify_conformity classifies the 3 normal cases in English", {
  expect_equal(une689_classify_conformity(c(0.02, 0.05, 0.07)),
               .t("une689_conformity"))
  expect_equal(une689_classify_conformity(c(1, 0.9, 0.5625)),
               .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(1.2, 0.05)),
               .t("une689_no_conformity"))
})

test_that("une689_classify_conformity returns Spanish labels when lang = 'es'", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_equal(une689_classify_conformity(c(0.02, 0.05, 0.07)), "CONFORMIDAD")
  expect_equal(une689_classify_conformity(c(1.2, 0.05)),  "NO CONFORMIDAD")
})

test_that("une689_classify_conformity does NOT declare false conformity with no data", {
  expect_true(is.na(une689_classify_conformity(c(NA_real_, NA_real_))))
  expect_true(is.na(une689_classify_conformity(numeric(0))))
})

test_that("une689_validate_min_days enforces the minimum number of days", {
  expect_false(une689_validate_min_days(2))
  expect_true(une689_validate_min_days(3))
  expect_true(une689_validate_min_days(5, minimum = 3))
})

test_that("une689_evaluate_preliminary calculates ED/IE per day and classifies the set", {
  data <- data.frame(
    day           = c(1, 1, 2, 3, 3),
    concentration = c(12, 8, 9, 5, 6),
    time          = c(4, 4, 8, 3, 5)
  )
  res <- une689_evaluate_preliminary(data, vla = 10)

  expect_equal(nrow(res$days_table), 3)
  expect_equal(res$days_table$ED, c(10, 9, 45 / 8), tolerance = 1e-12)
  expect_equal(res$days_table$IE, c(1, 0.9, 45 / 80), tolerance = 1e-12)
  expect_equal(res$result, .t("une689_no_decision"))
})

test_that("une689_evaluate_preliminary detects NON-CONFORMITY", {
  data <- data.frame(
    day           = c(1, 2, 3),
    concentration = c(15, 8, 6),
    time          = c(8, 8, 8)
  )
  res <- une689_evaluate_preliminary(data, vla = 10)
  expect_equal(res$result, .t("une689_no_conformity"))
})

test_that("preliminary assessment cannot classify fewer than three measured days", {
  one <- data.frame(day = 1, concentration = 0.5, time = 8)
  expect_error(une689_evaluate_preliminary(one, vla = 10), "At least 3")
  two <- rbind(one, transform(one, day = 2))
  expect_error(une689_evaluate_preliminary(two, vla = 10), "At least 3")
})

test_that("preliminary assessment rejects invalid OEL and partial samples", {
  x <- data.frame(day = 1:3, concentration = c(1, 2, 3),
                  time = c(8, 8, 8))
  expect_error(une689_evaluate_preliminary(x, vla = 0), "positive")
  expect_error(une689_evaluate_preliminary(x, vla = Inf), "finite")
  x$time[2] <- NA_real_
  expect_error(une689_evaluate_preliminary(x, vla = 10), "incomplete")
})

test_that("fully blank slots do not count as measured days", {
  x <- data.frame(day = 1:3, concentration = c(1, 2, NA_real_),
                  time = c(8, 8, NA_real_))
  expect_error(une689_evaluate_preliminary(x, vla = 10), "At least 3")
})

test_that("preliminary thresholds depend on 3, 4 or 5 measurements", {
  expect_equal(une689_classify_conformity(c(.05, .07, .09)), .t("une689_conformity"))
  expect_equal(une689_classify_conformity(c(.12, .13, .14)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(.12, .13, .14, .14)), .t("une689_conformity"))
  expect_equal(une689_classify_conformity(c(.16, .17, .18, .19)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(.16, .17, .18, .19, .19)), .t("une689_conformity"))
  expect_equal(une689_classify_conformity(c(.30, .40, 1.20)), .t("une689_no_conformity"))
})

test_that("preliminary threshold boundaries are strict", {
  expect_equal(une689_classify_conformity(c(.01, .02, .10)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(.01, .02, .03, .15)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(.01, .02, .03, .04, .20)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(c(.01, .02, 1.00)), .t("une689_no_decision"))
})

test_that("insufficient or invalid IE never leads to conformity", {
  expect_equal(une689_classify_conformity(c(.01, .02)), .t("une689_no_decision"))
  expect_equal(une689_classify_conformity(rep(.01, 6)), .t("une689_no_decision"))
  expect_error(une689_classify_conformity(c(.01, NA_real_, .02)), "NA")
  expect_error(une689_classify_conformity(c(.01, Inf, .02)), "finite")
  expect_error(une689_classify_conformity(c(-.01, .02, .03)), "non-negative")
})

