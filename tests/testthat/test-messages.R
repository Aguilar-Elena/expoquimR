test_that("language selection reports and rejects invalid values explicitly", {
  old <- suppressMessages(expoquimr_lang())

  expect_message(
    expoquimr_lang(),
    "Current expoquimR language"
  )

  expect_error(
    expoquimr_lang("xx"),
    "Language 'xx' is not supported"
  )

  invisible(expoquimr_lang(old))
})


test_that("UNE-EN 689 minimum-days error is explicit", {
  expect_error(
    une689_evaluate_statistical(
      c(1, 2, 3),
      vla = 10
    ),
    "At least 6 measurement days"
  )
})


test_that("report input validation emits specific errors", {
  expect_error(
    expoquimr_report(),
    "At least one of 'coshh', 'inrs' or 'une689' must be supplied"
  )
})


test_that("internal Shiny launcher reports an unknown application", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("DT")
  skip_if_not_installed("ggplot2")

  expect_error(
    expoquimR:::.expoquimR_run_app(
      "__expoquimr_nonexistent_app__",
      launch.browser = FALSE
    ),
    "was not found inside the expoquimR package"
  )
})
