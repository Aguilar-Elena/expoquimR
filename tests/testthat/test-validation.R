test_that("numeric scalar validation handles invalid inputs", {
  expect_invisible(
    expoquimR:::.assert_numeric_scalar(1, "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(c(1, 2), "x"),
    "numeric scalar"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar("1", "x"),
    "numeric scalar"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(NA_real_, "x"),
    "must not be NA"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_scalar(
      NA_real_,
      "x",
      allow_na = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(Inf, "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(-Inf, "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_scalar(NaN, "x")
  )
})


test_that("numeric vector validation handles edge conditions", {
  expect_invisible(
    expoquimR:::.assert_numeric_vector(c(1, 2, 3), "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(character(), "x"),
    "numeric"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(numeric(), "x"),
    "must not be empty"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_vector(
      numeric(),
      "x",
      allow_empty = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, NA), "x"),
    "must not contain NA"
  )

  expect_invisible(
    expoquimR:::.assert_numeric_vector(
      c(1, NA),
      "x",
      allow_na = TRUE
    )
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, Inf), "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, -Inf), "x"),
    "finite"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(c(1, NaN), "x")
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(
      c(1, 0),
      "x",
      positive = TRUE
    ),
    "positive"
  )

  expect_error(
    expoquimR:::.assert_numeric_vector(
      c(1, -1),
      "x",
      positive = TRUE
    ),
    "positive"
  )
})

test_that("COSHH volatility rejects non-finite and non-scalar inputs", {
  expect_error(
    coshh_classify_volatility(Inf, 20),
    "finite"
  )

  expect_error(
    coshh_classify_volatility(111, -Inf),
    "finite"
  )

  expect_error(
    coshh_classify_volatility(c(100, 111), 20),
    "numeric scalar"
  )
})


test_that("UNE-EN 689 statistics rejects unsupported edge cases", {
  expect_error(
    une689_statistics(numeric()),
    "must not be empty"
  )

  expect_error(
    une689_statistics(c(1, 2, Inf)),
    "finite"
  )

  expect_error(
    une689_statistics(c(1, 2, -Inf)),
    "finite"
  )

  expect_error(
    une689_statistics(c(1, 2, NaN))
  )

  expect_error(
    une689_statistics(c(1, 0, 2)),
    "positive"
  )

  expect_error(
    une689_statistics(c(1, -1, 2)),
    "positive"
  )

  expect_error(
    une689_statistics(c("1", "2", "3")),
    "numeric"
  )
})
