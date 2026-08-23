# Get or set the language used by expoquimR

expoquimR supports English (`"en"`, default) and Spanish (`"es"`). The
active language controls the language of function output messages,
column labels returned by high-level wrapper functions, and
error/warning messages. It does **not** affect the Shiny apps, which
have their own in-app language selector.

## Usage

``` r
expoquimr_lang(lang = NULL)
```

## Arguments

- lang:

  Character. `"en"` (English, default) or `"es"` (Spanish). If `NULL`,
  returns the currently active language without changing it.

## Value

Invisibly returns the previously active language.

## Details

The active language is stored in a private package environment, not in
[`options()`](https://rdrr.io/r/base/options.html), so calling this
function never alters the user's global R session settings.

## Examples

``` r
expoquimr_lang()          # query current language
#> Current expoquimR language: en
old <- expoquimr_lang("es")  # switch to Spanish, saving the previous value
expoquimr_lang(old)          # restore it
```
