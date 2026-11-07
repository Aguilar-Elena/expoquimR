test_that("stored COSHH recommendations are translated without changing calculations", {
  keys <- paste0("coshh_risk_", 1:4, "_measures")
  original <- vapply(keys, function(k) expoquimR:::.translations$en[[k]], character(1))
  spanish <- expoquimR:::.localize_result_labels(original, keys, "es")
  expect_equal(spanish, vapply(keys, function(k) expoquimR:::.translations$es[[k]], character(1)))
  expect_equal(expoquimR:::.localize_result_labels(spanish, keys, "en"), original)
  expect_equal(expoquimR:::.localize_result_labels(c(NA_character_, "other"), keys, "es"), c(NA_character_, "other"))
})

test_that("stored INRS characterisations translate reversibly", {
  keys <- paste0("inrs_char_", 1:3)
  en <- vapply(keys, function(k) expoquimR:::.translations$en[[k]], character(1))
  es <- vapply(keys, function(k) expoquimR:::.translations$es[[k]], character(1))
  expect_equal(expoquimR:::.localize_result_labels(en, keys, "es"), es)
  expect_equal(expoquimR:::.localize_result_labels(es, keys, "en"), en)
})
