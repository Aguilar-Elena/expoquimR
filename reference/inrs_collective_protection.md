# Collective protection class and score (INRS method)

Collective protection class and score (INRS method)

## Usage

``` r
inrs_collective_protection(situation)
```

## Arguments

- situation:

  Character. One of the situations of INRS Figure 4, e.g.
  `"Enclosing hood / full enclosure"`.

## Value

A one-row `data.frame` with columns `class` and `score`.

## Examples

``` r
inrs_collective_protection("Enclosing hood / full enclosure")
#>   class score
#> 5     1 0.001
```
