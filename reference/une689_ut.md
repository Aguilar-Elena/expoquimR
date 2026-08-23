# UNE-EN 689 UT factor from the sample size

Looks up the one-sided tolerance factor (UT) tabulated by UNE-EN 689 for
a number of days `n` between 6 and 30. For `n > 30` the limit value
1.820 is used, as established by the standard.

## Usage

``` r
une689_ut(n)
```

## Arguments

- n:

  Integer. Number of days (ED measurements) used in the statistical
  assessment. Must be `>= 6`.

## Value

Numeric scalar with the UT value, or `NA_real_` if `n < 6`.

## Examples

``` r
une689_ut(6)
#> [1] 2.187
une689_ut(50)
#> [1] 1.82
```
