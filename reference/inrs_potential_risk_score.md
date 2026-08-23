# Potential risk score (INRS method)

Potential risk score (INRS method)

## Usage

``` r
inrs_potential_risk_score(potential_risk_class)
```

## Arguments

- potential_risk_class:

  Character. See
  [`inrs_potential_risk_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_potential_risk_class.md).

## Value

Numeric (1, 10, 100, 1000 or 10000), or `NA_real_`.

## Examples

``` r
inrs_potential_risk_score("3")
#> [1] 100
```
