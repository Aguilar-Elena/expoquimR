# Evaluate COSHH substances from an Excel file

Reads an Excel sheet with the format of the expoquimR COSHH template
(one row per substance) and returns the complete assessment of each one
by calling
[`coshh_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_evaluate.md).

## Usage

``` r
coshh_from_excel(path, sheet = "COSHH_datos")
```

## Arguments

- path:

  Character. Path to the `.xlsx` file. Can be obtained with
  [`system.file()`](https://rdrr.io/r/base/system.file.html) for the
  template included in the package, or be any local path.

- sheet:

  Character or integer. Name or number of the sheet that contains the
  data (default `"COSHH_datos"`).

## Value

A `data.frame` with one row per substance and the result columns of
[`coshh_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_evaluate.md).

## Examples

``` r
# With the template included in the package:
path <- system.file("plantillas", "plantilla_coshh.xlsx",
                    package = "expoquimR")
coshh_from_excel(path)
#>       substance    phrases grade volatility quantity risk
#> 1       Toluene H315, H336     A     Medium   Medium    1
#> 2        Cement       H315     A       High    Large    2
#> 3 Sulfuric acid   R35, R37     C        Low    Small    1
#>                                                                       measures
#> 1                                               General ventilation. Low risk.
#> 2 Specific prevention and protection measures, e.g. local exhaust ventilation.
#> 3                                               General ventilation. Low risk.

# With your own file, simply pass its path:
# coshh_from_excel("my_coshh_data.xlsx")
```
