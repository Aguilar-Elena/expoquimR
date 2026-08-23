# Evaluate a chemical product with the INRS method (high-level wrapper)

Chains all the steps of the INRS method (hazard class, quantity,
frequency, potential exposure, potential risk, volatility or dustiness,
process and collective protection) from the raw data of a product, and
returns a complete result row. Designed to be used directly from code,
without going through the Shiny application.

## Usage

``` r
inrs_evaluate(
  name,
  r_phrases = character(0),
  h_phrases = character(0),
  process = NULL,
  vla = NA_real_,
  quantity_value = NA_real_,
  quantity_unit = c("g", "ml", "kg", "l"),
  frequency_value = NA_real_,
  frequency_unit = c("minutes", "hours", "days", "months", "not_used"),
  substance_type = c("liquid", "solid"),
  liquid_method = c("graph", "pressure"),
  use_temperature = NA_real_,
  boiling_point = NA_real_,
  vapour_pressure = NA_real_,
  solid_description = NA_character_,
  procedure,
  protection
)
```

## Arguments

- name:

  Character. Name of the product.

- r_phrases, h_phrases:

  Character vectors. See
  [`inrs_hazard_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_hazard_class.md).

- process:

  Character. See
  [`inrs_hazard_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_hazard_class.md).

- vla:

  Numeric. VLA in mg/m3.

- quantity_value, quantity_unit:

  See
  [`inrs_quantity_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_quantity_class.md).

- frequency_value, frequency_unit:

  See
  [`inrs_frequency_class()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_frequency_class.md).

- substance_type:

  Character. `"liquid"` or `"solid"`.

- liquid_method:

  Character. `"graph"` or `"pressure"`. Only used if
  `substance_type = "liquid"`.

- use_temperature, boiling_point:

  Numeric. Only if `liquid_method = "graph"`.

- vapour_pressure:

  Numeric. Only if `liquid_method = "pressure"`.

- solid_description:

  Character. Only if `substance_type = "solid"`. See
  [`inrs_solid_dustiness()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_solid_dustiness.md).

- procedure:

  Character. See
  [`inrs_process_type()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_process_type.md).

- protection:

  Character. See
  [`inrs_collective_protection()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_collective_protection.md).

## Value

A one-row `data.frame` with all the intermediate classes and scores, the
final inhalation risk score and its characterisation.

## Examples

``` r
inrs_evaluate(
  name = "Solvent X",
  h_phrases = "H336",
  vla = 50,
  quantity_value = 5, quantity_unit = "l",
  frequency_value = 3, frequency_unit = "hours",
  substance_type = "liquid",
  liquid_method = "graph",
  use_temperature = 40, boiling_point = 80,
  procedure = "Open",
  protection = "Moderate dispersion conditions"
)
#>     product hazard_class quantity_class frequency_class
#> 1 Solvent X            2              2               3
#>   potential_exposure_class potential_risk_class potential_risk_score
#> 1                        2                    1                    1
#>   volatility_dustiness_class volatility_dustiness_score procedure_class
#> 1                          3                        100               3
#>   procedure_score protection_class protection_score vla_correction_factor
#> 1             0.5                3              0.7                     1
#>   inhalation_risk                                   risk_characterisation
#> 1              35 1 - Risk appears low a priori (no modifications needed)
```
