# Complete UNE-EN 689 preliminary assessment (high-level wrapper)

Calculates the ED and IE for each day and classifies the overall
conformity, from a set of samples organised by measurement day. Designed
to be used directly from code, without going through the Shiny
application.

## Usage

``` r
une689_evaluate_preliminary(data, vla)
```

## Arguments

- data:

  A `data.frame` in long format with columns `day` (day identifier,
  numeric or character), `concentration` (mg/m3) and `time` (hours). One
  row per sample.

- vla:

  Numeric. Valor Limite Ambiental / occupational exposure limit (mg/m3).

## Value

A list with two elements:

- `days_table`:

  A `data.frame` with columns `day`, `ED` and `IE`, one row per day.

- `result`:

  Character scalar with the overall classification, see
  [`une689_classify_conformity()`](https://aguilar-elena.github.io/expoquimR/reference/une689_classify_conformity.md).

## Examples

``` r
data <- data.frame(
  day = c(1, 1, 2, 3, 3),
  concentration = c(12, 8, 9, 5, 6),
  time = c(4, 4, 8, 3, 5)
)
une689_evaluate_preliminary(data, vla = 10)
#> $days_table
#>   day     ED     IE
#> 1   1 10.000 1.0000
#> 2   2  9.000 0.9000
#> 3   3  5.625 0.5625
#> 
#> $result
#> [1] "NO DECISION"
#> 
```
