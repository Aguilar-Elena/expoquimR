## Master script: generates R/sysdata.rda with ALL the package's internal
## tables at once. Whenever you add a new module (UNE-689, etc.), create
## its own data-raw/<module>_tablas.R WITHOUT a usethis::use_data() call,
## and add here a source() plus its object names to the final list.
##
## Run on your Mac:
##   devtools::load_all()
##   source("data-raw/build_sysdata.R")

source("data-raw/coshh_tablas.R")
source("data-raw/inrs_tablas.R")
# source("data-raw/une689_tablas.R")  # once it exists

# Convert all tibbles to plain data.frame: the package's functions only
# use base indexing ([ , $ , logical subset), so this avoids the package
# depending on 'tibble' at runtime just for the class of these internal
# objects (tibble is neither in Imports nor Suggests: it is only used
# here, in data-raw, as syntactic sugar to write the tables).
coshh_grade_table    <- as.data.frame(coshh_grade_table)
coshh_risk_table     <- as.data.frame(coshh_risk_table)
coshh_measures_table <- as.data.frame(coshh_measures_table)

inrs_hazard_table              <- as.data.frame(inrs_hazard_table)
inrs_frequency_table           <- as.data.frame(inrs_frequency_table)
inrs_potential_exposure_table  <- as.data.frame(inrs_potential_exposure_table)
inrs_potential_risk_table      <- as.data.frame(inrs_potential_risk_table)
inrs_risk_score_table          <- as.data.frame(inrs_risk_score_table)
inrs_process_table             <- as.data.frame(inrs_process_table)
inrs_protection_table          <- as.data.frame(inrs_protection_table)

usethis::use_data(
  # COSHH
  coshh_grade_table, coshh_risk_table, coshh_measures_table,
  # INRS
  inrs_hazard_table, inrs_frequency_table, inrs_potential_exposure_table,
  inrs_potential_risk_table, inrs_risk_score_table,
  inrs_process_table, inrs_protection_table,
  internal = TRUE, overwrite = TRUE
)
