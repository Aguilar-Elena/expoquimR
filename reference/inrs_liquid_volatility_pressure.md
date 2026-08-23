# Volatility class of a liquid from vapour pressure

Classifies the volatility of a liquid according to the official
thresholds of Table 8 of the INRS method.

## Usage

``` r
inrs_liquid_volatility_pressure(vapour_pressure)
```

## Arguments

- vapour_pressure:

  Numeric. Vapour pressure at working temperature, in kPa.

## Value

Character scalar (`"1"` if Pv \< 0.5 kPa, `"2"` if 0.5 \<= Pv \< 25 kPa,
`"3"` if Pv \>= 25 kPa).

## Examples

``` r
inrs_liquid_volatility_pressure(15)
#> [1] "2"
```
