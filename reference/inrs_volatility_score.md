# Volatility or dustiness score (INRS method)

Volatility or dustiness score (INRS method)

## Usage

``` r
inrs_volatility_score(volatility_class)
```

## Arguments

- volatility_class:

  Character. `"1"`, `"2"` or `"3"`, as returned by
  [`inrs_liquid_volatility_graph()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_liquid_volatility_graph.md),
  [`inrs_liquid_volatility_pressure()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_liquid_volatility_pressure.md)
  or
  [`inrs_solid_dustiness()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_solid_dustiness.md).

## Value

Numeric (1, 10 or 100), or `NA_real_`.

## Examples

``` r
inrs_volatility_score("2")
#> [1] 10
```
