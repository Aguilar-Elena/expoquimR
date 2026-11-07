test_that("report validates language without changing active language", {
  old <- expoquimr_lang()
  on.exit(expoquimr_lang(old), add = TRUE)
  expect_error(expoquimr_report(lang = "fr", open = FALSE), "lang")
  expect_identical(expoquimr_lang(), old)
})

test_that("report can render in Spanish and English", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")
  skip_if_not_installed("kableExtra")
  skip_if_not(rmarkdown::pandoc_available())
  old <- expoquimr_lang()
  on.exit(expoquimr_lang(old), add = TRUE)
  example <- data.frame(substance = "Toluene", risk = 1L, measures = "Ventilation")
  for (lang in c("es", "en")) {
    out <- tempfile(fileext = ".html")
    expoquimr_report(coshh = example, lang = lang, output = out, open = FALSE)
    html <- paste(readLines(out, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    expect_true(grepl(if (lang == "es") "Evaluación del riesgo" else "Occupational Chemical Exposure", html, fixed = TRUE))
    expect_identical(expoquimr_lang(), old)
  }
})
