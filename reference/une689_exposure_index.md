# Exposure index (IE) for a measurement day, per UNE-EN 689

Exposure index (IE) for a measurement day, per UNE-EN 689

## Usage

``` r
une689_exposure_index(ed, vla)
```

## Arguments

- ed:

  Numeric. Daily exposure, see
  [`une689_daily_exposure()`](https://aguilar-elena.github.io/expoquimR/reference/une689_daily_exposure.md).

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

## Value

Numeric scalar (`ed / vla`), or `NA_real_` if `ed` or `vla` are not
valid (`vla` must be `> 0`).

## Examples

``` r
une689_exposure_index(ed = 9, vla = 10)
#> [1] 0.9
```
