# Generate an occupational chemical exposure risk assessment report

Renders a self-contained HTML report from the results of one or more
assessment methods implemented in expoquimR. Each method section is
included only when the corresponding argument is supplied. The report
includes input data, result tables, density plots (UNE-EN 689), additive
effect groups, and a citation block for the package.

## Usage

``` r
expoquimr_report(
  coshh = NULL,
  inrs = NULL,
  une689 = NULL,
  evaluator = "",
  workplace = "",
  output = "expoquimr_report.html",
  lang = .expoquimR_state$lang,
  open = TRUE
)
```

## Arguments

- coshh:

  A `data.frame` returned by
  [`coshh_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_evaluate.md)
  or
  [`coshh_from_excel()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_from_excel.md).
  If `NULL` (default), the COSHH section is omitted.

- inrs:

  A `data.frame` returned by
  [`inrs_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_evaluate.md)
  or
  [`inrs_from_excel()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_from_excel.md).
  If `NULL` (default), the INRS section is omitted.

- une689:

  A list returned by
  [`une689_from_excel()`](https://aguilar-elena.github.io/expoquimR/reference/une689_from_excel.md)
  or constructed manually with elements `$preliminary` and optionally
  `$additive`. If `NULL` (default), the UNE-EN 689 section is omitted.

- evaluator:

  Character. Name of the person responsible for the assessment.
  Displayed in the report header. Default `""`.

- workplace:

  Character. Name or description of the workplace or workstation
  assessed. Default `""`.

- output:

  Character. Path and filename for the output HTML file. Default
  `"expoquimr_report.html"` in the current working directory.

- lang:

  Character. Language for the report body: `"en"` (English, default) or
  `"es"` (Spanish). See
  [`expoquimr_lang()`](https://aguilar-elena.github.io/expoquimR/reference/expoquimr_lang.md).

- open:

  Logical. Whether to open the report in the default browser after
  rendering. Default `TRUE`.

## Value

Invisibly returns the path to the generated HTML file.

## Examples

``` r
# \donttest{
# COSHH only
res <- coshh_evaluate(
  name = "Toluene", phrases = "H315, H336",
  quantity = "Medium", is_liquid = TRUE,
  boiling_point = 111, process_temp = 20
)
out1 <- tempfile(fileext = ".html")
expoquimr_report(
  coshh     = res,
  evaluator = "Dr. Jane Smith",
  workplace = "Printing workshop A",
  output    = out1,
  open      = FALSE
)
#> Report saved to: /tmp/RtmprMSwez/file19b51617c25f.html

# All three methods
path <- system.file("plantillas", "plantilla_une689.xlsx",
                    package = "expoquimR")
res_une <- une689_from_excel(path)

out2 <- tempfile(fileext = ".html")
expoquimr_report(
  coshh     = res,
  une689    = res_une,
  evaluator = "Dr. Jane Smith",
  workplace = "Printing workshop A",
  output    = out2,
  lang      = "en",
  open      = FALSE
)
#> Report saved to: /tmp/RtmprMSwez/file19b5782aa641.html
# }
```
