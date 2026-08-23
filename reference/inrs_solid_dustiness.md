# Dustiness class of a solid (INRS method)

Dustiness class of a solid (INRS method)

## Usage

``` r
inrs_solid_dustiness(description)
```

## Arguments

- description:

  Character. One of
  `"Dust that generates a lot of visible dispersion in the air"`,
  `"Fine dust with little visible dispersion"` or
  `"Compact solid with no visible dust"`.

## Value

Character scalar (`"1"` to `"3"`), or `NA_character_` if `description`
does not match any valid option.

## Examples

``` r
inrs_solid_dustiness("Fine dust with little visible dispersion")
#> [1] "2"
```
