# Probability-paper data for examining a similar exposure group (UNE-EN 689)

Computes the quantities needed to draw the graphical validation of a
similar exposure group (SEG, "GES" in Spanish) on probability paper: the
daily exposure values are ranked in ascending order and each rank `k` is
assigned the plotting position \\P_k = (k - 3/8) / (n + 1/4)\\. If the
data follow the assumed distribution, the points fall approximately on a
straight line when plotted against \\P_k\\ on log-normal paper
(lognormal data) or on normal paper (normal data).

## Usage

``` r
une689_probability_data(
  ed,
  distribution = c("auto", "lognormal", "normal"),
  alpha = 0.05
)
```

## Arguments

- ed:

  Numeric vector. Daily exposure (ED) values, all strictly positive;
  between 3 and 5000 values.

- distribution:

  Character. `"lognormal"`, `"normal"`, or `"auto"` (default). With
  `"auto"` the lognormal distribution is used if the Shapiro-Wilk test
  on `log(ED)` does not reject it at level `alpha`; otherwise the normal
  distribution is used if the test on `ED` does not reject it; if both
  are rejected, an error is raised. The labels returned by
  [`une689_distribution_type()`](https://aguilar-elena.github.io/expoquimR/reference/une689_distribution_type.md)
  (English or Spanish) are also accepted.

- alpha:

  Numeric. Significance level of the Shapiro-Wilk tests used by
  `distribution = "auto"` (default 0.05).

## Value

A list with elements:

- `data`:

  A `data.frame` with one row per observation and columns `k` (rank),
  `ed` (sorted values), `pk` (plotting position), `pk_percent`
  (`100 * pk`), `z` (standard normal quantile of `pk`), `y` (`log(ed)`
  for lognormal, `ed` for normal), `fitted` and `residual` of the
  straight-line fit.

- `distribution`:

  `"lognormal"` or `"normal"`.

- `n`:

  Number of observations.

- `intercept`, `slope`:

  Coefficients of the straight line `y = intercept + slope * z`.

- `r_squared`:

  Coefficient of determination of the fit.

- `W`, `p_value`:

  Shapiro-Wilk statistic and p-value for the chosen distribution (on
  `log(ed)` for lognormal, on `ed` for normal).

- `alpha`:

  The significance level used.

## Details

The vertical coordinate used for the fit is the standard normal quantile
\\z_k = \Phi^{-1}(P_k)\\, which is what the probability scale of the
paper represents. The straight line is the least-squares regression of
`log(ED)` (lognormal) or `ED` (normal) on \\z_k\\. For lognormal data
the intercept and slope estimate `log(MG)` and `log(DSG)`, and for
normal data they estimate `MA` and `DS`; these are regression-based
graphical estimates and do not replace
[`une689_statistics()`](https://aguilar-elena.github.io/expoquimR/reference/une689_statistics.md).

The coefficient of determination returned in `r_squared` is purely
descriptive. The graphical check is a visual one: the group is
considered consistent when all points lie close to a straight line and
none is exceptionally separated from the rest. This function does not
apply any numerical cut-off to that judgement.

Note that [`stats::ppoints()`](https://rdrr.io/r/stats/ppoints.html)
uses the same plotting positions only for `n <= 10`; this function
always uses \\(k - 3/8)/(n + 1/4)\\.

## See also

[`une689_probability_plot()`](https://aguilar-elena.github.io/expoquimR/reference/une689_probability_plot.md),
[`une689_normality_test()`](https://aguilar-elena.github.io/expoquimR/reference/une689_normality_test.md),
[`une689_distribution_type()`](https://aguilar-elena.github.io/expoquimR/reference/une689_distribution_type.md)

## Examples

``` r
ed <- c(0.008, 0.012, 0.017, 0.021, 0.034, 0.041)
pd <- une689_probability_data(ed)
pd$distribution
#> [1] "lognormal"
pd$data[, c("k", "ed", "pk")]
#>   k    ed   pk
#> 1 1 0.008 0.10
#> 2 2 0.012 0.26
#> 3 3 0.017 0.42
#> 4 4 0.021 0.58
#> 5 5 0.034 0.74
#> 6 6 0.041 0.90
pd$r_squared
#> [1] 0.9825294
```
