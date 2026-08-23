# INRS Method: Qualitative Inhalation Risk Assessment

## Overview

The INRS method is a qualitative control-banding approach for assessing
the risk of inhalation of chemical agents, developed by the French
National Research and Safety Institute (INRS). Unlike COSHH Essentials,
which produces a categorical risk level, the INRS method calculates a
continuous **inhalation risk score** as the product of five partial
scores, each reflecting a different dimension of the exposure situation.

The final score is compared against three risk bands to determine the
appropriate level of action.

## The five-factor cascade

| Factor | Source | Score range |
|----|----|----|
| Hazard potential | Hazard class (1–5) from H/R phrases, process or VLA | 1–10 000 |
| Quantity × Frequency | Exposure potential class (0–5) | 1–10 000 |
| Volatility / Dustiness | Physical state and conditions | 1, 10 or 100 |
| Process type | Degree of containment | 0.001–1 |
| Collective protection | Ventilation or enclosure | 0.001–10 |

The inhalation risk score is the product of all five:

    Score = Hazard_potential × Volatility × Process × Protection × FC_VLA

## Risk bands

| Score | Risk band | Recommended action |
|----|----|----|
| ≤ 100 | Low | No modifications needed a priori |
| 101–1 000 | Moderate | Corrective measures or detailed assessment likely needed |
| \> 1 000 | Very high | Immediate corrective action required |

## Step-by-step example

### 1. Hazard class

The hazard class (1–5) is determined from H phrases, R phrases, material
and process type, or VLA. The method explores from class 5 downwards and
returns the first match. If nothing matches classes 2–5, class 1 is
assigned by default.

``` r

# From H phrases
inrs_hazard_class(h_phrases = "H336")
#> [1] "2"

# From VLA
inrs_hazard_class(vla = 0.05)   # <= 0.1 mg/m³ → class 5
#> [1] "5"
inrs_hazard_class(vla = 50)     # > 10 mg/m³   → class 1 (default)
#> [1] "2"
```

### 2. Quantity and frequency classes

``` r

inrs_quantity_class(5, "l")          # 5 litres → class 2
#> [1] "2"
inrs_frequency_class(3, "hours")    # 3 hours/day → class 3
#> [1] "3"
```

### 3. Exposure potential

``` r

inrs_potential_exposure_class("2", "3")   # → class 2
#> [1] "2"
inrs_potential_risk_score("2")        # → 10
#> [1] 10
```

### 4. Volatility (liquid)

Two approaches are available:

``` r

# From boiling point graph (official INRS Figure 2)
inrs_liquid_volatility_graph(use_temperature = 20, boiling_point = 111)
#> [1] "2"

# From vapour pressure (Table 8 thresholds: 0.5 kPa / 25 kPa)
inrs_liquid_volatility_pressure(vapour_pressure = 5)
#> [1] "2"
```

For solids, dustiness is classified by description:

``` r

inrs_solid_dustiness("Fine dust with little visible dispersion")
#> [1] "2"
```

### 5. Process and collective protection

``` r

inrs_process_type("Open")
#>   class score
#> 2     3   0.5
inrs_collective_protection("Moderate dispersion conditions")
#>   class score
#> 3     3   0.7
```

### 6. VLA correction factor

``` r

inrs_oel_correction_factor(vla = 50)    # VLA > 0.1 → FC = 1
#> [1] 1
inrs_oel_correction_factor(vla = 0.05)  # VLA <= 0.1 → FC = 10
#> [1] 10
```

### 7. Final inhalation risk score

``` r

inrs_inhalation_risk(
  potential_risk_score  = 10,
  volatility_score      = 10,
  procedure_score       = 0.5,
  protection_score      = 0.7,
  vla_correction_factor = 1
)
#> [1] 35
```

### 8. Risk characterisation

``` r

inrs_risk_characterisation(35)
#> [1] "1 - Risk appears low a priori (no modifications needed)"
inrs_risk_characterisation(500)
#> [1] "2 - Moderate risk (corrective measures and/or more detailed assessment likely needed)"
inrs_risk_characterisation(5000)
#> [1] "3 - Very high risk (immediate corrective action required)"
```

## Full assessment in one call

``` r

inrs_evaluate(
  name             = "Toluene",
  h_phrases        = "H336",
  vla              = 50,
  quantity_value   = 5,
  quantity_unit    = "l",
  frequency_value  = 3,
  frequency_unit   = "hours",
  substance_type   = "liquid",
  liquid_method    = "graph",
  use_temperature  = 20,
  boiling_point    = 111,
  procedure        = "Open",
  protection       = "Moderate dispersion conditions"
)
#>   product hazard_class quantity_class frequency_class potential_exposure_class
#> 1 Toluene            2              2               3                        2
#>   potential_risk_class potential_risk_score volatility_dustiness_class
#> 1                    1                    1                          2
#>   volatility_dustiness_score procedure_class procedure_score protection_class
#> 1                         10               3             0.5                3
#>   protection_score vla_correction_factor inhalation_risk
#> 1              0.7                     1             3.5
#>                                     risk_characterisation
#> 1 1 - Risk appears low a priori (no modifications needed)
```

## From Excel (no coding required)

``` r

ruta <- system.file("plantillas", "plantilla_inrs.xlsx", package = "expoquimR")
inrs_from_excel(ruta)
```

## Language

``` r

expoquimr_lang("es")
inrs_risk_characterisation(35)
#> [1] "1 - Riesgo a priori bajo (sin necesidad de modificaciones)"
inrs_risk_characterisation(5000)
#> [1] "3 - Riesgo muy elevado (medidas correctoras inmediatas requeridas)"
expoquimr_lang("en")
```

## Interactive application

``` r

run_inrs()
```

The INRS Shiny application allows the user to evaluate up to 10 products
in a single session. Results are displayed in two panels: a summary
table with the key classes and the final risk score, and a collapsible
detail panel showing all intermediate scores for audit purposes.

## References

- INRS. *Evaluation du risque chimique par inhalation — Methode
  d’evaluation simplifiee du risque chimique.* ND 2233. Available at:
  <https://www.inrs.fr/>
