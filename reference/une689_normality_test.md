# Normality and lognormality tests (UNE-EN 689)

Applies the Shapiro-Wilk test to the ED values (to test normality) and
to their logarithm (to test lognormality).

## Usage

``` r
une689_normality_test(ed)
```

## Arguments

- ed:

  Numeric vector. Daily exposure (ED) values, all strictly positive. At
  least 3 values are required (minimum required by
  [`stats::shapiro.test()`](https://rdrr.io/r/stats/shapiro.test.html));
  UNE-EN 689 additionally requires a minimum of 6 for the full
  statistical assessment.

## Value

A list with elements `W_normal`, `pval_normal`, `W_lognormal`,
`pval_lognormal`.

## Examples

``` r
une689_normality_test(c(5, 6, 7, 8, 9, 10))
#> $W_normal
#> [1] 0.9818894
#> 
#> $pval_normal
#> [1] 0.960555
#> 
#> $W_lognormal
#> [1] 0.9751017
#> 
#> $pval_lognormal
#> [1] 0.9247816
#> 
```
