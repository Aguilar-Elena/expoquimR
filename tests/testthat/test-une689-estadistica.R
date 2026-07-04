test_that("une689_ut queries the table and applies the limit for n > 30", {
  expect_equal(une689_ut(6),  2.187)
  expect_equal(une689_ut(30), 1.820)
  expect_equal(une689_ut(50), 1.820)
  expect_true(is.na(une689_ut(5)))
})

test_that("une689_statistics calculates MA/DS/MG/DSG correctly", {
  ed  <- c(5, 6, 7, 8, 9, 10)
  res <- une689_statistics(ed)
  expect_equal(res$MA,  mean(ed))
  expect_equal(res$DS,  sd(ed))
  expect_equal(res$MG,  exp(mean(log(ed))))
  expect_equal(res$DSG, exp(sd(log(ed))))
})

test_that("une689_statistics requires positive values without NA", {
  expect_error(une689_statistics(c(5, NA, 7)))
  expect_error(une689_statistics(c(5, -1, 7)))
})

test_that("une689_normality_test returns a correctly structured result", {
  ed  <- c(5, 6, 7, 8, 9, 10)
  res <- une689_normality_test(ed)
  expect_named(res, c("W_normal", "pval_normal", "W_lognormal", "pval_lognormal"))
  expect_true(res$pval_normal    >= 0 && res$pval_normal    <= 1)
  expect_true(res$pval_lognormal >= 0 && res$pval_lognormal <= 1)
})

test_that("une689_distribution_type prioritises lognormal over normal", {
  expect_equal(une689_distribution_type(0.5,  0.5),  .t("une689_lognormal"))
  expect_equal(une689_distribution_type(0.5,  0.01), .t("une689_normal"))
  expect_equal(une689_distribution_type(0.01, 0.01), .t("une689_neither"))
})

test_that("une689_distribution_type returns Spanish labels when lang = 'es'", {
  expoquimr_lang("es")
  on.exit(expoquimr_lang("en"))
  expect_equal(une689_distribution_type(0.5,  0.5),  "Lognormal")
  expect_equal(une689_distribution_type(0.5,  0.01), "Normal")
  expect_equal(une689_distribution_type(0.01, 0.01), "Ninguna")
})

test_that("une689_lsc and une689_ur calculate according to distribution type", {
  log_type <- .t("une689_lognormal")
  nor_type <- .t("une689_normal")

  expect_equal(une689_lsc(nor_type, ut = 2, MA = 7.5, DS = 1.87),
               7.5 + 2 * 1.87)
  expect_equal(une689_lsc(log_type, ut = 2, MG = 7.3, DSG = 1.3),
               7.3 * 1.3^2)
  expect_true(is.na(une689_lsc(.t("une689_neither"), ut = 2)))

  expect_equal(une689_ur(nor_type, vla = 10, MA = 7.5, DS = 1.87),
               (10 - 7.5) / 1.87)
  expect_equal(une689_ur(log_type, vla = 10, MG = 7.3, DSG = 1.3),
               (log(10) - log(7.3)) / log(1.3))
  expect_true(is.na(une689_ur(.t("une689_neither"), vla = 10)))
})

test_that("une689_statistical_conformity compares UR against UT", {
  expect_equal(une689_statistical_conformity(ur = 2.5,  ut = 2.005),
               .t("une689_conformity"))
  expect_equal(une689_statistical_conformity(ur = 1.5,  ut = 2.005),
               .t("une689_no_conformity"))
  expect_true(is.na(une689_statistical_conformity(ur = NA_real_, ut = 2.005)))
})

test_that("une689_evaluate_statistical requires a minimum of 6 ED values", {
  expect_error(une689_evaluate_statistical(c(5, 6, 7), vla = 10))
})

test_that("une689_evaluate_statistical returns a complete and coherent structure", {
  ed  <- c(5, 6, 7, 8, 9, 10)
  res <- une689_evaluate_statistical(ed, vla = 10)

  expect_equal(res$n,  6)
  expect_equal(res$ut, une689_ut(6))
  expect_true(res$tipo %in% c(.t("une689_lognormal"),
                               .t("une689_normal"),
                               .t("une689_neither")))
  if (res$tipo == .t("une689_neither")) {
    expect_true(is.na(res$ur))
    expect_true(is.na(res$lsc))
    expect_true(is.na(res$conformidad))
  } else {
    expect_false(is.na(res$ur))
    expect_false(is.na(res$lsc))
    expect_true(res$conformidad %in% c(.t("une689_conformity"),
                                        .t("une689_no_conformity")))
  }
})

test_that("une689_monitoring_interval_opt1 classifies the 4 intervals", {
  expect_match(une689_monitoring_interval_opt1(0.5, vla = 10), "36")
  expect_match(une689_monitoring_interval_opt1(2,   vla = 10), "24")
  expect_match(une689_monitoring_interval_opt1(4,   vla = 10), "18")
  expect_match(une689_monitoring_interval_opt1(8,   vla = 10), "12")
})

test_that("une689_monitoring_interval_opt2 classifies the 3 intervals and final warning", {
  expect_match(une689_monitoring_interval_opt2(2,  vla = 10), "36")
  expect_match(une689_monitoring_interval_opt2(4,  vla = 10), "30")
  expect_match(une689_monitoring_interval_opt2(8,  vla = 10), "24")
  expect_match(une689_monitoring_interval_opt2(11, vla = 10), "review|revisar")
})
