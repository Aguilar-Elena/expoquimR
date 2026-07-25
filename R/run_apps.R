#' Launch the COSHH Essentials Shiny application
#'
#' @param ... Additional arguments passed to [shiny::runApp()] (e.g.
#'   `launch.browser`, `port`).
#'
#' @return No return value, called for side effects. Launches a Shiny
#'   application in the default browser.
#'
#' @examplesIf interactive()
#' run_coshh()
#'
#' @export
run_coshh <- function(...) {
  .expoquimR_run_app("coshh", ...)
}

#' Launch the INRS method Shiny application
#'
#' @inheritParams run_coshh
#' @return No return value, called for side effects. Launches a Shiny
#'   application in the default browser.
#'
#' @examplesIf interactive()
#' run_inrs()
#'
#' @export
run_inrs <- function(...) {
  .expoquimR_run_app("inrs", ...)
}

#' Launch the UNE-EN 689 Shiny application (preliminary, statistical and
#' periodic assessment)
#'
#' @inheritParams run_coshh
#' @return No return value, called for side effects. Launches a Shiny
#'   application in the default browser.
#'
#' @examplesIf interactive()
#' run_une689()
#'
#' @export
run_une689 <- function(...) {
  .expoquimR_run_app("une689", ...)
}

# Internal helper: checks dependencies and launches the app from inst/apps/<id>
.expoquimR_run_app <- function(id, ...) {
  missing_pkgs <- c("shiny", "DT", "ggplot2")[
    !vapply(c("shiny", "DT", "ggplot2"), requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(missing_pkgs) > 0) {
    stop(
      .t("need_shiny", paste(missing_pkgs, collapse = ", "),
         paste0('"', missing_pkgs, '"', collapse = ", ")),
      call. = FALSE
    )
  }

  app_dir <- system.file("apps", id, package = "expoquimR")
  if (!nzchar(app_dir)) {
    stop(.t("app_not_found", id), call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
