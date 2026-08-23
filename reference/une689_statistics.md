# Descriptive statistics of daily exposure (UNE-EN 689)

Calculates the arithmetic mean and standard deviation (MA, DS) and the
geometric mean and standard deviation (MG, DSG) of a set of daily
exposure (ED) values, needed to test the normal and lognormal fits.

## Usage

``` r
une689_statistics(ed)
```

## Arguments

- ed:

  Numeric vector. Daily exposure (ED) values, all strictly positive.

## Value

A list with elements `MA`, `DS`, `MG`, `DSG`.

## Examples

``` r
une689_statistics(c(5, 6, 7, 8, 9, 10))
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
```
