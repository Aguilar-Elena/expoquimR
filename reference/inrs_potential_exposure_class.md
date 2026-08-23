# Potential exposure class (INRS method)

Consults Table 4 of the INRS method (quantity class x frequency class)
to obtain the potential exposure class.

## Usage

``` r
inrs_potential_exposure_class(quantity_class, frequency_class)
```

## Arguments

- quantity_class:

  Character. See
  [`inrs_quantity_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_quantity_class.md).

- frequency_class:

  Character. See
  [`inrs_frequency_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_frequency_class.md).

## Value

Character scalar (`"0"` to `"5"`), or `NA_character_` if the combination
is not defined.

## Examples

``` r
inrs_potential_exposure_class("3", "2")
#> [1] "3"
```
