# One-sided risk index UR (UNE-EN 689)

One-sided risk index UR (UNE-EN 689)

## Usage

``` r
une689_ur(
  distribution_type,
  vla,
  MA = NA_real_,
  DS = NA_real_,
  MG = NA_real_,
  DSG = NA_real_
)
```

## Arguments

- distribution_type:

  Character. Distribution type; see
  [`une689_lsc()`](https://aguilar-elena.github.io/expoquimR/reference/une689_lsc.md).

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

- MA, DS, MG, DSG:

  Numeric. See
  [`une689_lsc()`](https://aguilar-elena.github.io/expoquimR/reference/une689_lsc.md).

## Value

Numeric scalar, or `NA_real_` if `distribution_type = "Neither"`.

## Examples

``` r
une689_ur("Normal", vla = 10, MA = 7.5, DS = 1.87)
#> [1] 1.336898
```
