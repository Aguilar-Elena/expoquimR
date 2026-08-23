# Check the minimum number of days for the preliminary assessment

The UNE-EN 689 preliminary assessment requires a minimum number of
evaluated days (usually 3). Helper function to validate this before
calculating, both from code and from the Shiny app.

## Usage

``` r
une689_validate_min_days(n_days, minimum = 3L)
```

## Arguments

- n_days:

  Integer. Number of days with data entered.

- minimum:

  Integer. Minimum number required (default 3).

## Value

Logical: `TRUE` if `n_days >= minimum`.

## Examples

``` r
une689_validate_min_days(2)
#> [1] FALSE
une689_validate_min_days(3)
#> [1] TRUE
```
