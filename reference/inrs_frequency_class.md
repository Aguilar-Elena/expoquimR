# Frequency of use class (INRS method)

Converts the given frequency of use to the reference units of Table 3 of
the INRS method (hours/day or days/month or days/year, depending on the
input unit) and returns the corresponding class (0 to 4).

## Usage

``` r
inrs_frequency_class(
  value = NA_real_,
  unit = c("minutes", "hours", "days", "months", "not_used")
)
```

## Arguments

- value:

  Numeric. Frequency value. Ignored if `unit = "not_used"`.

- unit:

  Character. One of `"minutes"`, `"hours"`, `"days"`, `"months"`,
  `"not_used"` (the latter for substances that are not used with a
  periodic frequency, and always returns class `"0"`).

## Value

Character scalar (`"0"` to `"4"`), or `NA_character_` if there is no
match in the reference table.

## Examples

``` r
inrs_frequency_class(3, "hours")
#> [1] "3"
inrs_frequency_class(unit = "not_used")
#> [1] "0"
```
