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
#'   manually with elements `$preliminar` and optionally `$aditivo`. If `NULL`
#'   (default), the UNE-EN 689 section is omitted.
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
#' \dontrun{
#' # COSHH only
#' res <- coshh_evaluate(
#'   nombre = "Toluene", frases = "H315, H336",
#'   cantidad = "Medium", es_liquido = TRUE,
#'   t_ebullicion = 111, t_proceso = 20
#' )
#' expoquimr_report(
#'   coshh     = res,
#'   evaluator = "Dr. Jane Smith",
#'   workplace = "Printing workshop A",
#'   output    = "report_coshh.html"
#' )
#'
#' # All three methods
#' ruta <- system.file("plantillas", "plantilla_une689.xlsx",
#'                     package = "expoquimR")
#' res_une <- une689_from_excel(ruta)
#'
#' expoquimr_report(
#'   coshh     = res,
#'   une689    = res_une,
#'   evaluator = "Dr. Jane Smith",
#'   workplace = "Printing workshop A",
#'   output    = "full_report.html",
#'   lang      = "en"
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
                              lang      = getOption("expoquimR.lang", "en"),
                              open      = TRUE) {

  for (pkg in c("rmarkdown", "knitr", "kableExtra")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(
        sprintf("Package '%s' is required to generate reports. ", pkg),
        sprintf("Install it with: install.packages('%s')", pkg),
        call. = FALSE
      )
    }
  }

  if (is.null(coshh) && is.null(inrs) && is.null(une689)) {
    stop("At least one of 'coshh', 'inrs' or 'une689' must be supplied.",
         call. = FALSE)
  }

  template <- system.file("rmd", "report_template.Rmd", package = "expoquimR")
  if (!nzchar(template)) {
    stop("Report template not found inside the expoquimR package.",
         call. = FALSE)
  }

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

  message("Report saved to: ", output)

  if (isTRUE(open)) {
    utils::browseURL(output)
  }

  invisible(output)
}
