# expoquimR <img src="man/figures/logo.png" align="right" height="120" alt="expoquimR logo"/>

**Qualitative and Quantitative Assessment of Occupational Chemical Exposure Risk**

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/expoquimR)](https://CRAN.R-project.org/package=expoquimR)
[![R-CMD-check](https://github.com/Aguilar-Elena/expoquimR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Aguilar-Elena/expoquimR/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

`expoquimR` is an R package for **occupational chemical exposure risk assessment**.

It is designed for occupational hygienists, health and safety technicians, prevention practitioners, researchers and engineers who need to evaluate whether workers are exposed to hazardous chemical agents above acceptable limits — and what preventive or corrective action is required.

Unlike generic statistical tools, `expoquimR` implements three internationally recognised assessment methods end to end, from raw measurement data to a final conformity decision. Every step of each method is available as a small, independently callable and unit-tested R function, so assessments are fully reproducible and auditable without depending on any graphical interface. Optional Shiny applications provide a guided interactive workflow for practitioners who prefer not to write code. Data can also be provided via Excel templates, with no programming required.

<hr>

## Why expoquimR?

Chemical risk assessment in occupational settings typically follows one of two paradigms:

**Qualitative control-banding** assigns substances to hazard and risk bands based on physicochemical properties and use patterns, without requiring exposure measurements. It is fast, cost-effective and suitable for initial screening and small-to-medium workplaces.

**Quantitative statistical assessment** uses actual exposure measurements collected over multiple working days and applies statistical inference to decide, with a defined level of confidence, whether exposure is below the occupational exposure limit (OEL).

Both paradigms are needed in practice. Yet most available software implements only one of them, in a closed graphical interface that prevents reproducibility, automation or integration with other analyses.

`expoquimR` was created to fill this gap.

It helps answer questions such as:

- Does this substance qualify as low, medium or high hazard under COSHH or INRS control-banding?
- What control measures are recommended for this combination of hazard, quantity and volatility?
- Is the statistical evidence sufficient to declare conformity with the OEL?
- How frequently should exposure measurements be repeated?
- If workers are simultaneously exposed to several agents affecting the same target organ, is the combined exposure within acceptable limits?

<hr>

## What does expoquimR do?

`expoquimR` implements three assessment methods, each available as a set of step-by-step functions and a high-level wrapper, as an interactive Shiny application, and via Excel-based input:

1. **COSHH Essentials** — qualitative control-banding method developed by the UK Health and Safety Executive. Assigns a hazard group (A–E) from H or R phrases and combines it with the quantity handled and the volatility or dustiness to produce a risk level (1–4) and recommended control measures.

2. **INRS method** — qualitative control-banding method developed by the French National Research and Safety Institute (INRS). Calculates an inhalation risk score as the product of five partial scores: hazard potential, quantity, frequency of use, volatility or dustiness, process type and collective protection.

3. **UNE-EN 689** — quantitative statistical method defined by the European standard EN 689. Implements the two-stage procedure: a preliminary assessment (minimum 3 measurement days) followed, if necessary, by a full statistical assessment (minimum 6 days) based on lognormal or normal distribution fitting, one-sided tolerance limits and monitoring-interval recommendations.

<hr>

## Main functions

| Function | Method | What it does |
|---|---|---|
| `coshh_classify_volatility()` | COSHH | Classifies liquid volatility from boiling point and process temperature |
| `coshh_grade()` | COSHH | Assigns hazard group A–E from H/R phrases |
| `coshh_risk()` | COSHH | Returns risk level 1–4 from group, quantity and volatility |
| `coshh_measures()` | COSHH | Returns recommended control measures for a risk level |
| `coshh_evaluate()` | COSHH | Full COSHH assessment in one call |
| `coshh_from_excel()` | COSHH | Reads an Excel template and evaluates all substances |
| `inrs_hazard_class()` | INRS | Assigns hazard class 1–5 from H/R phrases, process or VLA |
| `inrs_quantity_class()` | INRS | Classifies daily quantity handled |
| `inrs_frequency_class()` | INRS | Classifies frequency of use |
| `inrs_liquid_volatility_graph()` | INRS | Classifies liquid volatility from the official INRS graph |
| `inrs_liquid_volatility_pressure()` | INRS | Classifies liquid volatility from vapour pressure |
| `inrs_inhalation_risk()` | INRS | Calculates the final inhalation risk score |
| `inrs_risk_characterisation()` | INRS | Characterises the risk band from the score |
| `inrs_evaluate()` | INRS | Full INRS assessment in one call |
| `inrs_from_excel()` | INRS | Reads an Excel template and evaluates all products |
| `une689_daily_exposure()` | UNE-EN 689 | Calculates daily exposure (ED) from samples and times |
| `une689_exposure_index()` | UNE-EN 689 | Calculates exposure index (IE = ED / VLA) |
| `une689_classify_conformity()` | UNE-EN 689 | Classifies conformity from a set of IE values |
| `une689_evaluate_preliminary()` | UNE-EN 689 | Full preliminary assessment from a data frame of measurements |
| `une689_statistics()` | UNE-EN 689 | Computes MA, DS, MG, DSG from ED values |
| `une689_normality_test()` | UNE-EN 689 | Shapiro-Wilk test for normality and lognormality |
| `une689_distribution_type()` | UNE-EN 689 | Infers the best-fitting distribution |
| `une689_lsc()` | UNE-EN 689 | Computes the one-sided tolerance limit LSC(95,70) |
| `une689_ur()` | UNE-EN 689 | Computes the risk index UR |
| `une689_statistical_conformity()` | UNE-EN 689 | Declares conformity or non-conformity (UR vs UT) |
| `une689_evaluate_statistical()` | UNE-EN 689 | Full statistical assessment in one call |
| `une689_monitoring_interval_opt1()` | UNE-EN 689 | Monitoring interval recommendation (MG or MA vs VLA) |
| `une689_monitoring_interval_opt2()` | UNE-EN 689 | Monitoring interval recommendation (LSC vs VLA) |
| `une689_from_excel()` | UNE-EN 689 | Reads a three-sheet Excel template and runs the full workflow |
| `run_coshh()` | COSHH | Launches the interactive Shiny application |
| `run_inrs()` | INRS | Launches the interactive Shiny application |
| `run_une689()` | UNE-EN 689 | Launches the interactive Shiny application |
| `expoquimr_lang()` | All | Gets or sets the active language (English/Spanish) |

<hr>

## Installation

```r
# From CRAN (once published):
install.packages("expoquimR")

# Development version from GitHub:
# install.packages("remotes")
remotes::install_github("Aguilar-Elena/expoquimR")
```

<hr>

## Language

`expoquimR` is fully bilingual. All function output labels, result strings and error messages are available in **English** (default) and **Spanish**.

```r
expoquimr_lang()        # query current language — returns "en"
expoquimr_lang("es")    # switch to Spanish
expoquimr_lang("en")    # switch back to English
```

The Shiny applications include an in-app language selector and do not depend on `expoquimr_lang()`.

<hr>

## Minimal usage

> **Note on argument names:** function arguments follow the terminology of
> the original normative documents (e.g. `vla` for occupational exposure
> limit, `frases_h` for H-phrases). String values such as quantity classes,
> process types and protection systems are language-sensitive and respond to
> [expoquimr_lang()].

### COSHH Essentials

```r
library(expoquimR)

coshh_evaluate(
  nombre       = "Toluene",
  frases       = "H315, H336",
  cantidad     = "Medium",
  es_liquido   = TRUE,
  t_ebullicion = 111,
  t_proceso    = 20
)
```

### INRS

```r
inrs_evaluate(
  nombre            = "Toluene",
  frases_h          = "H336",
  vla               = 50,
  cantidad_valor    = 5,
  cantidad_unidad   = "l",
  frecuencia_valor  = 3,
  frecuencia_unidad = "horas",
  tipo_sustancia    = "liquida",
  metodo_liquido    = "grafico",
  temperatura_uso   = 20,
  punto_ebullicion  = 111,
  procedimiento     = "Abierto",
  proteccion        = "Condiciones moderadas de dispersion"
)
```

### UNE-EN 689

```r
# Preliminary assessment
datos <- data.frame(
  jornada       = c(1, 1, 2, 3, 3),   # measurement day
  concentracion = c(12, 8, 9, 5, 6),  # concentration (mg/m³)
  tiempo        = c(4,  4, 8, 3, 5)   # duration (hours)
)
une689_evaluate_preliminary(datos, vla = 10)

# Statistical assessment (>= 6 measurement days)
ed_values <- c(10, 9, 5.6, 11, 8, 13)
une689_evaluate_statistical(ed_values, vla = 10)
```

### Interactive applications

```r
run_coshh()    # COSHH Essentials app
run_inrs()     # INRS app
run_une689()   # UNE-EN 689 app (multi-agent, additive effects, full workflow)
```

### From Excel (no coding required)

```r
# Copy the template to your working directory, fill it in, then:
ruta <- system.file("plantillas", "plantilla_coshh.xlsx", package = "expoquimR")
coshh_from_excel(ruta)

ruta <- system.file("plantillas", "plantilla_inrs.xlsx", package = "expoquimR")
inrs_from_excel(ruta)

ruta <- system.file("plantillas", "plantilla_une689.xlsx", package = "expoquimR")
une689_from_excel(ruta)   # returns preliminary results, statistical assessment and additive effects
```

<hr>

## Additive effects (UNE-EN 689)

When workers are simultaneously exposed to multiple chemical agents affecting the same target organ, the European standard requires that the combined exposure index be evaluated:

```
IE_combined = IE_agent1 + IE_agent2 + ... + IE_agentN
```

Conformity requires IE_combined ≤ 1. The `une689_from_excel()` function handles this automatically from the `Additive_effects` sheet of the UNE-EN 689 template. The Shiny application allows the user to define independent additive groups interactively, where each group covers a different target organ and agents can appear in more than one group.

<hr>

## Excel templates

`expoquimR` includes ready-to-fill Excel templates for all three methods. Each template includes an **Instructions** sheet with accepted values for every field.

```r
# Open the templates folder
browseURL(system.file("plantillas", package = "expoquimR"))

# Or copy a template to your working directory
file.copy(
  system.file("plantillas", "plantilla_coshh.xlsx", package = "expoquimR"), "."
)
file.copy(
  system.file("plantillas", "plantilla_inrs.xlsx",  package = "expoquimR"), "."
)
file.copy(
  system.file("plantillas", "plantilla_une689.xlsx", package = "expoquimR"), "."
)
```

The UNE-EN 689 template has three sheets: **Agents** (name and VLA), **Measurements** (one row per sample, with a `tipo` field to distinguish preliminary from additional measurement days), and **Additive_effects** (optional, for groups of agents sharing a target organ).

<hr>

## Outputs

After running the high-level wrapper functions or `*_desde_excel()`:

| Output | Description |
|---|---|
| `data.frame` of results | One row per substance or agent, all intermediate steps and final decision |
| Risk level or score | Numeric value (COSHH: 1–4; INRS: continuous score; UNE-EN 689: UR vs UT) |
| Recommended control measures | Text in the active language (COSHH and INRS) |
| Conformity decision | CONFORMITY / NON-CONFORMITY / NO DECISION (UNE-EN 689) |
| Statistical parameters | MG, DSG, MA, DS, W, p-value, UT, LSC(95,70), UR (UNE-EN 689 statistical) |
| Monitoring interval | Recommended re-assessment period in months (UNE-EN 689 periodic) |
| Additive effects table | IE per agent, combined IE and group conformity decision |

<hr>

## Methodological notes

**COSHH Essentials:** any H or R phrase not listed explicitly in hazard groups B–E is assigned to group A by default, following the original method rule. This is consistent with the precautionary principle.

**INRS:** the volatility classification via the official graph uses the two boundary lines defined in the INRS ND 2233 guide (Figure 2). Vapour pressure thresholds follow Table 8 of the same guide (0.5 kPa / 25 kPa). These corrections were applied relative to an earlier version of the implementation, where the graph and the calculation were not fully consistent.

**UNE-EN 689:** the false-conformity bug present in some implementations of this standard — where `all(IE < 0.1, na.rm = TRUE)` returns `TRUE` on an empty vector, incorrectly declaring conformity without data — has been corrected. `une689_classify_conformity()` returns `NA` when no valid IE value is available.

`expoquimR` does not embed country-specific occupational exposure limits, as these vary by jurisdiction. The user must supply the applicable VLA/OEL when calling any UNE-EN 689 function.

<hr>

## Limitations

`expoquimR` implements the algorithmic steps of each method faithfully, but it does not replace professional judgement. The selection of the appropriate method, the design of the measurement strategy, the interpretation of results in the context of a specific workplace and the definition of corrective measures require the expertise of a qualified occupational hygienist or prevention specialist.

Qualitative control-banding methods (COSHH, INRS) are screening tools. A low risk level does not guarantee that exposure is below the OEL. A high risk level does not necessarily mean that exposure is dangerous; it means that further investigation or control is advisable.

The statistical assessment in UNE-EN 689 assumes that measurements are representative of the actual exposure distribution and that the sampling strategy was correctly designed. `expoquimR` does not validate measurement strategy design.

<hr>

## Citation

If you use `expoquimR` in your research, please cite:

```
Aguilar-Elena, R., Delgado-Garcia, A. & Guillem-Riquelme, A. (2025).
expoquimR: Qualitative and Quantitative Assessment of Occupational Chemical
Exposure Risk. R package version 0.1.0. Universidad Internacional de Valencia
(VIU) & Universidad de Salamanca (USAL).
https://github.com/Aguilar-Elena/expoquimR
```

<hr>

## Authors

**PhD. Raúl Aguilar Elena** &middot; raguilar@universidadviu.com  
Occupational Risk Prevention and Occupational Health Research Group  
Universidad Internacional de Valencia (VIU), Valencia, Spain

**Ana Delgado-Garcia** &middot; a.delgado@usal.es  
BISITE Research Group  
Universidad de Salamanca (USAL), Salamanca, Spain

**PhD. Alejandro Guillem-Riquelme** &middot; aguillem@universidadviu.com  
Occupational Risk Prevention and Occupational Health Research Group  
Universidad Internacional de Valencia (VIU), Valencia, Spain

<hr>

## License

MIT © 2025 Raúl Aguilar Elena & Ana Delgado-Garcia
