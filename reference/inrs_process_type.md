# Process class and score (INRS method)

Process class and score (INRS method)

## Usage

``` r
inrs_process_type(type)
```

## Arguments

- type:

  Character. One of `"Dispersive"`, `"Open"`,
  `"Closed/opened regularly"`, `"Permanently closed"`.

## Value

A one-row `data.frame` with columns `class` and `score`.

## Examples

``` r
inrs_process_type("Open")
#>   class score
#> 2     3   0.5
```
