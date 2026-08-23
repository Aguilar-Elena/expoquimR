# Evaluate a substance using the COSHH Essentials method (high-level wrapper)

Chains
[`coshh_grade()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_grade.md),
[`coshh_classify_volatility()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_classify_volatility.md)
(if applicable),
[`coshh_risk()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_risk.md)
and
[`coshh_measures()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_measures.md)
to produce a complete result row from the raw data of a substance.
Designed to be called directly from code (scripts, reports,
[`purrr::pmap`](https://purrr.tidyverse.org/reference/pmap.html),
vignettes) without going through the Shiny application.

## Usage

``` r
coshh_evaluate(
  name,
  phrases,
  quantity,
  is_liquid,
  boiling_point = NA_real_,
  process_temp = NA_real_,
  dustiness = NA_character_
)
```

## Arguments

- name:

  Character. Identifying name of the substance.

- phrases:

  Character. H/R phrases; see
  [`coshh_grade()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_grade.md).

- quantity:

  Character. Quantity class in the active language.

- is_liquid:

  Logical. `TRUE` if the substance is liquid (volatility will be
  calculated from `boiling_point` / `process_temp`); `FALSE` if solid
  (`dustiness` will be used directly).

- boiling_point, process_temp:

  Numeric. Required only if `is_liquid = TRUE`. See
  [`coshh_classify_volatility()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_classify_volatility.md).

- dustiness:

  Character. Required only if `is_liquid = FALSE`. Dustiness class in
  the active language.

## Value

A one-row `data.frame` with columns `substance`, `phrases`, `grade`,
`volatility`, `quantity`, `risk` and `measures`.

## Details

Output labels (volatility class, quantity class, control measures) are
returned in the active language; see
[`expoquimr_lang()`](https://aguilar-elena.github.io/expoquimR/reference/expoquimr_lang.md).

## Examples

``` r
coshh_evaluate(
  name = "Toluene",
  phrases = "H315, H336",
  quantity = "Medium",
  is_liquid = TRUE,
  boiling_point = 111,
  process_temp = 20
)
#>   substance    phrases grade volatility quantity risk
#> 1   Toluene H315, H336     A     Medium   Medium    1
#>                         measures
#> 1 General ventilation. Low risk.
```
