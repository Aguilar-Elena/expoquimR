#' Evaluate COSHH substances from an Excel file
#'
#' Reads an Excel sheet with the format of the expoquimR COSHH template
#' (one row per substance) and returns the complete assessment of each
#' one by calling [coshh_evaluate()].
#'
#' @param path Character. Path to the `.xlsx` file. Can be obtained with
#'   [system.file()] for the template included in the package, or be any
#'   local path.
#' @param sheet Character or integer. Name or number of the sheet that
#'   contains the data (default `"COSHH_datos"`).
#'
#' @return A `data.frame` with one row per substance and the result
#'   columns of [coshh_evaluate()].
#'
#' @examples
#' \dontrun{
#' # With the template included in the package:
#' path <- system.file("plantillas", "plantilla_coshh.xlsx",
#'                     package = "expoquimR")
#' coshh_from_excel(path)
#'
#' # With your own file:
#' coshh_from_excel("my_coshh_data.xlsx")
#' }
#'
#' @export
coshh_from_excel <- function(path, sheet = "COSHH_datos") {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  df <- as.data.frame(readxl::read_excel(path, sheet = sheet, skip = 2, col_types = "text"))

  required_cols <- c("substance", "quantity", "is_liquid")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(.t("missing_cols", paste(missing_cols, collapse = ", ")), call. = FALSE)
  }

  results <- lapply(seq_len(nrow(df)), function(i) {
    row <- df[i, ]

    is_liq <- isTRUE(toupper(trimws(row$is_liquid)) == "TRUE")

    h_phrases_str <- trimws(row$h_phrases %||% "")
    r_phrases_str <- trimws(row$r_phrases %||% "")
    combined_phrases <- paste(
      c(h_phrases_str, r_phrases_str)[nzchar(c(h_phrases_str, r_phrases_str))],
      collapse = ", "
    )

    coshh_evaluate(
      name          = row$substance %||% paste("Substance", i),
      phrases       = combined_phrases,
      quantity      = trimws(row$quantity),
      is_liquid     = is_liq,
      boiling_point = suppressWarnings(as.numeric(row$boiling_point)),
      process_temp  = suppressWarnings(as.numeric(row$process_temp)),
      dustiness     = trimws(row$dustiness %||% NA_character_)
    )
  })

  do.call(rbind, results)
}

#' Evaluate INRS chemical products from an Excel file
#'
#' Reads an Excel sheet with the format of the expoquimR INRS template
#' (one row per product) and returns the complete assessment by calling
#' [inrs_evaluate()].
#'
#' @param path Character. Path to the `.xlsx` file.
#' @param sheet Character or integer. Name or number of the sheet
#'   (default `"INRS_datos"`).
#'
#' @return A `data.frame` with one row per product and all the result
#'   columns of [inrs_evaluate()].
#'
#' @examples
#' \dontrun{
#' path <- system.file("plantillas", "plantilla_inrs.xlsx",
#'                     package = "expoquimR")
#' inrs_from_excel(path)
#' }
#'
#' @export
inrs_from_excel <- function(path, sheet = "INRS_datos") {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  df <- as.data.frame(readxl::read_excel(path, sheet = sheet, skip = 2, col_types = "text"))

  required_cols <- c("product", "procedure", "protection")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop(.t("missing_cols", paste(missing_cols, collapse = ", ")), call. = FALSE)
  }

  results <- lapply(seq_len(nrow(df)), function(i) {
    row <- df[i, ]

    h_phrases <- if (!is.na(row$h_phrases) && nzchar(trimws(row$h_phrases)))
      trimws(strsplit(row$h_phrases, ",")[[1]]) else character(0)
    r_phrases <- if (!is.na(row$r_phrases) && nzchar(trimws(row$r_phrases)))
      trimws(strsplit(row$r_phrases, ",")[[1]]) else character(0)
    process  <- if (!is.na(row$process) && nzchar(trimws(row$process)))
      trimws(row$process) else NULL

    inrs_evaluate(
      name               = row$product %||% paste("Product", i),
      h_phrases          = h_phrases,
      r_phrases          = r_phrases,
      process            = process,
      vla                = suppressWarnings(as.numeric(row$vla)),
      quantity_value     = suppressWarnings(as.numeric(row$quantity_value)),
      quantity_unit      = trimws(row$quantity_unit  %||% "g"),
      frequency_value    = suppressWarnings(as.numeric(row$frequency_value)),
      frequency_unit     = trimws(row$frequency_unit %||% "hours"),
      substance_type     = trimws(row$substance_type %||% "liquid"),
      liquid_method      = trimws(row$liquid_method   %||% "graph"),
      use_temperature    = suppressWarnings(as.numeric(row$use_temperature)),
      boiling_point      = suppressWarnings(as.numeric(row$boiling_point)),
      vapour_pressure    = suppressWarnings(as.numeric(row$vapour_pressure)),
      solid_description  = trimws(row$solid_description %||% NA_character_),
      procedure          = trimws(row$procedure),
      protection         = trimws(row$protection)
    )
  })

  do.call(rbind, results)
}

#' Evaluate UNE-EN 689 chemical exposure from an Excel file
#'
#' Reads the three sheets of the expoquimR UNE-EN 689 template
#' (`Agents`, `Measurements` and optionally `Additive_effects`) and
#' returns a list with the preliminary assessment of each agent, and if
#' applicable, the additive effects calculation by group.
#'
#' @param path Character. Path to the `.xlsx` file.
#'
#' @return A list with the elements:
#'   \describe{
#'     \item{`preliminary`}{A list with one element per agent, each with
#'       `name`, `vla`, `days_table` and `result`.}
#'     \item{`additive`}{`data.frame` with columns `group`, `agent`,
#'       `mean_ie` and `combined_ie`, or `NULL` if there is no additive
#'       effects sheet.}
#'   }
#'
#' @examples
#' \dontrun{
#' path <- system.file("plantillas", "plantilla_une689.xlsx",
#'                     package = "expoquimR")
#' res <- une689_from_excel(path)
#' res$preliminary
#' res$additive
#' }
#'
#' @export
une689_from_excel <- function(path) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    stop(.t("need_readxl"), call. = FALSE)
  }

  sheets <- readxl::excel_sheets(path)

  # ---- Agents -----------------------------------------------------------
  if (!"Agents" %in% sheets) {
    stop(.t("excel_no_sheet_agents"), call. = FALSE)
  }
  agents_df <- as.data.frame(readxl::read_excel(path, sheet = "Agents",
                                              skip = 2, col_types = "text"))
  agents_df$vla_mg_m3 <- suppressWarnings(as.numeric(agents_df$vla_mg_m3))

  # ---- Measurements -------------------------------------------------------
  if (!"Measurements" %in% sheets) {
    stop(.t("excel_no_sheet_meas"), call. = FALSE)
  }
  meas_df <- as.data.frame(readxl::read_excel(path, sheet = "Measurements",
                                               skip = 2, col_types = "text"))
  meas_df$concentration_mg_m3 <- suppressWarnings(as.numeric(meas_df$concentration_mg_m3))
  meas_df$time_h              <- suppressWarnings(as.numeric(meas_df$time_h))
  meas_df$day                 <- suppressWarnings(as.integer(meas_df$day))

  # ---- Preliminary assessment per agent ------------------------------------
  preliminary <- lapply(seq_len(nrow(agents_df)), function(i) {
    name <- agents_df$agent[i]
    vla  <- agents_df$vla_mg_m3[i]

    # Select measurements for this agent (only type "pre")
    sub <- meas_df[
      trimws(tolower(meas_df$agent)) == trimws(tolower(name)) &
        trimws(tolower(meas_df$type)) == "pre",
    ]
    sub <- sub[!is.na(sub$concentration_mg_m3) & !is.na(sub$time_h), ]

    if (nrow(sub) == 0 || is.na(vla)) {
      return(list(name = name, vla = vla,
                  days_table = NULL, result = NA_character_))
    }

    data <- data.frame(
      day           = sub$day,
      concentration = sub$concentration_mg_m3,
      time          = sub$time_h
    )

    res <- une689_evaluate_preliminary(data, vla = vla)

    # If NO DECISION, try statistical assessment with additional days
    if (!is.na(res$result) && res$result == .t("une689_no_decision")) {
      sub_add <- meas_df[
        trimws(tolower(meas_df$agent)) == trimws(tolower(name)) &
          trimws(tolower(meas_df$type)) == "add",
      ]
      sub_add <- sub_add[!is.na(sub_add$concentration_mg_m3) &
                           !is.na(sub_add$time_h), ]

      if (nrow(sub_add) > 0) {
        n_pre <- max(data$day, na.rm = TRUE)
        data_add <- data.frame(
          day           = sub_add$day + n_pre,
          concentration = sub_add$concentration_mg_m3,
          time          = sub_add$time_h
        )
        data_total <- rbind(data, data_add)

        day_ids <- sort(unique(data_total$day))
        eds  <- vapply(day_ids, function(d) {
          s <- data_total[data_total$day == d, ]
          une689_daily_exposure(s$concentration, s$time)
        }, numeric(1))
        eds <- eds[!is.na(eds) & eds > 0]

        if (une689_validate_min_days(length(eds), minimum = 6L)) {
          stats_result <- une689_evaluate_statistical(eds, vla = vla)
          stats_result$eds <- eds   # needed for density plot in expoquimr_report()
          stats_result$vla <- vla
          return(list(
            name       = name,
            vla        = vla,
            days_table = res$days_table,
            result     = res$result,
            statistics = stats_result
          ))
        }
      }
    }

    list(name = name, vla = vla,
         days_table = res$days_table,
         result = res$result)
  })
  names(preliminary) <- agents_df$agent

  # ---- Additive effects -----------------------------------------------------
  additive <- NULL
  if ("Additive_effects" %in% sheets) {
    add_df <- as.data.frame(readxl::read_excel(path, sheet = "Additive_effects", skip = 2, col_types = "text"))
    add_df$group <- suppressWarnings(as.integer(add_df$group))

    groups <- sort(unique(add_df$group[!is.na(add_df$group)]))
    group_rows <- lapply(groups, function(g) {
      group_agents <- trimws(add_df$agent[add_df$group == g])
      group_desc   <- add_df$group_description[add_df$group == g][1]

      ie_per_agent <- vapply(group_agents, function(ag) {
        pre <- preliminary[[ag]]
        if (is.null(pre) || is.null(pre$days_table)) return(NA_real_)
        mean(pre$days_table$IE, na.rm = TRUE)
      }, numeric(1))

      # Only calculate combined_ie if ALL agents in the group have data
      has_na <- anyNA(ie_per_agent)
      combined_ie <- if (has_na) NA_real_ else sum(ie_per_agent)

      group_result <- if (has_na) {
        .t("une689_additive_na")
      } else if (combined_ie < 0.1) {
        .t("une689_conformity")
      } else if (combined_ie > 1) {
        .t("une689_no_conformity")
      } else {
        .t("une689_no_decision")
      }
      data.frame(
        group          = g,
        description    = group_desc %||% "",
        agent          = group_agents,
        mean_ie        = round(ie_per_agent, 4),
        combined_ie    = round(combined_ie, 4),
        group_result   = group_result,
        stringsAsFactors = FALSE
      )
    })
    additive <- do.call(rbind, group_rows)
  }

  list(preliminary = preliminary, additive = additive)
}

# Internal helper (avoids a dependency on rlang in these functions)
`%||%` <- function(a, b) if (is.null(a) || (length(a) == 1 && is.na(a))) b else a
