# Potential risk class (INRS method)

Consults Table 5 of the INRS method (potential exposure class x hazard
class) to obtain the potential risk class.

## Usage

``` r
inrs_potential_risk_class(potential_exposure_class, hazard_class)
```

## Arguments

- potential_exposure_class:

  Character. See
  [`inrs_potential_exposure_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_potential_exposure_class.md).

- hazard_class:

  Character. See
  [`inrs_hazard_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_hazard_class.md).

## Value

Character scalar (`"1"` to `"5"`), or `NA_character_` if the combination
is not defined.

## Examples

``` r
inrs_potential_risk_class("4", "3")
#> [1] "3"
```
