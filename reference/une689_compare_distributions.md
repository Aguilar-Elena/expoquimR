# Diagnostic comparison of normal and lognormal UNE-EN 689 models

Returns both model calculations without selecting a normative
distribution. The existing statistical assessment and its outputs are
unchanged.

## Usage

``` r
une689_compare_distributions(ed, vla, alpha = 0.05)
```

## Arguments

- ed:

  Numeric vector of at least six positive, finite daily exposures.

- vla:

  Positive, finite occupational exposure limit.

- alpha:

  Shapiro-Wilk significance threshold, strictly between 0 and 1.

## Value

A list containing models, discordant, and requires_review.
