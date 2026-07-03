## code to prepare the internal INRS reference tables
## Ejecutar en tu Mac tras data-raw/coshh_tablas.R:
##   source("data-raw/inrs_tablas.R")
## Esto añade objetos nuevos a R/sysdata.rda (usethis::use_data añade sin
## machacar los ya existentes de COSHH, pero corre igualmente primero
## devtools::load_all() para que 'usethis' sepa cual es el paquete activo).

library(tibble)

# Tabla 1: clase de peligro segun frases R/H, VLA o material y proceso
inrs_tabla_1 <- tibble::tribble(
  ~clase_peligro, ~frases_r, ~frases_h, ~vla_texto, ~materiales_procesos,

  "1",
  "Tiene frases R, pero no tiene ninguna de las que aparecen a continuacion",
  "Tiene frases H, pero no tiene ninguna de las que aparecen a continuacion",
  "> 100",
  "No hay proceso definido",

  "2",
  "R37, R36/37, R37/38, R36/37/38, R67",
  "H335, H336",
  "> 10 y <= 100",
  "Hierro, cereal y derivados, grafito, material de construccion, talco, cemento, composites, madera tratada, soldadura metales-plasticos, material vegetal-animal",

  "3",
  "R20, R20/21, R20/22, R20/21/22, R33, R48/20, R48/20/21, R48/20/22, R48/20/21/22, R62, R63, R64, R65, R68/20, R68/20/21, R68/20/22, R68/20/21/22",
  "H304, H332, H361, H361d, H361f, H361fd, H362, H371, H373, EUH071",
  "> 1 y <= 10",
  "Soldadura inoxidable, fibras ceramicas-vegetales, pinturas de plomo, muelas, arenas, aceites de corte/refrigerantes",

  "4",
  "R15/29, R23, R23/24, R23/25, R23/24/25, R29, R31, R39/23, R39/23/24, R39/23/25, R39/23/24/25, R40, R42, R42/43, R48/23, R48/23/24, R48/23/25, R48/23/24/25, R60, R61, R68",
  "H331, H334, H341, H351, H360, H360F, H360FD, H360D, H360Df, H360Fd, H370, H372, EUH029, EUH031",
  "> 0,1 y <= 1",
  "Maderas blandas y derivados, plomo metalico, fundicion y afinaje de plomo",

  "5",
  "R26, R26/27, R26/28, R26/27/28, R32, R39, R39/26, R39/26/27, R39/26/28, R39/26/27/28, R45, R46, R49",
  "H330, H340, H350, H350i, EUH032, EUH070",
  "<= 0,1",
  "Amianto, betunes y breas, gasolina, vulcanizacion, maderas duras y derivados"
)

# Tabla 3: clase de frecuencia de uso segun periodo/unidad convertidos
inrs_tabla_frecuencia <- tibble::tribble(
  ~periodo, ~desde, ~hasta, ~unidad, ~clase,
  "Dia",     0,     0.5,    "horas", "1",
  "Dia",     0.5,   2,      "horas", "2",
  "Dia",     2,     6,      "horas", "3",
  "Dia",     6,     Inf,    "horas", "4",

  "Semana",  0,     2,      "horas", "1",
  "Semana",  2,     8,      "horas", "2",
  "Semana", 24,    72,      "horas", "3",
  "Semana", 72,    Inf,     "horas", "4",

  "Mes",     1,     1,      "dias",  "1",
  "Mes",     2,     6,      "dias",  "2",
  "Mes",     7,     15,     "dias",  "3",
  "Mes",     16,    Inf,    "dias",  "4",

  "Anio",    0,     15,     "dias",  "1",
  "Anio",    16,    60,     "dias",  "2",
  "Anio",    61,   150,     "dias",  "3",
  "Anio",   151,    Inf,    "dias",  "4"
)

# Tabla 4: clase de cantidad x clase de frecuencia -> clase de exposicion potencial
# (aplanada a formato largo a partir de la matriz original)
inrs_tabla_exposicion_potencial <- tibble::tribble(
  ~clase_cantidad, ~clase_frecuencia, ~clase_exposicion,
  "5", "0", "0", "5", "1", "4", "5", "2", "5", "5", "3", "5", "5", "4", "5",
  "4", "0", "0", "4", "1", "3", "4", "2", "4", "4", "3", "4", "4", "4", "5",
  "3", "0", "0", "3", "1", "3", "3", "2", "3", "3", "3", "3", "3", "4", "4",
  "2", "0", "0", "2", "1", "2", "2", "2", "2", "2", "3", "2", "2", "4", "2",
  "1", "0", "0", "1", "1", "1", "1", "2", "1", "1", "3", "1", "1", "4", "1"
)

# Tabla 5: clase de exposicion potencial x clase de peligro -> clase de riesgo potencial
inrs_tabla_riesgo_potencial <- tibble::tribble(
  ~clase_exposicion, ~clase_peligro, ~clase_riesgo,
  "5", "1", "2", "5", "2", "3", "5", "3", "4", "5", "4", "5", "5", "5", "5",
  "4", "1", "1", "4", "2", "2", "4", "3", "3", "4", "4", "4", "4", "5", "5",
  "3", "1", "1", "3", "2", "2", "3", "3", "3", "3", "4", "4", "3", "5", "5",
  "2", "1", "1", "2", "2", "1", "2", "3", "2", "2", "4", "3", "2", "5", "4",
  "1", "1", "1", "1", "2", "1", "1", "3", "2", "1", "4", "3", "1", "5", "4"
)

# Tabla 6: puntuacion asociada a cada clase de riesgo potencial
inrs_tabla_puntuacion_riesgo <- tibble::tribble(
  ~clase_riesgo, ~puntuacion,
  "5", 10000,
  "4", 1000,
  "3", 100,
  "2", 10,
  "1", 1
)

# Tabla de clases de procedimiento (Figura 3 INRS)
inrs_tabla_procedimiento <- tibble::tribble(
  ~tipo,                             ~clase, ~puntuacion,
  "Dispersivo",                      "4",    1,
  "Abierto",                         "3",    0.5,
  "Cerrado/abierto regularmente",    "2",    0.05,
  "Cerrado permanente",              "1",    0.001
)

# Tabla de proteccion colectiva (Figura 4 INRS)
inrs_tabla_proteccion <- tibble::tribble(
  ~situacion,                              ~clase, ~puntuacion,
  "Espacio confinado sin ventilacion",     "5",    10,
  "Sin ventilacion mecanica",              "4",    1,
  "Condiciones moderadas de dispersion",   "3",    0.7,
  "Captacion localizada o cabinas ventiladas", "2", 0.1,
  "Captacion envolvente",                  "1",    0.001
)

# NOTA: la llamada a usethis::use_data() para estas tablas se hace en
# data-raw/build_sysdata.R, junto con el resto de tablas del paquete, para
# no sobrescribir R/sysdata.rda cada vez que se genera un modulo nuevo.
