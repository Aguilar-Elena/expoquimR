#' Lanzar la app Shiny del metodo COSHH Essentials
#'
#' @param ... Argumentos adicionales pasados a [shiny::runApp()] (p. ej.
#'   `launch.browser`, `port`).
#'
#' @return No devuelve nada; lanza la app Shiny de forma bloqueante.
#'
#' @examplesIf interactive()
#' run_coshh()
#'
#' @export
run_coshh <- function(...) {
  .expoquimR_run_app("coshh", ...)
}

#' Lanzar la app Shiny del metodo INRS
#'
#' @inheritParams run_coshh
#' @return No devuelve nada; lanza la app Shiny de forma bloqueante.
#'
#' @examplesIf interactive()
#' run_inrs()
#'
#' @export
run_inrs <- function(...) {
  .expoquimR_run_app("inrs", ...)
}

#' Lanzar la app Shiny de UNE-EN 689 (preliminar, estadistica y periodicidad)
#'
#' @inheritParams run_coshh
#' @return No devuelve nada; lanza la app Shiny de forma bloqueante.
#'
#' @examplesIf interactive()
#' run_une689()
#'
#' @export
run_une689 <- function(...) {
  .expoquimR_run_app("une689", ...)
}

# Helper interno: comprueba dependencias y lanza la app desde inst/apps/<id>
.expoquimR_run_app <- function(id, ...) {
  faltan <- c("shiny", "DT", "ggplot2")[
    !vapply(c("shiny", "DT", "ggplot2"), requireNamespace, logical(1), quietly = TRUE)
  ]
  if (length(faltan) > 0) {
    stop(
      "Los siguientes paquetes son necesarios para usar las apps de expoquimR: ",
      paste(faltan, collapse = ", "), ".\n",
      "Instalalos con: install.packages(c(", paste0('"', faltan, '"', collapse = ", "), "))",
      call. = FALSE
    )
  }

  app_dir <- system.file("apps", id, package = "expoquimR")
  if (!nzchar(app_dir)) {
    stop("No se encontro la app '", id, "' dentro del paquete expoquimR.", call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
