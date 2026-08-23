# Final inhalation risk score (INRS method)

Product of the five partial scores of the INRS method.

## Usage

``` r
inrs_inhalation_risk(
  potential_risk_score,
  volatility_score,
  procedure_score,
  protection_score,
  vla_correction_factor
)
```

## Arguments

- potential_risk_score:

  Numeric. See
  [`inrs_potential_risk_score()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_potential_risk_score.md).

- volatility_score:

  Numeric. See
  [`inrs_volatility_score()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_volatility_score.md).

- procedure_score:

  Numeric. See
  [`inrs_process_type()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_process_type.md).

- protection_score:

  Numeric. See
  [`inrs_collective_protection()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_collective_protection.md).

- vla_correction_factor:

  Numeric. See
  [`inrs_oel_correction_factor()`](https://aguilar-elena.github.io/expoquimR/reference/inrs_oel_correction_factor.md).

## Value

Numeric, or `NA_real_` if any component is missing.

## Examples

``` r
inrs_inhalation_risk(100, 10, 0.5, 0.7, 10)
#> [1] 3500
```
