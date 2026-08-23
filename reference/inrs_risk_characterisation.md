# Inhalation risk characterisation (INRS method)

Inhalation risk characterisation (INRS method)

## Usage

``` r
inrs_risk_characterisation(inhalation_risk)
```

## Arguments

- inhalation_risk:

  Numeric. See
  [`inrs_inhalation_risk()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_inhalation_risk.md).

## Value

Character scalar describing the action priority, or `NA_character_` if
`inhalation_risk` is `NA`.

## Examples

``` r
inrs_risk_characterisation(2500)
#> [1] "3 - Very high risk (immediate corrective action required)"
```
