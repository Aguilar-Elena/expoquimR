# Upper confidence limit LSC(95,70) (UNE-EN 689)

Upper confidence limit LSC(95,70) (UNE-EN 689)

## Usage

``` r
une689_lsc(
  distribution_type,
  ut,
  MA = NA_real_,
  DS = NA_real_,
  MG = NA_real_,
  DSG = NA_real_
)
```

## Arguments

- distribution_type:

  Character. Distribution type as returned by
  [`une689_distribution_type()`](https://aguilar-elena.github.io/expoquimR/reference/une689_distribution_type.md).
  Accepts both English (`"Lognormal"`, `"Normal"`, `"Neither"`) and
  Spanish labels.

- ut:

  Numeric. UT factor, see
  [`une689_ut()`](https://aguilar-elena.github.io/expoquimR/reference/une689_ut.md).

- MA, DS:

  Numeric. Arithmetic mean and standard deviation (only needed when
  `distribution_type = "Normal"`); see
  [`une689_statistics()`](https://aguilar-elena.github.io/expoquimR/reference/une689_statistics.md).

- MG, DSG:

  Numeric. Geometric mean and standard deviation (only needed when
  `distribution_type = "Lognormal"`); see
  [`une689_statistics()`](https://aguilar-elena.github.io/expoquimR/reference/une689_statistics.md).

## Value

Numeric scalar with the LSC(95,70), or `NA_real_` if
`distribution_type = "Neither"` (or `"Ninguna"` in Spanish).

## Examples

``` r
une689_lsc("Normal", ut = 2.005, MA = 7.5, DS = 1.87)
#> [1] 11.24935
```
