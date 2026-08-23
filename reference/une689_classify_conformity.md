# Classify the conformity of the UNE-EN 689 preliminary assessment

From the exposure indices (IE) of all the days evaluated, determines
whether exposure is conforming, non-conforming, or whether no decision
can be made without further measurements, following the criteria of the
UNE-EN 689 preliminary assessment.

## Usage

``` r
une689_classify_conformity(ie)
```

## Arguments

- ie:

  Numeric vector. Exposure indices, one per day (see
  [`une689_exposure_index()`](https://aguilar-elena.github.io/expoquimR/reference/une689_exposure_index.md)).
  `NA` values (days without enough data) are ignored.

## Value

Character scalar: `.t("une689_conformity")` if all IE values are below
0.1; `.t("une689_no_conformity")` if any IE is above 1;
`.t("une689_no_decision")` if any IE is between 0.1 and 1 (both
inclusive) and none exceeds 1. Returns `NA_character_` if there is no
valid IE at all (not enough data to classify).

## Correction relative to the original app

In the original Shiny app, if all days had IE = `NA` (due to missing
data), the check `all(IEs < 0.1, na.rm = TRUE)` returned `TRUE` (because
[`all()`](https://rdrr.io/r/base/all.html) over an empty vector is
`TRUE` in R), and the result was incorrectly reported as
**.t("une689_conformity")** with no actual data. This function fixes
that case by returning `NA_character_` (not enough data) instead of a
false conformity. This change is flagged here because, unlike the INRS
points, it was applied without prior confirmation: reporting
"conformity" with no data is a safety flaw, not a methodological
judgement call.

## Examples

``` r
une689_classify_conformity(c(0.02))
#> [1] "CONFORMITY"
une689_classify_conformity(c(1, 0.9, 0.56))
#> [1] "NO DECISION"
une689_classify_conformity(c(1.2, 0.05))
#> [1] "NON-CONFORMITY"
```
