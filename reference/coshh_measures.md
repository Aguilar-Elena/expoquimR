# Get the recommended control measures for a COSHH risk level

Get the recommended control measures for a COSHH risk level

## Usage

``` r
coshh_measures(risk_level)
```

## Arguments

- risk_level:

  Integer or character. Risk level (1 to 4), as returned by
  [`coshh_risk()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_risk.md).

## Value

Character scalar with the recommended control measures in the active
language (see
[`expoquimr_lang()`](https://aguilar-elena.github.io/expoquimR/reference/expoquimr_lang.md)),
or `NA_character_` if the level is not defined.

## Examples

``` r
coshh_measures(3)
#> [1] "Containment or closed systems. Keep process below atmospheric pressure where possible."
expoquimr_lang("es")
coshh_measures(3)
#> [1] "Confinamiento o sistemas cerrados. Mantener el proceso a presión inferior a la atmosférica cuando sea posible."
expoquimr_lang("en")
```
