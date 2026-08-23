# Recommended monitoring interval, option 2 (LSC95,70 vs VLA)

Recommended monitoring interval, option 2 (LSC95,70 vs VLA)

## Usage

``` r
une689_monitoring_interval_opt2(lsc, vla)
```

## Arguments

- lsc:

  Numeric. LSC(95,70), see
  [`une689_lsc()`](https://aguilar-elena.github.io/expoquimR/reference/une689_lsc.md).

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

## Value

Character scalar describing the recommended monitoring interval, in
months, or a warning that exposure must be reviewed.

## Examples

``` r
une689_monitoring_interval_opt2(lsc = 4, vla = 10)
#> [1] "Recommended monitoring interval: 30 months"
```
