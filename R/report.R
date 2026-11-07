#' Generate an occupational chemical exposure risk assessment report
#'
#' Renders a self-contained HTML report from the results of one or more
#' assessment methods implemented in expoquimR. Each method section is
#' included only when the corresponding argument is supplied. The report
#' includes input data, result tables, density plots (UNE-EN 689), additive
#' effect groups, and a citation block for the package.
#'
#' @param coshh A `data.frame` returned by [coshh_evaluate()] or
#'   [coshh_from_excel()]. If `NULL` (default), the COSHH section is omitted.
#' @param inrs A `data.frame` returned by [inrs_evaluate()] or
#'   [inrs_from_excel()]. If `NULL` (default), the INRS section is omitted.
#' @param une689 A list returned by [une689_from_excel()] or constructed
#'   manually with elements `$preliminary` and optionally `$additive`. If
#'   `NULL` (default), the UNE-EN 689 section is omitted.
#' @param evaluator Character. Name of the person responsible for the
#'   assessment. Displayed in the report header. Default `""`.
#' @param workplace Character. Name or description of the workplace or
#'   workstation assessed. Default `""`.
#' @param output Character. Path and filename for the output HTML file.
#'   Default `"expoquimr_report.html"` in the current working directory.
#' @param lang Character. Language for the report body: `"en"` (English,
#'   default) or `"es"` (Spanish). See [expoquimr_lang()].
#' @param open Logical. Whether to open the report in the default browser
#'   after rendering. Default `TRUE`.
#'
#' @return Invisibly returns the path to the generated HTML file.
#'
#' @examples
#' \donttest{
#' # COSHH only
#' res <- coshh_evaluate(
#'   name = "Toluene", phrases = "H315, H336",
#'   quantity = "Medium", is_liquid = TRUE,
#'   boiling_point = 111, process_temp = 20
#' )
#' out1 <- tempfile(fileext = ".html")
#' expoquimr_report(
#'   coshh     = res,
#'   evaluator = "Dr. Jane Smith",
#'   workplace = "Printing workshop A",
#'   output    = out1,
#'   open      = FALSE
#' )
#'
#' # All three methods
#' path <- system.file("plantillas", "plantilla_une689.xlsx",
#'                     package = "expoquimR")
#' res_une <- une689_from_excel(path)
#'
#' out2 <- tempfile(fileext = ".html")
#' expoquimr_report(
#'   coshh     = res,
#'   une689    = res_une,
#'   evaluator = "Dr. Jane Smith",
#'   workplace = "Printing workshop A",
#'   output    = out2,
#'   lang      = "en",
#'   open      = FALSE
#' )
#' }
#'
#' @export
expoquimr_report <- function(coshh     = NULL,
                              inrs      = NULL,
                              une689    = NULL,
                              evaluator = "",
                              workplace = "",
                              output    = "expoquimr_report.html",
                              lang      = .expoquimR_state$lang,
                              open      = TRUE) {

  if (!is.character(lang) || length(lang) != 1L || is.na(lang) ||
      !lang %in% c("en", "es")) {
    stop("lang must be 'en' or 'es'.", call. = FALSE)
  }
  old_lang <- .expoquimR_state$lang
  on.exit(.expoquimR_state$lang <- old_lang, add = TRUE)

  for (pkg in c("rmarkdown", "knitr", "kableExtra")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(
        if (identical(lang, "es")) sprintf("Se necesita el paquete '%s' para generar informes. ", pkg) else sprintf("Package '%s' is required to generate reports. ", pkg),
        if (identical(lang, "es")) sprintf("Inst\u00e1lalo con: install.packages('%s')", pkg) else sprintf("Install it with: install.packages('%s')", pkg),
        call. = FALSE
      )
    }
  }

  if (is.null(coshh) && is.null(inrs) && is.null(une689)) {
    stop(if (identical(lang, "es")) "Debes proporcionar al menos uno de los resultados: coshh, inrs o une689." else "At least one of 'coshh', 'inrs' or 'une689' must be supplied.",
         call. = FALSE)
  }

  template <- system.file("rmd", "report_template.Rmd", package = "expoquimR")
  if (!nzchar(template)) {
    stop(if (identical(lang, "es")) "No se ha encontrado la plantilla de informe en expoquimR." else "Report template not found inside the expoquimR package.",
         call. = FALSE)
  }

  output <- .ensure_html_extension(output)
  output <- normalizePath(output, mustWork = FALSE)

  rmarkdown::render(
    input       = template,
    output_file = output,
    params      = list(
      coshh     = coshh,
      inrs      = inrs,
      une689    = une689,
      evaluator = evaluator,
      workplace = workplace,
      lang      = lang
    ),
    envir  = new.env(parent = globalenv()),
    quiet  = TRUE
  )

  message(if (identical(lang, "es")) "Informe guardado en: " else "Report saved to: ", output)

  if (isTRUE(open)) {
    utils::browseURL(output)
  }

  invisible(output)
}

# ---- rOpenSci statistical standards ----
#' @srrstats {G4.0} HTML report output filenames are normalised automatically; `.html` is appended when the user supplies a filename without an extension.
#' @srrstats {EA5.2} Numeric values presented through Shiny and rendered reports are explicitly formatted using round(), sprintf(), knitr table precision, DT numeric formatting, or the controlled graphical digits parameter rather than relying on default numeric printing.
#' @noRd
NULL
# ---- end rOpenSci statistical standards ----
