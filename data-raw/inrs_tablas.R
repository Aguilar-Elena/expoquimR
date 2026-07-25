## code to prepare the internal INRS reference tables
## Run after data-raw/coshh_tablas.R, on your Mac:
##   source("data-raw/inrs_tablas.R")
## This appends new objects to R/sysdata.rda (usethis::use_data() adds
## without overwriting the existing COSHH ones, but run
## devtools::load_all() first anyway so 'usethis' knows which package is
## active).

library(tibble)

# Table 1: hazard class from R/H phrases, VLA, or material and process
inrs_hazard_table <- tibble::tribble(
  ~hazard_class, ~r_phrases, ~h_phrases, ~vla_text, ~process_materials,

  "1",
  "Has R phrases, but none of the ones listed below",
  "Has H phrases, but none of the ones listed below",
  "> 100",
  "No process defined",

  "2",
  "R37, R36/37, R37/38, R36/37/38, R67",
  "H335, H336",
  "> 10 and <= 100",
  "Iron, cereals and derivatives, graphite, construction material, talc, cement, composites, treated wood, metal-plastic welding, plant/animal material",

  "3",
  "R20, R20/21, R20/22, R20/21/22, R33, R48/20, R48/20/21, R48/20/22, R48/20/21/22, R62, R63, R64, R65, R68/20, R68/20/21, R68/20/22, R68/20/21/22",
  "H304, H332, H361, H361d, H361f, H361fd, H362, H371, H373, EUH071",
  "> 1 and <= 10",
  "Stainless steel welding, ceramic/plant fibres, lead paints, grinding wheels, sands, cutting/cooling oils",

  "4",
  "R15/29, R23, R23/24, R23/25, R23/24/25, R29, R31, R39/23, R39/23/24, R39/23/25, R39/23/24/25, R40, R42, R42/43, R48/23, R48/23/24, R48/23/25, R48/23/24/25, R60, R61, R68",
  "H331, H334, H341, H351, H360, H360F, H360FD, H360D, H360Df, H360Fd, H370, H372, EUH029, EUH031",
  "> 0.1 and <= 1",
  "Softwoods and derivatives, metallic lead, lead smelting and refining",

  "5",
  "R26, R26/27, R26/28, R26/27/28, R32, R39, R39/26, R39/26/27, R39/26/28, R39/26/27/28, R45, R46, R49",
  "H330, H340, H350, H350i, EUH032, EUH070",
  "<= 0.1",
  "Asbestos, bitumens and tars, petrol, vulcanisation, hardwoods and derivatives"
)

# Table 3: frequency of use class from converted period/unit
inrs_frequency_table <- tibble::tribble(
  ~period, ~from, ~to,  ~unit,  ~class,
  "Day",     0,     0.5,    "hours", "1",
  "Day",     0.5,   2,      "hours", "2",
  "Day",     2,     6,      "hours", "3",
  "Day",     6,     Inf,    "hours", "4",

  "Week",    0,     2,      "hours", "1",
  "Week",    2,     8,      "hours", "2",
  "Week",   24,    72,      "hours", "3",
  "Week",   72,    Inf,     "hours", "4",

  "Month",   1,     1,      "days",  "1",
  "Month",   2,     6,      "days",  "2",
  "Month",   7,     15,     "days",  "3",
  "Month",  16,    Inf,     "days",  "4",

  "Year",    0,     15,     "days",  "1",
  "Year",   16,     60,     "days",  "2",
  "Year",   61,    150,     "days",  "3",
  "Year",  151,    Inf,     "days",  "4"
)

# Table 4: quantity class x frequency class -> potential exposure class
# (flattened to long format from the original matrix)
inrs_potential_exposure_table <- tibble::tribble(
  ~quantity_class, ~frequency_class, ~exposure_class,
  "5", "0", "0", "5", "1", "4", "5", "2", "5", "5", "3", "5", "5", "4", "5",
  "4", "0", "0", "4", "1", "3", "4", "2", "4", "4", "3", "4", "4", "4", "5",
  "3", "0", "0", "3", "1", "3", "3", "2", "3", "3", "3", "3", "3", "4", "4",
  "2", "0", "0", "2", "1", "2", "2", "2", "2", "2", "3", "2", "2", "4", "2",
  "1", "0", "0", "1", "1", "1", "1", "2", "1", "1", "3", "1", "1", "4", "1"
)

# Table 5: potential exposure class x hazard class -> potential risk class
inrs_potential_risk_table <- tibble::tribble(
  ~exposure_class, ~hazard_class, ~risk_class,
  "5", "1", "2", "5", "2", "3", "5", "3", "4", "5", "4", "5", "5", "5", "5",
  "4", "1", "1", "4", "2", "2", "4", "3", "3", "4", "4", "4", "4", "5", "5",
  "3", "1", "1", "3", "2", "2", "3", "3", "3", "3", "4", "4", "3", "5", "5",
  "2", "1", "1", "2", "2", "1", "2", "3", "2", "2", "4", "3", "2", "5", "4",
  "1", "1", "1", "1", "2", "1", "1", "3", "2", "1", "4", "3", "1", "5", "4"
)

# Table 6: score associated with each potential risk class
inrs_risk_score_table <- tibble::tribble(
  ~risk_class, ~score,
  "5", 10000,
  "4", 1000,
  "3", 100,
  "2", 10,
  "1", 1
)

# Process class table (INRS Figure 3)
inrs_process_table <- tibble::tribble(
  ~type,                          ~class, ~score,
  "Dispersive",                   "4",    1,
  "Open",                         "3",    0.5,
  "Closed/opened regularly",      "2",    0.05,
  "Permanently closed",           "1",    0.001
)

# Collective protection table (INRS Figure 4)
inrs_protection_table <- tibble::tribble(
  ~situation,                                 ~class, ~score,
  "Confined space without ventilation",       "5",    10,
  "No mechanical ventilation",                "4",    1,
  "Moderate dispersion conditions",           "3",    0.7,
  "Local exhaust or ventilated enclosures",   "2",    0.1,
  "Enclosing hood / full enclosure",          "1",    0.001
)

# NOTE: the usethis::use_data() call for these tables is made in
# data-raw/build_sysdata.R, together with the rest of the package's
# tables, so as not to overwrite R/sysdata.rda every time a new module
# is generated.
