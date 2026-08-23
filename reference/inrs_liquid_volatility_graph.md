# Volatility class of a liquid from use temperature and boiling point

Classifies the volatility of a liquid by comparing its boiling point
with the two class-separating lines of the INRS method graph (Figure 2,
use temperature on the X axis, boiling point on the Y axis).

## Usage

``` r
inrs_liquid_volatility_graph(use_temperature, boiling_point)
```

## Arguments

- use_temperature:

  Numeric. Use (process) temperature, in degrees Celsius. Corresponds to
  the X axis of the graph.

- boiling_point:

  Numeric. Boiling point, in degrees Celsius. Corresponds to the Y axis
  of the graph.

## Value

Character scalar (`"1"` low, `"2"` medium, `"3"` high).

## Examples

``` r
inrs_liquid_volatility_graph(use_temperature = 20, boiling_point = 200)
#> [1] "1"
inrs_liquid_volatility_graph(use_temperature = 20, boiling_point = 80)
#> [1] "3"
```
