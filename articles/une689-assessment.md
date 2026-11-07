# UNE-EN 689: Quantitative Statistical Exposure Assessment

## Overview

UNE-EN 689 is a European standard that defines a two-stage statistical
procedure for comparing measured occupational exposure levels against
occupational exposure limits (OELs). It is designed to provide a
statistically rigorous and reproducible conformity decision based on a
representative set of exposure measurements collected over multiple
working days.

The standard assumes that daily exposure (ED) values follow a
**lognormal or normal distribution** and uses a **one-sided upper
tolerance limit** (LSC\_{95,70}) to decide, with 95% confidence and 70%
coverage, whether exposure is below the OEL.

## The two-stage procedure

### Stage 1: Preliminary assessment (minimum 3 measurement days)

Each measurement day produces one or more samples. The daily exposure ED
is calculated as the time-weighted average over an 8-hour shift. The
exposure index IE = ED / OEL is then computed for each day.

Decision rules:

| Condition | Outcome |
|----|----|
| All IE \< 0.1 | **CONFORMITY** — exposure is well below the OEL |
| Any IE \> 1 | **NON-CONFORMITY** — at least one day exceeds the OEL |
| Any IE between 0.1 and 1 | **NO DECISION** — proceed to Stage 2 |

### Stage 2: Statistical assessment (minimum 6 measurement days total)

The full set of ED values (preliminary + additional days) is fitted to a
lognormal or normal distribution using the Shapiro-Wilk test. The
one-sided upper tolerance limit LSC\_{95,70} is then compared against
the OEL via the risk index UR. If UR ≥ UT (tabulated tolerance factor),
conformity is declared.

## Stage 1 example

``` r

# Five samples across three working days
data <- data.frame(
  day           = c(1, 1, 2, 3, 3),
  concentration = c(12, 8, 9, 5, 6),   # mg/m³
  time          = c(4,  4, 8, 3, 5)    # hours
)

res_pre <- une689_evaluate_preliminary(data, vla = 10)
res_pre$days_table
#>   day     ED     IE
#> 1   1 10.000 1.0000
#> 2   2  9.000 0.9000
#> 3   3  5.625 0.5625
res_pre$result
#> [1] "NO DECISION"
```

### Step-by-step

``` r

# Daily exposure for day 1 (two samples)
une689_daily_exposure(concentration = c(12, 8), time = c(4, 4))
#> [1] 10

# Exposure index
une689_exposure_index(ed = 10, vla = 10)
#> [1] 1

# Classify conformity from a set of IE values
une689_classify_conformity(c(1.0, 0.9, 0.5625))
#> [1] "NO DECISION"
```

## Stage 2 example

When the preliminary assessment returns NO DECISION, additional
measurement days are collected and the full statistical assessment is
performed on the combined dataset.

``` r

# Six ED values (3 preliminary + 3 additional)
eds <- c(10, 9, 5.625, 11, 8, 13)

res_est <- une689_evaluate_statistical(eds, vla = 10)

cat("Distribution:", res_est$distribution_type, "\n")
#> Distribution: Lognormal
cat("MG =",  round(res_est$MG,  3), "\n")
#> MG = 9.13
cat("DSG =", round(res_est$DSG, 3), "\n")
#> DSG = 1.336
cat("UT =",  res_est$ut, "\n")
#> UT = 2.187
cat("LSC(95,70) =", round(res_est$lsc, 3), "\n")
#> LSC(95,70) = 17.21
cat("UR =",  round(res_est$ur, 3), "\n")
#> UR = 0.314
cat("Result:", res_est$conformity, "\n")
#> Result: NON-CONFORMITY
```

### Step-by-step

``` r

# Descriptive statistics
est <- une689_statistics(eds)
est$MG; est$DSG
#> [1] 9.129882
#> [1] 1.33626

# Normality and lognormality tests
test <- une689_normality_test(eds)
test$pval_lognormal
#> [1] 0.8702792

# Distribution type (lognormal has priority)
distribution_type <- une689_distribution_type(
  pval_normal    = test$pval_normal,
  pval_lognormal = test$pval_lognormal
)
distribution_type
#> [1] "Lognormal"

# Tolerance factor UT for n = 6
une689_ut(6)
#> [1] 2.187

# LSC(95,70)
une689_lsc(distribution_type, ut = une689_ut(6), MG = est$MG, DSG = est$DSG)
#> [1] 17.2103

# Risk index UR
une689_ur(distribution_type, vla = 10, MG = est$MG, DSG = est$DSG)
#> [1] 0.3140406

# Conformity decision
une689_statistical_conformity(ur = une689_ur(distribution_type, vla = 10,
                                               MG = est$MG, DSG = est$DSG),
                                ut = une689_ut(6))
#> [1] "NON-CONFORMITY"
```

### Graphical validation of the similar exposure group

Besides the Shapiro-Wilk tests, the similar exposure group (SEG) can be
validated graphically on probability paper. The ED values are ranked in
ascending order and each rank `k` receives the plotting position
`P_k = (k - 3/8) / (n + 1/4)`. The points are then plotted against `P_k`
on log-normal paper (logarithmic horizontal axis) when the data are
lognormal, or on normal paper (linear horizontal axis) when the data are
normal. If all points lie close to a straight line and none is
exceptionally separated from the rest, the SEG is consistent with the
assumed distribution.

``` r

pd <- une689_probability_data(eds)

pd$distribution
#> [1] "lognormal"
pd$data[, c("k", "ed", "pk")]
#>   k     ed   pk
#> 1 1  5.625 0.10
#> 2 2  8.000 0.26
#> 3 3  9.000 0.42
#> 4 4 10.000 0.58
#> 5 5 11.000 0.74
#> 6 6 13.000 0.90
```

``` r

une689_probability_plot(eds, vla = 10)
```

![Log-normal probability paper with the six daily exposure values and a
fitted straight
line.](une689-assessment_files/figure-html/probability_plot-1.png)

The coefficient of determination of the line (`pd$r_squared`) is shown
in the plot subtitle as a descriptive aid only: the check is visual, and
the package applies no numerical cut-off to it. With
`distribution = "auto"` (the default) the paper is chosen from the
Shapiro-Wilk results; use `"lognormal"` or `"normal"` to force one.

## Periodic assessment (monitoring interval)

Once conformity has been established, the standard requires defining how
frequently measurements should be repeated. Two options are available:

``` r

# Option 1: MG or MA versus the OEL
une689_monitoring_interval_opt1(reference_value = res_est$MG, vla = 10)
#> [1] "Recommended monitoring interval: 12 months"

# Option 2: LSC(95,70) versus the OEL
une689_monitoring_interval_opt2(lsc = res_est$lsc, vla = 10)
#> [1] "Not recommended. Exposure must be reviewed."
```

## Additive effects

When workers are simultaneously exposed to multiple agents affecting the
same target organ, the European standard requires that the **combined
exposure index** be evaluated:

    IE_combined = IE_agent1 + IE_agent2 + ... + IE_agentN

Conformity requires IE_combined ≤ 1. For example, if toluene (IE = 0.20)
and xylene (IE = 0.30) both affect the central nervous system:

``` r

ie_toluene <- 0.20
ie_xylene  <- 0.30
ie_combined <- ie_toluene + ie_xylene

cat("Combined IE:", ie_combined, "\n")
#> Combined IE: 0.5
une689_classify_conformity(ie_combined)
#> [1] "NO DECISION"
```

Agents can appear in more than one additive group if they affect
multiple target organs. The
[`une689_from_excel()`](https://aguilar-elena.github.io/expoquimR/reference/une689_from_excel.md)
function and the Shiny application handle multiple independent additive
groups automatically.

## From Excel (no coding required)

The UNE-EN 689 Excel template has three sheets:

- **Agents**: agent name and VLA, one row per agent.
- **Measurements**: one row per sample, with a `type` field (`pre` for
  preliminary days, `add` for additional days).
- **Additive_effects** (optional): groups of agents sharing a target
  organ.

``` r

ruta <- system.file("plantillas", "plantilla_une689.xlsx", package = "expoquimR")
res <- une689_from_excel(ruta)

# Preliminary results and statistical assessment per agent
res$preliminary$Toluene$result
res$preliminary$Toluene$statistics$conformity

# Additive effects table
res$additive
```

## Language

``` r

expoquimr_lang("es")
une689_classify_conformity(c(0.02, 0.05))
#> [1] "CONFORMIDAD"
une689_distribution_type(0.5, 0.5)
#> [1] "Lognormal"
une689_monitoring_interval_opt1(0.5, vla = 10)
#> [1] "Periodicidad recomendada: 36 meses"
expoquimr_lang("en")
```

## Interactive application

``` r

run_une689()
```

The UNE-EN 689 Shiny application supports:

- Multiple chemical agents, each with its own tab and independent
  measurement days.
- Sequential workflow: preliminary assessment → automatic unlock of
  additional days on NO DECISION → statistical assessment → periodic
  assessment.
- Independent additive effect groups: users define which agents share a
  target organ, and agents can appear in more than one group.

## Methodological note

A known implementation error in some versions of this standard involves
the use of `all(IE < 0.1, na.rm = TRUE)` to test conformity. In R,
[`all()`](https://rdrr.io/r/base/all.html) on an empty vector returns
`TRUE`, which would incorrectly declare conformity when no valid IE
values are available. `expoquimR` corrects this by returning `NA` from
[`une689_classify_conformity()`](https://aguilar-elena.github.io/expoquimR/reference/une689_classify_conformity.md)
when the input contains no valid IE values.

## References

- AENOR. *UNE-EN 689:2019. Workplace exposure — Measurement of exposure
  by inhalation to chemical agents — Strategy for testing compliance
  with occupational exposure limit values.* Madrid: AENOR.
- European Committee for Standardisation (CEN). *EN 689:2018.*
