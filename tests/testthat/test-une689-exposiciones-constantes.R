test_that('constant ED returns an undetermined result without Shapiro error', {
  for (x in c(0.5, 5, 20)) {
    r <- une689_evaluate_statistical(rep(x, 6), vla = 10)
    expect_identical(r$diagnostic_status, 'CONSTANT_EXPOSURES')
    expect_identical(r$distribution_type, 'Neither')
    expect_equal(r$MA, x)
    expect_equal(r$MG, x)
    expect_equal(r$DS, 0)
    expect_equal(r$DSG, 1)
    expect_true(is.na(r$pval_normal))
    expect_true(is.na(r$pval_lognormal))
    expect_true(is.na(r$lsc))
    expect_true(is.na(r$ur))
    expect_true(is.na(r$conformity))
  }
})
test_that('variable ED preserves existing mathematical outputs', {
  r <- une689_evaluate_statistical(c(3, 4, 5, 6, 8, 12), 15)
  expect_equal(r$MG, 5.7073, tolerance = 1e-4)
  expect_equal(r$lsc, 16.85801, tolerance = 1e-4)
  expect_identical(r$conformity, 'NON-CONFORMITY')
})
