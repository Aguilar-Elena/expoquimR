# Recommended monitoring interval, option 1 (MG or MA vs VLA)

Recommended monitoring interval, option 1 (MG or MA vs VLA)

## Usage

``` r
une689_monitoring_interval_opt1(reference_value, vla)
```

## Arguments

- reference_value:

  Numeric. MG if the distribution is lognormal, or MA if normal (see
  [`une689_statistics()`](https://aguilar-elena.github.io/expoquimR/reference/une689_statistics.md)).

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

## Value

Character scalar describing the recommended monitoring interval, in
months.

## Examples

``` r
une689_monitoring_interval_opt1(reference_value = 0.8, vla = 10)
#> [1] "Recommended monitoring interval: 36 months"
```
