# Conformity of the statistical assessment (UNE-EN 689)

Conformity of the statistical assessment (UNE-EN 689)

## Usage

``` r
une689_statistical_conformity(ur, ut)
```

## Arguments

- ur:

  Numeric. One-sided risk index, see
  [`une689_ur()`](https://aguilar-elena.github.io/expoquimR/reference/une689_ur.md).

- ut:

  Numeric. UT factor, see
  [`une689_ut()`](https://aguilar-elena.github.io/expoquimR/reference/une689_ut.md).

## Value

Character scalar: `"CONFORMITY"` if `ur >= ut`, `"NON-CONFORMITY"` if
`ur < ut`, or `NA_character_` if `ur` is `NA` (e.g. when neither the
normal nor the lognormal fit is adequate). Labels are returned in the
active language; see
[`expoquimr_lang()`](https://aguilar-elena.github.io/expoquimR/reference/expoquimr_lang.md).

## Examples

``` r
une689_statistical_conformity(ur = 2.1, ut = 2.005)
#> [1] "CONFORMITY"
```
