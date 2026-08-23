# Daily handled quantity class (INRS method)

Classifies the daily quantity of substance handled into one of the 5
classes of the INRS method, according to its unit.

## Usage

``` r
inrs_quantity_class(value, unit = c("g", "ml", "kg", "l"))
```

## Arguments

- value:

  Numeric. Daily quantity handled.

- unit:

  Character. One of `"g"`, `"ml"`, `"kg"`, `"l"`.

## Value

Character scalar (`"1"` to `"5"`), or `NA_character_` if `value` is
`NA`.

## Examples

``` r
inrs_quantity_class(50, "g")
#> [1] "1"
inrs_quantity_class(500, "kg")
#> [1] "4"
```
