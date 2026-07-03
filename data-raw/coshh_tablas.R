## code to prepare the internal COSHH reference tables
## Ejecutar este script en tu Mac (con el paquete cargado con devtools::load_all())
## para regenerar R/sysdata.rda cada vez que cambien las tablas normativas.
##
##   source("data-raw/coshh_tablas.R")
##
## Esto crea/actualiza R/sysdata.rda con los objetos internos que usan las
## funciones de R/coshh.R. Al ser internos (no exportados), no aparecen con
## data(), pero son accesibles desde dentro del paquete.

library(tibble)

# Tabla de asignacion de grado de peligrosidad segun frases R / H (COSHH Essentials)
coshh_tabla_grados <- tibble::tribble(
  ~grado, ~frases_r, ~frases_h,
  "A", "R36, R38, R65, R67. Tambien cualquier sustancia sin frases R contenidas en los grupos B a E.",
       "H303, H304, H305, H313, H315, H316, H318, H319, H320, H333, H336. Tambien cualquier sustancia sin frases H contenidas en los grupos B a E.",
  "B", "R20/21/22, R68/20/21/22",
       "H302, H312, H332, H371",
  "C", "R23/24/25, R34, R35, R37, R37/38, R39/23/24/25, R41, R43, R48/20/21/22, R68/23/24/25",
       "H301, H311, H314, H317, H318, H331, H335, H370, H373",
  "D", "R26/27/28, R39/26/27/28, R40, R48/23/24/25, R48/23/25, R48/24, R60, R61, R62, R63, R64",
       "H300, H310, H330, H351, H360, H361, H362, H372",
  "E", "Mut. Cat. 3 R40*, R42, R45, R46, R49, R68*",
       "H334, H340, H341, H350"
)

# Tabla 5: matriz Peligrosidad x Cantidad x Volatilidad -> nivel de riesgo (1-4)
coshh_tabla_riesgo <- tibble::tribble(
  ~peligrosidad, ~cantidad, ~volatilidad, ~riesgo,
  "A", "Pequeña", "Baja", 1, "A", "Pequeña", "Media", 1, "A", "Pequeña", "Alta", 1,
  "A", "Mediana", "Baja", 1, "A", "Mediana", "Media", 1, "A", "Mediana", "Alta", 2,
  "A", "Grande",  "Media", 2, "A", "Grande", "Alta", 2,
  "B", "Pequeña", "Baja", 1, "B", "Pequeña", "Media", 1, "B", "Pequeña", "Alta", 1,
  "B", "Mediana", "Baja", 1, "B", "Mediana", "Media", 2, "B", "Mediana", "Alta", 2,
  "B", "Grande",  "Baja", 1, "B", "Grande",  "Media", 2, "B", "Grande", "Alta", 3,
  "C", "Pequeña", "Baja", 1, "C", "Pequeña", "Media", 2, "C", "Pequeña", "Alta", 2,
  "C", "Mediana", "Baja", 2, "C", "Mediana", "Media", 3, "C", "Mediana", "Alta", 3,
  "C", "Grande",  "Baja", 2, "C", "Grande",  "Media", 4, "C", "Grande", "Alta", 4,
  "D", "Pequeña", "Baja", 2, "D", "Pequeña", "Media", 3, "D", "Pequeña", "Alta", 3,
  "D", "Mediana", "Baja", 3, "D", "Mediana", "Media", 4, "D", "Mediana", "Alta", 4,
  "D", "Grande",  "Baja", 3, "D", "Grande",  "Media", 4, "D", "Grande", "Alta", 4,
  "E", "Cualquiera", "Cualquiera", 4
)

# Medidas de control recomendadas por nivel de riesgo potencial (1-4)
coshh_tabla_medidas <- tibble::tribble(
  ~nivel_riesgo, ~condiciones_tipicas, ~medidas_control,
  "1", "Agentes de peligrosidad A o B en baja cantidad y baja tendencia a pasar al ambiente.",
       "Ventilacion general. Riesgo leve.",
  "2", "Peligrosidad media o elevada con cantidad y/o volatilidad moderadas.",
       "Medidas especificas de prevencion y proteccion, por ejemplo, extraccion localizada.",
  "3", "Situaciones con agentes mas peligrosos o con mayores cantidades.",
       "Confinamiento o sistemas cerrados. Mantener el proceso a presion inferior a la atmosferica cuando sea posible.",
  "4", "Sustancias muy toxicas o cancerigenas o agentes de peligrosidad media en grandes cantidades.",
       "Cumplir con la legislacion para sustancias CMR de categorias 1 y 2. Evaluacion detallada de la exposicion. Verificar con mayor frecuencia la eficacia de las instalaciones de control."
)

# NOTA: la llamada a usethis::use_data() para estas tablas se hace en
# data-raw/build_sysdata.R, junto con el resto de tablas del paquete, para
# no sobrescribir R/sysdata.rda cada vez que se genera un modulo nuevo.
