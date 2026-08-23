# VLA correction factor (INRS method)

VLA correction factor (INRS method)

## Usage

``` r
inrs_oel_correction_factor(vla)
```

## Arguments

- vla:

  Numeric. VLA in mg/m3.

## Value

Numeric (1, 10, 30 or 100), or `NA_real_` if `vla` is `NA`.

## Examples

``` r
inrs_oel_correction_factor(0.05)
#> [1] 10
```
