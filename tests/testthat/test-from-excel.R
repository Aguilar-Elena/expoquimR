# ---- rOpenSci statistical standards ----
#' @srrstats {G5.1} Package-supplied Excel templates used in tests and examples are distributed under inst/plantillas and are therefore available to users; additional inline fixtures are visible in the public test suite.
# ---- end rOpenSci statistical standards ----

test_that("COSHH Excel template is read and evaluated reproducibly", {

  skip_if_not_installed("readxl")

  path <- system.file(
    "plantillas",
    "plantilla_coshh.xlsx",
    package = "expoquimR"
  )

  expect_true(nzchar(path))
  expect_true(file.exists(path))

  result <- coshh_from_excel(path)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)

  input <- as.data.frame(
    readxl::read_excel(
      path,
      sheet = "COSHH_datos",
      skip = 2,
      col_types = "text"
    )
  )

  expect_true(all(
    c("substance", "quantity", "is_liquid") %in% names(input)
  ))

  row <- input[1, , drop = FALSE]

  value_or <- function(x, default) {
    if (is.null(x) || (length(x) == 1 && is.na(x))) default else x
  }

  is_liq <- isTRUE(
    toupper(trimws(row$is_liquid)) == "TRUE"
  )

  h_phrases <- trimws(value_or(row$h_phrases, ""))
  r_phrases <- trimws(value_or(row$r_phrases, ""))

  phrases <- paste(
    c(h_phrases, r_phrases)[
      nzchar(c(h_phrases, r_phrases))
    ],
    collapse = ", "
  )

  direct <- coshh_evaluate(
    name          = value_or(row$substance, "Substance 1"),
    phrases       = phrases,
    quantity      = trimws(row$quantity),
    is_liquid     = is_liq,
    boiling_point = suppressWarnings(
      as.numeric(row$boiling_point)
    ),
    process_temp  = suppressWarnings(
      as.numeric(row$process_temp)
    ),
    dustiness     = trimws(
      value_or(row$dustiness, NA_character_)
    )
  )

  expect_equal(
    as.list(result[1, , drop = FALSE]),
    as.list(direct)
  )
})


test_that("INRS Excel template is read and evaluated reproducibly", {

  skip_if_not_installed("readxl")

  path <- system.file(
    "plantillas",
    "plantilla_inrs.xlsx",
    package = "expoquimR"
  )

  expect_true(nzchar(path))
  expect_true(file.exists(path))

  result <- inrs_from_excel(path)

  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0)

  input <- as.data.frame(
    readxl::read_excel(
      path,
      sheet = "INRS_datos",
      skip = 2,
      col_types = "text"
    )
  )

  expect_true(all(
    c("product", "procedure", "protection") %in%
      names(input)
  ))

  row <- input[1, , drop = FALSE]

  value_or <- function(x, default) {
    if (is.null(x) || (length(x) == 1 && is.na(x))) default else x
  }

  h_phrases <- if (
    !is.na(row$h_phrases) &&
      nzchar(trimws(row$h_phrases))
  ) {
    trimws(strsplit(row$h_phrases, ",")[[1]])
  } else {
    character(0)
  }

  r_phrases <- if (
    !is.na(row$r_phrases) &&
      nzchar(trimws(row$r_phrases))
  ) {
    trimws(strsplit(row$r_phrases, ",")[[1]])
  } else {
    character(0)
  }

  process <- if (
    !is.na(row$process) &&
      nzchar(trimws(row$process))
  ) {
    trimws(row$process)
  } else {
    NULL
  }

  direct <- inrs_evaluate(
    name              = value_or(row$product, "Product 1"),
    h_phrases         = h_phrases,
    r_phrases         = r_phrases,
    process           = process,
    vla               = suppressWarnings(
      as.numeric(row$vla)
    ),
    quantity_value    = suppressWarnings(
      as.numeric(row$quantity_value)
    ),
    quantity_unit     = trimws(
      value_or(row$quantity_unit, "g")
    ),
    frequency_value   = suppressWarnings(
      as.numeric(row$frequency_value)
    ),
    frequency_unit    = trimws(
      value_or(row$frequency_unit, "hours")
    ),
    substance_type    = trimws(
      value_or(row$substance_type, "liquid")
    ),
    liquid_method     = trimws(
      value_or(row$liquid_method, "graph")
    ),
    use_temperature   = suppressWarnings(
      as.numeric(row$use_temperature)
    ),
    boiling_point     = suppressWarnings(
      as.numeric(row$boiling_point)
    ),
    vapour_pressure   = suppressWarnings(
      as.numeric(row$vapour_pressure)
    ),
    solid_description = trimws(
      value_or(row$solid_description, NA_character_)
    ),
    procedure         = trimws(row$procedure),
    protection        = trimws(row$protection)
  )

  expect_equal(
    as.list(result[1, , drop = FALSE]),
    as.list(direct)
  )
})


test_that("UNE-EN 689 Excel template produces reproducible preliminary results", {

  skip_if_not_installed("readxl")

  path <- system.file(
    "plantillas",
    "plantilla_une689.xlsx",
    package = "expoquimR"
  )

  expect_true(nzchar(path))
  expect_true(file.exists(path))

  sheets <- readxl::excel_sheets(path)

  expect_true("Agents" %in% sheets)
  expect_true("Measurements" %in% sheets)

  result <- une689_from_excel(path)

  expect_type(result, "list")
  expect_named(
    result,
    c("preliminary", "additive")
  )

  expect_type(result$preliminary, "list")
  expect_gt(length(result$preliminary), 0)

  agents <- as.data.frame(
    readxl::read_excel(
      path,
      sheet = "Agents",
      skip = 2,
      col_types = "text"
    )
  )

  measurements <- as.data.frame(
    readxl::read_excel(
      path,
      sheet = "Measurements",
      skip = 2,
      col_types = "text"
    )
  )

  agents$vla_mg_m3 <- suppressWarnings(
    as.numeric(agents$vla_mg_m3)
  )

  measurements$concentration_mg_m3 <-
    suppressWarnings(
      as.numeric(
        measurements$concentration_mg_m3
      )
    )

  measurements$time_h <-
    suppressWarnings(
      as.numeric(measurements$time_h)
    )

  measurements$day <-
    suppressWarnings(
      as.integer(measurements$day)
    )

  agent_name <- agents$agent[1]
  vla <- agents$vla_mg_m3[1]

  sub <- measurements[
    trimws(tolower(measurements$agent)) ==
      trimws(tolower(agent_name)) &
      trimws(tolower(measurements$type)) == "pre",
    ,
    drop = FALSE
  ]

  sub <- sub[
    !is.na(sub$concentration_mg_m3) &
      !is.na(sub$time_h),
    ,
    drop = FALSE
  ]

  expect_gt(nrow(sub), 0)
  expect_false(is.na(vla))

  data <- data.frame(
    day           = sub$day,
    concentration = sub$concentration_mg_m3,
    time          = sub$time_h
  )

  direct <- une689_evaluate_preliminary(
    data,
    vla = vla
  )

  from_excel <- result$preliminary[[agent_name]]

  expect_equal(
    from_excel$name,
    agent_name
  )

  expect_equal(
    from_excel$vla,
    vla,
    tolerance = 1e-12
  )

  expect_equal(
    from_excel$result,
    direct$result
  )

  expect_equal(
    from_excel$days_table,
    direct$days_table
  )
})


test_that("Excel import functions reject nonexistent files", {

  skip_if_not_installed("readxl")

  missing <- tempfile(fileext = ".xlsx")

  expect_error(
    coshh_from_excel(missing),
    "does not exist"
  )

  expect_error(
    inrs_from_excel(missing),
    "does not exist"
  )

  expect_error(
    une689_from_excel(missing),
    "does not exist"
  )
})
