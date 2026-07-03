#' Clase de cantidad diaria manipulada (metodo INRS)
#'
#' Clasifica la cantidad diaria de sustancia manipulada en una de las 5
#' clases del metodo INRS, segun su unidad.
#'
#' @param valor Numeric. Cantidad diaria manipulada.
#' @param unidad Character. Una de `"g"`, `"ml"`, `"kg"`, `"l"`.
#'
#' @return Character escalar (`"1"` a `"5"`), o `NA_character_` si
#'   `valor` es `NA`.
#'
#' @examples
#' inrs_clase_cantidad(50, "g")
#' inrs_clase_cantidad(500, "kg")
#'
#' @export
inrs_clase_cantidad <- function(valor, unidad = c("g", "ml", "kg", "l")) {
  unidad <- match.arg(unidad)
  if (is.na(valor)) return(NA_character_)

  if (unidad %in% c("g", "ml")) {
    if (valor < 100) "1" else if (valor < 10000) "2" else "3"
  } else {
    if (valor < 10) "2" else if (valor < 100) "3" else if (valor < 1000) "4" else "5"
  }
}

#' Clase de frecuencia de uso (metodo INRS)
#'
#' Convierte la frecuencia de uso indicada a las unidades de referencia de
#' la Tabla 3 del metodo INRS (horas/dia o dias/mes o dias/año, segun la
#' unidad de entrada) y devuelve la clase correspondiente (0 a 4).
#'
#' @param valor Numeric. Valor de frecuencia. Ignorado si
#'   `unidad = "no_se_usa"`.
#' @param unidad Character. Una de `"minutos"`, `"horas"`, `"dias"`,
#'   `"meses"`, `"no_se_usa"` (esta ultima para sustancias que no se usan
#'   con una frecuencia periodica, y siempre devuelve clase `"0"`).
#'
#' @return Character escalar (`"0"` a `"4"`), o `NA_character_` si no hay
#'   coincidencia en la tabla de referencia.
#'
#' @examples
#' inrs_clase_frecuencia(3, "horas")
#' inrs_clase_frecuencia(unidad = "no_se_usa")
#'
#' @export
inrs_clase_frecuencia <- function(valor = NA_real_,
                                   unidad = c("minutos", "horas", "dias", "meses", "no_se_usa")) {
  unidad <- match.arg(unidad)
  if (unidad == "no_se_usa") return("0")
  if (is.na(valor)) return(NA_character_)

  conv <- switch(unidad,
    minutos = list(valor = valor / 60, unidad_cmp = "horas", periodo = "Dia"),
    horas   = list(valor = valor,      unidad_cmp = "horas", periodo = "Dia"),
    dias    = list(valor = valor,      unidad_cmp = "dias",  periodo = "Mes"),
    meses   = list(valor = valor * 30, unidad_cmp = "dias",  periodo = "Anio")
  )

  tabla <- inrs_tabla_frecuencia
  fila <- tabla[
    tabla$unidad == conv$unidad_cmp &
      tabla$periodo == conv$periodo &
      conv$valor >= tabla$desde &
      conv$valor <= tabla$hasta,
    "clase",
    drop = TRUE
  ]

  if (length(fila) == 0) NA_character_ else fila[1]
}

#' Clase de peligro de una sustancia (metodo INRS)
#'
#' Determina la clase de peligro (1 a 5) de una sustancia a partir de sus
#' frases R, sus frases H, su VLA, o el material/proceso al que
#' pertenece, consultando la Tabla 1 del metodo INRS. Se explora desde la
#' clase mas peligrosa (5) hasta la menos peligrosa (1) y se devuelve la
#' primera clase para la que exista coincidencia. Si ninguna frase, VLA o
#' proceso coincide con las clases 2 a 5, se asigna la clase 1 por
#' defecto (cajon de sastre: "tiene frases pero ninguna de las
#' anteriores"), tal como establece la metodologia INRS.
#'
#' @param frases_r Character vector de frases R (opcional).
#' @param frases_h Character vector de frases H (opcional).
#' @param proceso Character escalar con el material/proceso (opcional).
#'   Se compara como subcadena (insensible a mayusculas) contra el texto
#'   de la Tabla 1.
#' @param vla Numeric. VLA en mg/m3 (opcional).
#'
#' @return Character escalar (`"1"` a `"5"`). Solo devuelve
#'   `NA_character_` si no se proporciono ningun criterio en absoluto
#'   (`frases_r`, `frases_h`, `proceso` y `vla` todos vacios/`NA`), en
#'   cuyo caso no hay informacion suficiente para clasificar.
#'
#' @examples
#' inrs_clase_peligro(frases_h = "H335")
#' inrs_clase_peligro(vla = 0.05)
#' inrs_clase_peligro(vla = 200) # cae en la clase 1 por defecto
#'
#' @export
inrs_clase_peligro <- function(frases_r = character(0),
                                frases_h = character(0),
                                proceso = NULL,
                                vla = NA_real_) {
  frases_r <- toupper(trimws(frases_r))
  frases_h <- toupper(trimws(frases_h))
  proceso_norm <- if (!is.null(proceso) && nzchar(trimws(proceso))) {
    tolower(trimws(proceso))
  } else {
    NULL
  }

  sin_criterios <- length(frases_r) == 0 && length(frases_h) == 0 &&
    is.null(proceso_norm) && is.na(vla)
  if (sin_criterios) return(NA_character_)

  tabla <- inrs_tabla_1

  for (j in 5:2) {
    fila <- tabla[tabla$clase_peligro == as.character(j), ]
    lista_r <- toupper(trimws(strsplit(fila$frases_r, ",")[[1]]))
    lista_h <- toupper(trimws(strsplit(fila$frases_h, ",")[[1]]))
    proceso_clase <- tolower(fila$materiales_procesos)

    match_r <- length(frases_r) > 0 && any(frases_r %in% lista_r)
    match_h <- length(frases_h) > 0 && any(frases_h %in% lista_h)
    match_proc <- !is.null(proceso_norm) && grepl(proceso_norm, proceso_clase, fixed = TRUE)
    match_vla <- if (!is.na(vla)) {
      switch(as.character(j),
        "5" = vla <= 0.1,
        "4" = vla > 0.1 & vla <= 1,
        "3" = vla > 1   & vla <= 10,
        "2" = vla > 10  & vla <= 100
      )
    } else {
      FALSE
    }

    if (match_r || match_h || match_proc || match_vla) {
      return(as.character(j))
    }
  }

  # Ninguna coincidencia en clases 2-5: clase 1 por defecto (cajon de sastre)
  "1"
}

#' Clase de exposicion potencial (metodo INRS)
#'
#' Consulta la Tabla 4 del metodo INRS (clase de cantidad x clase de
#' frecuencia) para obtener la clase de exposicion potencial.
#'
#' @param clase_cantidad Character. Vease [inrs_clase_cantidad()].
#' @param clase_frecuencia Character. Vease [inrs_clase_frecuencia()].
#'
#' @return Character escalar (`"0"` a `"5"`), o `NA_character_` si la
#'   combinacion no esta definida.
#'
#' @examples
#' inrs_clase_exposicion_potencial("3", "2")
#'
#' @export
inrs_clase_exposicion_potencial <- function(clase_cantidad, clase_frecuencia) {
  if (is.na(clase_cantidad) || is.na(clase_frecuencia)) return(NA_character_)

  tabla <- inrs_tabla_exposicion_potencial
  fila <- tabla[
    tabla$clase_cantidad == clase_cantidad & tabla$clase_frecuencia == clase_frecuencia,
    "clase_exposicion",
    drop = TRUE
  ]

  if (length(fila) == 0) NA_character_ else fila[1]
}

#' Clase de riesgo potencial (metodo INRS)
#'
#' Consulta la Tabla 5 del metodo INRS (clase de exposicion potencial x
#' clase de peligro) para obtener la clase de riesgo potencial.
#'
#' @param clase_exposicion_potencial Character. Vease
#'   [inrs_clase_exposicion_potencial()].
#' @param clase_peligro Character. Vease [inrs_clase_peligro()].
#'
#' @return Character escalar (`"1"` a `"5"`), o `NA_character_` si la
#'   combinacion no esta definida.
#'
#' @examples
#' inrs_clase_riesgo_potencial("4", "3")
#'
#' @export
inrs_clase_riesgo_potencial <- function(clase_exposicion_potencial, clase_peligro) {
  if (is.na(clase_exposicion_potencial) || is.na(clase_peligro)) return(NA_character_)

  tabla <- inrs_tabla_riesgo_potencial
  fila <- tabla[
    tabla$clase_exposicion == clase_exposicion_potencial & tabla$clase_peligro == clase_peligro,
    "clase_riesgo",
    drop = TRUE
  ]

  if (length(fila) == 0) NA_character_ else fila[1]
}

#' Puntuacion de riesgo potencial (metodo INRS)
#'
#' @param clase_riesgo_potencial Character. Vease
#'   [inrs_clase_riesgo_potencial()].
#'
#' @return Numeric (1, 10, 100, 1000 o 10000), o `NA_real_`.
#'
#' @examples
#' inrs_puntuacion_riesgo_potencial("3")
#'
#' @export
inrs_puntuacion_riesgo_potencial <- function(clase_riesgo_potencial) {
  if (is.na(clase_riesgo_potencial)) return(NA_real_)

  tabla <- inrs_tabla_puntuacion_riesgo
  fila <- tabla[tabla$clase_riesgo == clase_riesgo_potencial, "puntuacion", drop = TRUE]

  if (length(fila) == 0) NA_real_ else as.numeric(fila[1])
}

#' Clase de volatilidad de un liquido a partir de temperatura y punto de ebullicion
#'
#' Clasifica la volatilidad de un liquido comparando su punto de
#' ebullicion con las dos rectas de separacion de clases del grafico del
#' metodo INRS (Figura 2, temperatura de utilizacion en el eje X, punto
#' de ebullicion en el eje Y).
#'
#' @param temperatura_uso Numeric. Temperatura de uso (proceso), en
#'   grados Celsius. Corresponde al eje X del grafico.
#' @param punto_ebullicion Numeric. Punto de ebullicion, en grados
#'   Celsius. Corresponde al eje Y del grafico.
#'
#' @return Character escalar (`"1"` baja, `"2"` media, `"3"` alta).
#'
#' @examples
#' inrs_volatilidad_liquido_grafico(temperatura_uso = 20, punto_ebullicion = 200)
#' inrs_volatilidad_liquido_grafico(temperatura_uso = 20, punto_ebullicion = 80)
#'
#' @export
inrs_volatilidad_liquido_grafico <- function(temperatura_uso, punto_ebullicion) {
  if (is.na(temperatura_uso) || is.na(punto_ebullicion)) {
    return(NA_character_)
  }
  # Rectas de separacion de clases del grafico oficial INRS (Figura 2):
  # linea1 separa clase 1 (baja) de clase 2 (media): pasa por (0,70) y (150,240)
  # linea2 separa clase 2 (media) de clase 3 (alta): pasa por (0,135) y (125,300)
  linea1 <- 70 + (240 - 70) / 150 * temperatura_uso
  linea2 <- 135 + (300 - 135) / 125 * temperatura_uso

  if (punto_ebullicion > linea2) {
    "1"
  } else if (punto_ebullicion > linea1) {
    "2"
  } else {
    "3"
  }
}

#' Clase de volatilidad de un liquido a partir de la presion de vapor
#'
#' Clasifica la volatilidad de un liquido segun los umbrales oficiales de
#' la Tabla 8 del metodo INRS.
#'
#' @param presion_vapor Numeric. Presion de vapor a la temperatura de
#'   trabajo, en kPa.
#'
#' @return Character escalar (`"1"` si Pv < 0,5 kPa, `"2"` si
#'   0,5 <= Pv < 25 kPa, `"3"` si Pv >= 25 kPa).
#'
#' @examples
#' inrs_volatilidad_liquido_presion(15)
#'
#' @export
inrs_volatilidad_liquido_presion <- function(presion_vapor) {
  if (is.na(presion_vapor)) return(NA_character_)
  if (presion_vapor < 0.5) "1" else if (presion_vapor < 25) "2" else "3"
}

#' Clase de pulverulencia de un solido (metodo INRS)
#'
#' @param descripcion Character. Una de `"Polvo que genera mucha
#'   dispersion visible en el aire"`, `"Polvo fino con poca dispersion
#'   visible"` o `"Solido compacto sin polvo visible"`.
#'
#' @return Character escalar (`"1"` a `"3"`), o `NA_character_` si la
#'   descripcion no coincide con ninguna opcion valida.
#'
#' @examples
#' inrs_pulverulencia_solido("Polvo fino con poca dispersion visible")
#'
#' @export
inrs_pulverulencia_solido <- function(descripcion) {
  switch(descripcion,
    "Polvo que genera mucha dispersion visible en el aire" = "3",
    "Polvo fino con poca dispersion visible" = "2",
    "Solido compacto sin polvo visible" = "1",
    NA_character_
  )
}

#' Puntuacion de volatilidad o pulverulencia (metodo INRS)
#'
#' @param clase_volatilidad Character. `"1"`, `"2"` o `"3"`, tal como
#'   devuelven [inrs_volatilidad_liquido_grafico()],
#'   [inrs_volatilidad_liquido_presion()] o [inrs_pulverulencia_solido()].
#'
#' @return Numeric (1, 10 o 100), o `NA_real_`.
#'
#' @examples
#' inrs_puntuacion_volatilidad("2")
#'
#' @export
inrs_puntuacion_volatilidad <- function(clase_volatilidad) {
  if (is.na(clase_volatilidad)) return(NA_real_)
  switch(clase_volatilidad,
    "1" = 1, "2" = 10, "3" = 100,
    NA_real_
  )
}

#' Clase y puntuacion de procedimiento (metodo INRS)
#'
#' @param tipo Character. Uno de `"Dispersivo"`, `"Abierto"`,
#'   `"Cerrado/abierto regularmente"`, `"Cerrado permanente"`.
#'
#' @return Un `data.frame` de una fila con columnas `clase` y
#'   `puntuacion`.
#'
#' @examples
#' inrs_procedimiento("Abierto")
#'
#' @export
inrs_procedimiento <- function(tipo) {
  tabla <- inrs_tabla_procedimiento
  fila <- tabla[tabla$tipo == tipo, c("clase", "puntuacion")]
  if (nrow(fila) == 0) {
    data.frame(clase = NA_character_, puntuacion = NA_real_)
  } else {
    fila[1, ]
  }
}

#' Clase y puntuacion de proteccion colectiva (metodo INRS)
#'
#' @param situacion Character. Una de las situaciones de la Figura 4
#'   INRS, p. ej. `"Captacion envolvente"`.
#'
#' @return Un `data.frame` de una fila con columnas `clase` y
#'   `puntuacion`.
#'
#' @examples
#' inrs_proteccion("Captacion envolvente")
#'
#' @export
inrs_proteccion <- function(situacion) {
  tabla <- inrs_tabla_proteccion
  fila <- tabla[tabla$situacion == situacion, c("clase", "puntuacion")]
  if (nrow(fila) == 0) {
    data.frame(clase = NA_character_, puntuacion = NA_real_)
  } else {
    fila[1, ]
  }
}

#' Factor de correccion segun el VLA (metodo INRS)
#'
#' @param vla Numeric. VLA en mg/m3.
#'
#' @return Numeric (1, 10, 30 o 100), o `NA_real_` si `vla` es `NA`.
#'
#' @examples
#' inrs_fc_vla(0.05)
#'
#' @export
inrs_fc_vla <- function(vla) {
  if (is.na(vla)) return(NA_real_)
  if (vla > 0.1) 1
  else if (vla <= 0.1 && vla > 0.01) 10
  else if (vla <= 0.01 && vla > 0.001) 30
  else 100
}

#' Puntuacion final de riesgo por inhalacion (metodo INRS)
#'
#' Producto de las cinco puntuaciones parciales del metodo INRS.
#'
#' @param puntuacion_riesgo_potencial Numeric. Vease
#'   [inrs_puntuacion_riesgo_potencial()].
#' @param puntuacion_volatilidad Numeric. Vease
#'   [inrs_puntuacion_volatilidad()].
#' @param puntuacion_procedimiento Numeric. Vease [inrs_procedimiento()].
#' @param puntuacion_proteccion Numeric. Vease [inrs_proteccion()].
#' @param fc_vla Numeric. Vease [inrs_fc_vla()].
#'
#' @return Numeric, o `NA_real_` si falta algun componente.
#'
#' @examples
#' inrs_riesgo_inhalacion(100, 10, 0.5, 0.7, 10)
#'
#' @export
inrs_riesgo_inhalacion <- function(puntuacion_riesgo_potencial,
                                    puntuacion_volatilidad,
                                    puntuacion_procedimiento,
                                    puntuacion_proteccion,
                                    fc_vla) {
  componentes <- c(
    puntuacion_riesgo_potencial, puntuacion_volatilidad,
    puntuacion_procedimiento, puntuacion_proteccion, fc_vla
  )
  if (anyNA(componentes)) return(NA_real_)
  Reduce(`*`, componentes)
}

#' Caracterizacion del riesgo por inhalacion (metodo INRS)
#'
#' @param riesgo_inhalacion Numeric. Vease [inrs_riesgo_inhalacion()].
#'
#' @return Character escalar describiendo la prioridad de accion, o
#'   `NA_character_` si `riesgo_inhalacion` es `NA`.
#'
#' @examples
#' inrs_caracterizacion(2500)
#'
#' @export
inrs_caracterizacion <- function(riesgo_inhalacion) {
  if (is.na(riesgo_inhalacion)) return(NA_character_)
  if (riesgo_inhalacion > 1000) {
    "1 - Riesgo muy elevado (medidas correctoras inmediatas)"
  } else if (riesgo_inhalacion > 100) {
    "2 - Riesgo moderado (probablemente necesita medidas correctoras y/o evaluacion mas detallada)"
  } else {
    "3 - Riesgo a priori bajo (sin necesidad de modificaciones)"
  }
}

#' Evaluar un producto quimico con el metodo INRS (funcion de alto nivel)
#'
#' Encadena todos los pasos del metodo INRS (clase de peligro, cantidad,
#' frecuencia, exposicion potencial, riesgo potencial, volatilidad o
#' pulverulencia, procedimiento y proteccion colectiva) a partir de los
#' datos brutos de un producto, y devuelve una fila de resultado completa.
#' Pensada para usarse directamente desde codigo, sin pasar por la
#' aplicacion Shiny.
#'
#' @param nombre Character. Nombre del producto.
#' @param frases_r,frases_h Character vectors. Vease
#'   [inrs_clase_peligro()].
#' @param proceso Character. Vease [inrs_clase_peligro()].
#' @param vla Numeric. VLA en mg/m3.
#' @param cantidad_valor,cantidad_unidad Vease [inrs_clase_cantidad()].
#' @param frecuencia_valor,frecuencia_unidad Vease
#'   [inrs_clase_frecuencia()].
#' @param tipo_sustancia Character. `"liquida"` o `"solida"`.
#' @param metodo_liquido Character. `"grafico"` o `"presion"`. Solo se usa
#'   si `tipo_sustancia = "liquida"`.
#' @param temperatura_uso,punto_ebullicion Numeric. Solo si
#'   `metodo_liquido = "grafico"`.
#' @param presion_vapor Numeric. Solo si `metodo_liquido = "presion"`.
#' @param descripcion_solida Character. Solo si
#'   `tipo_sustancia = "solida"`. Vease [inrs_pulverulencia_solido()].
#' @param procedimiento Character. Vease [inrs_procedimiento()].
#' @param proteccion Character. Vease [inrs_proteccion()].
#'
#' @return Un `data.frame` de una fila con todas las clases y puntuaciones
#'   intermedias, la puntuacion final de riesgo por inhalacion y su
#'   caracterizacion.
#'
#' @examples
#' inrs_evaluar(
#'   nombre = "Disolvente X",
#'   frases_h = "H336",
#'   vla = 50,
#'   cantidad_valor = 5, cantidad_unidad = "l",
#'   frecuencia_valor = 3, frecuencia_unidad = "horas",
#'   tipo_sustancia = "liquida",
#'   metodo_liquido = "grafico",
#'   temperatura_uso = 40, punto_ebullicion = 80,
#'   procedimiento = "Abierto",
#'   proteccion = "Condiciones moderadas de dispersion"
#' )
#'
#' @export
inrs_evaluar <- function(nombre,
                          frases_r = character(0),
                          frases_h = character(0),
                          proceso = NULL,
                          vla = NA_real_,
                          cantidad_valor = NA_real_,
                          cantidad_unidad = c("g", "ml", "kg", "l"),
                          frecuencia_valor = NA_real_,
                          frecuencia_unidad = c("minutos", "horas", "dias", "meses", "no_se_usa"),
                          tipo_sustancia = c("liquida", "solida"),
                          metodo_liquido = c("grafico", "presion"),
                          temperatura_uso = NA_real_,
                          punto_ebullicion = NA_real_,
                          presion_vapor = NA_real_,
                          descripcion_solida = NA_character_,
                          procedimiento,
                          proteccion) {
  cantidad_unidad <- match.arg(cantidad_unidad)
  frecuencia_unidad <- match.arg(frecuencia_unidad)
  tipo_sustancia <- match.arg(tipo_sustancia)
  metodo_liquido <- match.arg(metodo_liquido)

  clase_peligro <- inrs_clase_peligro(frases_r, frases_h, proceso, vla)
  clase_cantidad <- inrs_clase_cantidad(cantidad_valor, cantidad_unidad)
  clase_frecuencia <- inrs_clase_frecuencia(frecuencia_valor, frecuencia_unidad)
  clase_expo_pot <- inrs_clase_exposicion_potencial(clase_cantidad, clase_frecuencia)
  clase_riesgo_pot <- inrs_clase_riesgo_potencial(clase_expo_pot, clase_peligro)
  punt_riesgo_pot <- inrs_puntuacion_riesgo_potencial(clase_riesgo_pot)

  clase_volatilidad <- if (tipo_sustancia == "liquida") {
    if (metodo_liquido == "grafico") {
      inrs_volatilidad_liquido_grafico(temperatura_uso, punto_ebullicion)
    } else {
      inrs_volatilidad_liquido_presion(presion_vapor)
    }
  } else {
    inrs_pulverulencia_solido(descripcion_solida)
  }
  punt_volatilidad <- inrs_puntuacion_volatilidad(clase_volatilidad)

  proc <- inrs_procedimiento(procedimiento)
  prot <- inrs_proteccion(proteccion)
  fc_vla <- inrs_fc_vla(vla)

  riesgo <- inrs_riesgo_inhalacion(
    punt_riesgo_pot, punt_volatilidad, proc$puntuacion, prot$puntuacion, fc_vla
  )
  caracterizacion <- inrs_caracterizacion(riesgo)

  data.frame(
    producto = nombre,
    clase_peligro = clase_peligro,
    clase_cantidad = clase_cantidad,
    clase_frecuencia = clase_frecuencia,
    clase_exposicion_potencial = clase_expo_pot,
    clase_riesgo_potencial = clase_riesgo_pot,
    puntuacion_riesgo_potencial = punt_riesgo_pot,
    clase_volatilidad_pulverulencia = clase_volatilidad,
    puntuacion_volatilidad_pulverulencia = punt_volatilidad,
    clase_procedimiento = proc$clase,
    puntuacion_procedimiento = proc$puntuacion,
    clase_proteccion = prot$clase,
    puntuacion_proteccion = prot$puntuacion,
    fc_vla = fc_vla,
    riesgo_inhalacion = riesgo,
    caracterizacion_riesgo = caracterizacion,
    stringsAsFactors = FALSE
  )
}
