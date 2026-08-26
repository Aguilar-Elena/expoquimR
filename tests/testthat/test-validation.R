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

test_that("UNE-EN 689 handles all-NA and identical exposure vectors", {
  expect_error(
    une689_statistics(rep(NA_real_, 6)),
    "must not contain NA"
  )

  identical_stats <- une689_statistics(rep(0.5, 6))

  expect_equal(identical_stats$MA, 0.5)
  expect_equal(identical_stats$DS, 0)
  expect_equal(identical_stats$MG, 0.5)
  expect_equal(identical_stats$DSG, 1)

  expect_error(
    une689_evaluate_statistical(rep(0.5, 6), vla = 1),
    "identical"
  )
})

test_that("UNE-EN 689 rejects data outside the statistical evaluation domain", {
  expect_error(
    une689_evaluate_statistical(c(0.4, 0.5, 0.6), vla = 1)
  )

  expect_error(
    une689_statistics(c(0.4, 0, 0.6)),
    "positive"
  )

  expect_error(
    une689_statistics(c(0.4, -0.5, 0.6)),
    "positive"
  )
})


test_that("UNE-EN 689 preliminary assessment validates tabular input", {
  x <- data.frame(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  expect_silent(
    une689_evaluate_preliminary(x, vla = 10)
  )

  expect_error(
    une689_evaluate_preliminary(
      x[, c("day", "concentration")],
      vla = 10
    ),
    "Missing: time"
  )

  expect_error(
    une689_evaluate_preliminary(
      list(
        day = x$day,
        concentration = x$concentration,
        time = x$time
      ),
      vla = 10
    ),
    "data.frame or a two-dimensional matrix"
  )
})


test_that("UNE-EN 689 preliminary assessment accepts named matrices", {
  x <- cbind(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  expect_message(
    result <- une689_evaluate_preliminary(x, vla = 10),
    "Converting matrix"
  )

  expect_type(result, "list")
  expect_s3_class(result$days_table, "data.frame")
})


test_that("UNE-EN 689 preliminary assessment normalises data-frame subclasses", {
  x <- data.frame(
    day = c(1, 1, 2, 3),
    concentration = c(1, 2, 3, 4),
    time = c(4, 4, 8, 8)
  )

  class(x) <- c("expoquimr_test_table", "data.frame")

  expect_message(
    result <- une689_evaluate_preliminary(x, vla = 10),
    "class-specific attributes"
  )

  expect_s3_class(result$days_table, "data.frame")
})


test_that("UNE-EN 689 preliminary assessment rejects list columns", {
  x <- data.frame(
    day = c(1, 2, 3),
    concentration = c(1, 2, 3),
    time = c(8, 8, 8)
  )

  x$concentration <- I(list(1, 2, 3))

  expect_error(
    une689_evaluate_preliminary(x, vla = 10),
    "list column"
  )
})


test_that("UNE-EN 689 preliminary assessment rejects unsupported column classes", {
  x <- data.frame(
    day = c(1, 2, 3),
    concentration = c(1, 2, 3),
    time = c(8, 8, 8)
  )

  x$concentration <- structure(
    x$concentration,
    class = "expoquimr_test_numeric"
  )

  expect_error(
    une689_evaluate_preliminary(x, vla = 10),
    "unsupported column class"
  )
})
