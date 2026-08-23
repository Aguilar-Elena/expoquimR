# Classify the volatility of a liquid using the COSHH Essentials method

Compares the boiling point of a substance with its process temperature
to assign a volatility class (`"Low"` / `"Medium"` / `"High"` in
English, `"Baja"` / `"Media"` / `"Alta"` in Spanish), following the
thresholds of the COSHH Essentials method.

## Usage

``` r
coshh_classify_volatility(boiling_point, process_temp)
```

## Arguments

- boiling_point:

  Numeric. Boiling point of the substance, in degrees Celsius.

- process_temp:

  Numeric. Temperature at which the substance is handled, in degrees
  Celsius.

## Value

Character scalar: volatility class in the active language.

## Details

The active language is controlled by
[`expoquimr_lang()`](https://aguilar-elena.github.io/expoquimR/reference/expoquimr_lang.md).

## Examples

``` r
coshh_classify_volatility(boiling_point = 111, process_temp = 20)
#> [1] "Medium"
expoquimr_lang("es")
coshh_classify_volatility(boiling_point = 111, process_temp = 20)
#> [1] "Media"
expoquimr_lang("en")
```
