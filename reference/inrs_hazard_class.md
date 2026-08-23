# Hazard class of a substance (INRS method)

Determines the hazard class (1 to 5) of a substance from its R phrases,
its H phrases, its VLA, or the material/process it belongs to, by
consulting Table 1 of the INRS method. It is explored from the most
hazardous class (5) down to the least hazardous (1), and the first class
with a match is returned. If no phrase, VLA or process matches classes 2
to 5, class 1 is assigned by default (catch-all: "has phrases but none
of the above"), as established by the INRS methodology.

## Usage

``` r
inrs_hazard_class(
  r_phrases = character(0),
  h_phrases = character(0),
  process = NULL,
  vla = NA_real_
)
```

## Arguments

- r_phrases:

  Character vector of R phrases (optional).

- h_phrases:

  Character vector of H phrases (optional).

- process:

  Character scalar with the material/process (optional). Compared as a
  substring (case-insensitive) against the text of Table 1.

- vla:

  Numeric. VLA in mg/m3 (optional).

## Value

Character scalar (`"1"` to `"5"`). Only returns `NA_character_` if no
criterion at all was supplied (`r_phrases`, `h_phrases`, `process` and
`vla` all empty/`NA`), in which case there is not enough information to
classify.

## Examples

``` r
inrs_hazard_class(h_phrases = "H335")
#> [1] "2"
inrs_hazard_class(vla = 0.05)
#> [1] "5"
inrs_hazard_class(vla = 200) # falls into class 1 by default
#> [1] "1"
```
