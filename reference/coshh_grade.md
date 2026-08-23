# Determine the COSHH hazard group from R/H phrases

Looks up each risk phrase (R) or hazard phrase (H) in the COSHH
Essentials hazard group assignment table (groups A to E) and returns the
most unfavourable group found. Any phrase not listed explicitly in
groups B-E is assigned to group A, following the default rule of the
original method.

## Usage

``` r
coshh_grade(phrases)
```

## Arguments

- phrases:

  Character scalar containing one or more phrases separated by commas,
  e.g. `"H315, H319"` or `"R20/21/22"`.

## Value

Character scalar with the group (`"A"` to `"E"`), or `NA_character_` if
`phrases` is empty or `NA`.

## Examples

``` r
coshh_grade("H315, H319")
#> [1] "A"
coshh_grade("R23/24/25")
#> [1] "C"
```
