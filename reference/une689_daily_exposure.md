# Daily exposure (ED) for a measurement day, per UNE-EN 689

Calculates the daily exposure from the concentrations and times of the
valid samples of a measurement day. If there is a single valid sample
taken over the complete 8-hour working day, the ED is directly that
concentration. Otherwise, it is calculated as the time-weighted average
over an 8-hour day (`sum(concentration * time) / 8`).

## Usage

``` r
une689_daily_exposure(concentration, time)
```

## Arguments

- concentration:

  Numeric vector. Measured concentrations (mg/m3), one per sample.

- time:

  Numeric vector. Time of each sample (hours), same length as
  `concentration`.

## Value

Numeric scalar with the ED, or `NA_real_` if there is no valid
(concentration, time) pair.

## Examples

``` r
une689_daily_exposure(concentration = c(12, 8), time = c(4, 4))
#> [1] 10
une689_daily_exposure(concentration = 9, time = 8)
#> [1] 9
```
