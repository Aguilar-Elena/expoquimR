# Complete UNE-EN 689 statistical assessment (high-level wrapper)

Chains the distribution fit, the calculation of UT, LSC(95,70), UR and
the statistical conformity from a set of daily exposure (ED) values.
Designed to be used directly from code, without going through the Shiny
application.

## Usage

``` r
une689_evaluate_statistical(ed, vla)
```

## Arguments

- ed:

  Numeric vector. ED values (one per day), all positive. A minimum of 6
  is required (see
  [`une689_validate_min_days()`](https://aguilar-elena.github.io/expoquimR/reference/une689_validate_min_days.md)).

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

## Value

A list with elements `n`, `distribution_type`, `MA`, `DS`, `MG`, `DSG`,
`W_normal`, `pval_normal`, `W_lognormal`, `pval_lognormal`, `ut`, `lsc`,
`ur`, `conformity`.

## Examples

``` r
une689_evaluate_statistical(c(5, 6, 7, 8, 9, 10), vla = 10)
#> $n
#> [1] 6
#> 
#> $distribution_type
#> [1] "Lognormal"
#> 
#> $MA
#> [1] 7.5
#> 
#> $DS
#> [1] 1.870829
#> 
#> $MG
#> [1] 7.29892
#> 
#> $DSG
#> [1] 1.295276
#> 
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
#> $ut
#> [1] 2.187
#> 
#> $lsc
#> [1] 12.85273
#> 
#> $ur
#> [1] 1.216966
#> 
#> $conformity
#> [1] "NON-CONFORMITY"
#> 
```
