# Evaluate INRS chemical products from an Excel file

Reads an Excel sheet with the format of the expoquimR INRS template (one
row per product) and returns the complete assessment by calling
[`inrs_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_evaluate.md).

## Usage

``` r
inrs_from_excel(path, sheet = "INRS_datos")
```

## Arguments

- path:

  Character. Path to the `.xlsx` file.

- sheet:

  Character or integer. Name or number of the sheet (default
  `"INRS_datos"`).

## Value

A `data.frame` with one row per product and all the result columns of
[`inrs_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_evaluate.md).

## Examples

``` r
path <- system.file("plantillas", "plantilla_inrs.xlsx",
                    package = "expoquimR")
inrs_from_excel(path)
#>   product hazard_class quantity_class frequency_class potential_exposure_class
#> 1 Toluene            2              2               3                        2
#> 2  Cement            3              3               3                        3
#>   potential_risk_class potential_risk_score volatility_dustiness_class
#> 1                    1                    1                          2
#> 2                    3                  100                          2
#>   volatility_dustiness_score procedure_class procedure_score protection_class
#> 1                         10               3             0.5                3
#> 2                         10               3             0.5                4
#>   protection_score vla_correction_factor inhalation_risk
#> 1              0.7                     1             3.5
#> 2              1.0                     1           500.0
#>                                                                   risk_characterisation
#> 1                               1 - Risk appears low a priori (no modifications needed)
#> 2 2 - Moderate risk (corrective measures and/or more detailed assessment likely needed)
```
