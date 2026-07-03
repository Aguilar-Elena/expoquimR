## Script maestro: genera R/sysdata.rda con TODAS las tablas internas del
## paquete de una sola vez. Cada vez que añadas un modulo nuevo (UNE-689,
## etc.), crea su propio data-raw/<modulo>_tablas.R SIN llamada a
## usethis::use_data(), y añade aqui un source() + los nombres de sus
## objetos en la lista final.
##
## Ejecutar en tu Mac:
##   devtools::load_all()
##   source("data-raw/build_sysdata.R")

source("data-raw/coshh_tablas.R")
source("data-raw/inrs_tablas.R")
# source("data-raw/une689_tablas.R")  # cuando exista

# Convertimos todas las tibbles a data.frame puro: las funciones del
# paquete solo usan indexado base ([ , $ , subset logico), y asi evitamos
# que el paquete dependa de 'tibble' en tiempo de ejecucion solo por la
# clase de estos objetos internos (tibble no esta ni en Imports ni en
# Suggests: solo se usa aqui, en data-raw, como azucar sintactico para
# escribir las tablas).
coshh_tabla_grados   <- as.data.frame(coshh_tabla_grados)
coshh_tabla_riesgo   <- as.data.frame(coshh_tabla_riesgo)
coshh_tabla_medidas  <- as.data.frame(coshh_tabla_medidas)

inrs_tabla_1                     <- as.data.frame(inrs_tabla_1)
inrs_tabla_frecuencia            <- as.data.frame(inrs_tabla_frecuencia)
inrs_tabla_exposicion_potencial  <- as.data.frame(inrs_tabla_exposicion_potencial)
inrs_tabla_riesgo_potencial      <- as.data.frame(inrs_tabla_riesgo_potencial)
inrs_tabla_puntuacion_riesgo     <- as.data.frame(inrs_tabla_puntuacion_riesgo)
inrs_tabla_procedimiento         <- as.data.frame(inrs_tabla_procedimiento)
inrs_tabla_proteccion            <- as.data.frame(inrs_tabla_proteccion)

usethis::use_data(
  # COSHH
  coshh_tabla_grados, coshh_tabla_riesgo, coshh_tabla_medidas,
  # INRS
  inrs_tabla_1, inrs_tabla_frecuencia, inrs_tabla_exposicion_potencial,
  inrs_tabla_riesgo_potencial, inrs_tabla_puntuacion_riesgo,
  inrs_tabla_procedimiento, inrs_tabla_proteccion,
  internal = TRUE, overwrite = TRUE
)
