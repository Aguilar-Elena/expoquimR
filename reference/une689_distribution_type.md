# Determine the distribution type (UNE-EN 689)

Decides whether the data best fits a lognormal, normal, or neither
distribution, from the Shapiro-Wilk p-values. Priority is given to the
lognormal fit, following common practice in industrial hygiene (exposure
is usually lognormal).

## Usage

``` r
une689_distribution_type(pval_normal, pval_lognormal, alpha = 0.05)
```

## Arguments

- pval_normal:

  Numeric. p-value of the normality test on ED.

- pval_lognormal:

  Numeric. p-value of the normality test on log(ED).

- alpha:

  Numeric. Significance level (default 0.05).

## Value

Character scalar: one of `"Lognormal"`, `"Normal"` or `"Neither"` (in
English, the default), or the equivalent Spanish labels when
`expoquimr_lang("es")` is active.

## Examples

``` r
une689_distribution_type(pval_normal = 0.03, pval_lognormal = 0.20)
#> [1] "Lognormal"
```
