# COSHH Essentials: Qualitative Chemical Risk Assessment

## Overview

COSHH Essentials (Control of Substances Hazardous to Health) is a
qualitative control-banding method developed by the UK Health and Safety
Executive (HSE). It is designed to help employers and occupational
hygienists identify the appropriate level of control for chemical
substances without requiring exposure measurements.

The method assigns substances to one of five **hazard groups** (A to E)
based on their hazard phrases (H or R), and combines this with the
**quantity** handled daily and the **volatility** (for liquids) or
**dustiness** (for solids) to produce a **risk level** (1 to 4) with
associated recommended control measures.

## Hazard groups

| Group | Hazard level    | Typical H phrases            |
|-------|-----------------|------------------------------|
| A     | Low             | H303, H315, H319, H336       |
| B     | Moderate        | H302, H312, H332, H371       |
| C     | Significant     | H301, H311, H314, H317, H331 |
| D     | High            | H300, H310, H330, H351, H360 |
| E     | Very high (CMR) | H334, H340, H341, H350       |

Any substance with H or R phrases not listed in groups B–E is assigned
to group A by default (precautionary principle).

## Risk levels and control measures

| Risk level | Typical situation | Control approach |
|----|----|----|
| 1 | Low hazard, low quantity/volatility | General ventilation |
| 2 | Medium hazard or moderate quantity | Local exhaust ventilation |
| 3 | High hazard or large quantity | Containment or closed systems |
| 4 | CMR substances or very high hazard | Comply with CMR legislation; detailed assessment |

## Step-by-step example

### 1. Classify liquid volatility

For liquid substances, volatility is estimated from the boiling point
and the process temperature using the boundary lines defined in the
COSHH Essentials guide.

``` r

# Toluene: boiling point 111 °C, process temperature 20 °C
coshh_classify_volatility(boiling_point = 111, process_temp = 20)
#> [1] "Medium"
```

### 2. Assign the hazard group

``` r

# Toluene: H315 (skin irritation), H336 (drowsiness/dizziness)
coshh_grade("H315, H336")
#> [1] "A"
```

### 3. Obtain the risk level

``` r

coshh_risk(grade = "A", quantity = "Medium", volatility = "Medium")
#> [1] 1
```

### 4. Get the recommended control measures

``` r

coshh_measures(1)
#> [1] "General ventilation. Low risk."
```

### 5. Full assessment in one call

The high-level wrapper
[`coshh_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_evaluate.md)
chains all four steps:

``` r

coshh_evaluate(
  name          = "Toluene",
  phrases       = "H315, H336",
  quantity      = "Medium",
  is_liquid     = TRUE,
  boiling_point = 111,
  process_temp  = 20
)
#>   substance    phrases grade volatility quantity risk
#> 1   Toluene H315, H336     A     Medium   Medium    1
#>                         measures
#> 1 General ventilation. Low risk.
```

## Evaluating multiple substances

[`coshh_evaluate()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_evaluate.md)
is designed to work well with
[`lapply()`](https://rdrr.io/r/base/lapply.html) or
[`purrr::pmap()`](https://purrr.tidyverse.org/reference/pmap.html) for
batch evaluation:

``` r

substances <- list(
  list(name = "Toluene",  phrases = "H315, H336", quantity = "Medium",
       is_liquid = TRUE,  boiling_point = 111, process_temp = 20),
  list(name = "Xylene",   phrases = "H315, H336", quantity = "Large",
       is_liquid = TRUE,  boiling_point = 139, process_temp = 20),
  list(name = "Cement",   phrases = "H315",        quantity = "Large",
       is_liquid = FALSE, dustiness = "High")
)

results <- do.call(rbind, lapply(substances, function(s) {
  do.call(coshh_evaluate, s)
}))

results
#>   substance    phrases grade volatility quantity risk
#> 1   Toluene H315, H336     A     Medium   Medium    1
#> 2    Xylene H315, H336     A     Medium    Large    2
#> 3    Cement       H315     A       High    Large    2
#>                                                                       measures
#> 1                                               General ventilation. Low risk.
#> 2 Specific prevention and protection measures, e.g. local exhaust ventilation.
#> 3 Specific prevention and protection measures, e.g. local exhaust ventilation.
```

## From Excel (no coding required)

For users who prefer not to write R code, `expoquimR` includes a
ready-to-fill Excel template. Download it, fill in one row per
substance, and pass the file path to
[`coshh_from_excel()`](https://aguilar-elena.github.io/expoquimR/reference/coshh_from_excel.md):

``` r

# Access the built-in template
ruta <- system.file("plantillas", "plantilla_coshh.xlsx", package = "expoquimR")

# Or copy it to your working directory
file.copy(ruta, ".")

# Run the assessment
coshh_from_excel("plantilla_coshh.xlsx")
```

## Language

All output labels are available in English (default) and Spanish:

``` r

expoquimr_lang("es")

coshh_evaluate(
  name          = "Tolueno",
  phrases       = "H315, H336",
  quantity      = "Mediana",
  is_liquid     = TRUE,
  boiling_point = 111,
  process_temp  = 20
)
#>   substance    phrases grade volatility quantity risk
#> 1   Tolueno H315, H336     A      Media  Mediana    1
#>                            measures
#> 1 Ventilación general. Riesgo leve.

expoquimr_lang("en")  # reset to English
```

## Interactive application

For a point-and-click interface, launch the COSHH Shiny application:

``` r

run_coshh()
```

## References

- UK Health and Safety Executive (HSE). *COSHH Essentials: Easy steps to
  control chemicals.* Available at: <https://www.hse.gov.uk/coshh/>
- European Chemicals Agency (ECHA). *Understanding CLP — Hazard
  statements.* Available at: <https://echa.europa.eu/>
- Lorenzale Algarra P, Sánchez-Toledo A, Guillen Riquelme A,
  Agún-González JJ, Aguilar-Elena R (2025). Evaluation of the
  suitability of COSHH Essentials for qualitative assessment of
  inhalation risk from chemical agents in perfume laboratories: a new
  perspective. *International Journal of Occupational Safety and
  Ergonomics*. <https://doi.org/10.1080/10803548.2025.2575603>
