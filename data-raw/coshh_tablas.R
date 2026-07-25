## code to prepare the internal COSHH reference tables
## Run this script on your Mac (with the package loaded via
## devtools::load_all()) to regenerate R/sysdata.rda whenever the
## normative tables change.
##
##   source("data-raw/coshh_tablas.R")
##
## This creates/updates R/sysdata.rda with the internal objects used by
## the functions in R/coshh.R. Being internal (not exported), they are
## not visible via data(), but are accessible from within the package.

library(tibble)

# Hazard grade assignment table from R / H phrases (COSHH Essentials)
coshh_grade_table <- tibble::tribble(
  ~grade, ~r_phrases, ~h_phrases,
  "A", "R36, R38, R65, R67. Also any substance with no R phrase listed in groups B to E.",
       "H303, H304, H305, H313, H315, H316, H318, H319, H320, H333, H336. Also any substance with no H phrase listed in groups B to E.",
  "B", "R20/21/22, R68/20/21/22",
       "H302, H312, H332, H371",
  "C", "R23/24/25, R34, R35, R37, R37/38, R39/23/24/25, R41, R43, R48/20/21/22, R68/23/24/25",
       "H301, H311, H314, H317, H318, H331, H335, H370, H373",
  "D", "R26/27/28, R39/26/27/28, R40, R48/23/24/25, R48/23/25, R48/24, R60, R61, R62, R63, R64",
       "H300, H310, H330, H351, H360, H361, H362, H372",
  "E", "Mut. Cat. 3 R40*, R42, R45, R46, R49, R68*",
       "H334, H340, H341, H350"
)

# Table 5: Hazard x Quantity x Volatility matrix -> risk level (1-4)
coshh_risk_table <- tibble::tribble(
  ~hazard, ~quantity, ~volatility, ~risk,
  "A", "Small", "Low", 1, "A", "Small", "Medium", 1, "A", "Small", "High", 1,
  "A", "Medium", "Low", 1, "A", "Medium", "Medium", 1, "A", "Medium", "High", 2,
  "A", "Large",  "Medium", 2, "A", "Large", "High", 2,
  "B", "Small", "Low", 1, "B", "Small", "Medium", 1, "B", "Small", "High", 1,
  "B", "Medium", "Low", 1, "B", "Medium", "Medium", 2, "B", "Medium", "High", 2,
  "B", "Large",  "Low", 1, "B", "Large",  "Medium", 2, "B", "Large", "High", 3,
  "C", "Small", "Low", 1, "C", "Small", "Medium", 2, "C", "Small", "High", 2,
  "C", "Medium", "Low", 2, "C", "Medium", "Medium", 3, "C", "Medium", "High", 3,
  "C", "Large",  "Low", 2, "C", "Large",  "Medium", 4, "C", "Large", "High", 4,
  "D", "Small", "Low", 2, "D", "Small", "Medium", 3, "D", "Small", "High", 3,
  "D", "Medium", "Low", 3, "D", "Medium", "Medium", 4, "D", "Medium", "High", 4,
  "D", "Large",  "Low", 3, "D", "Large",  "Medium", 4, "D", "Large", "High", 4,
  "E", "Any", "Any", 4
)

# Recommended control measures by potential risk level (1-4)
coshh_measures_table <- tibble::tribble(
  ~risk_level, ~typical_conditions, ~control_measures,
  "1", "Hazard group A or B agents in small quantity and with low tendency to become airborne.",
       "General ventilation. Low risk.",
  "2", "Medium or high hazard with moderate quantity and/or volatility.",
       "Specific prevention and protection measures, e.g. local exhaust ventilation.",
  "3", "Situations with more hazardous agents or larger quantities.",
       "Containment or closed systems. Keep the process below atmospheric pressure where possible.",
  "4", "Highly toxic or carcinogenic substances, or medium-hazard agents in large quantities.",
       "Comply with legislation for CMR substances categories 1 and 2. Detailed exposure assessment required. Verify control effectiveness more frequently."
)

# NOTE: the usethis::use_data() call for these tables is made in
# data-raw/build_sysdata.R, together with the rest of the package's
# tables, so as not to overwrite R/sysdata.rda every time a new module
# is generated.
