# Calculate the COSHH risk level

Queries the hazard x quantity x volatility matrix of the COSHH
Essentials method to obtain the potential risk level (1 to 4).
Substances of grade `"E"` (carcinogenic, mutagenic or similar) always
receive the maximum level, regardless of quantity or volatility.

## Usage

``` r
coshh_risk(grade, quantity, volatility)
```

## Arguments

- grade:

  Character. Hazard group (`"A"` to `"E"`), as returned by
  [`coshh_grade()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_grade.md).

- quantity:

  Character. Quantity class in the active language. Use `"Small"` /
  `"Medium"` / `"Large"` (English) or `"Pequeña"` / `"Mediana"` /
  `"Grande"` (Spanish).

- volatility:

  Character. Volatility class in the active language. Use `"Low"` /
  `"Medium"` / `"High"` (English) or `"Baja"` / `"Media"` / `"Alta"`
  (Spanish). For solids, this corresponds to dustiness.

## Value

Integer with the risk level (1 to 4), or `NA_integer_` if the
combination is not defined in the table or `grade` is `NA`.

## Examples

``` r
coshh_risk(grade = "C", quantity = "Medium", volatility = "High")
#> [1] 3
coshh_risk(grade = "E", quantity = "Small",  volatility = "Low")
#> [1] 4
```
