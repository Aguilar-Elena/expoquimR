#' Exposicion diaria (ED) de una jornada, segun UNE-EN 689
#'
#' Calcula la exposicion diaria a partir de las concentraciones y tiempos
#' de las muestras validas de una jornada. Si hay una unica muestra
#' valida tomada durante las 8 horas completas de jornada, la ED es
#' directamente esa concentracion. En caso contrario, se calcula como el
#' promedio ponderado por tiempo sobre una jornada de 8 horas
#' (`sum(concentracion * tiempo) / 8`).
#'
#' @param concentracion Numeric vector. Concentraciones medidas (mg/m3),
#'   una por muestra.
#' @param tiempo Numeric vector. Tiempo de cada muestra (horas), del
#'   mismo largo que `concentracion`.
#'
#' @return Numeric escalar con la ED, o `NA_real_` si no hay ninguna
#'   pareja (concentracion, tiempo) valida.
#'
#' @examples
#' une689_ed_jornada(concentracion = c(12, 8), tiempo = c(4, 4))
#' une689_ed_jornada(concentracion = 9, tiempo = 8)
#'
#' @export
une689_ed_jornada <- function(concentracion, tiempo) {
  stopifnot(length(concentracion) == length(tiempo))
  validas <- !is.na(concentracion) & !is.na(tiempo)
  conc <- concentracion[validas]
  tiem <- tiempo[validas]

  if (length(conc) == 0) return(NA_real_)
  if (length(conc) == 1 && isTRUE(tiem[1] == 8)) return(conc[1])

  sum(conc * tiem) / 8
}

#' Indice de exposicion (IE) de una jornada, segun UNE-EN 689
#'
#' @param ed Numeric. Exposicion diaria, vease [une689_ed_jornada()].
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#'
#' @return Numeric escalar (`ed / vla`), o `NA_real_` si `ed` o `vla` no
#'   son validos (`vla` debe ser `> 0`).
#'
#' @examples
#' une689_ie_jornada(ed = 9, vla = 10)
#'
#' @export
une689_ie_jornada <- function(ed, vla) {
  if (is.na(ed) || is.na(vla) || vla <= 0) return(NA_real_)
  ed / vla
}

#' Clasificar la conformidad de la evaluacion preliminar UNE-EN 689
#'
#' A partir de los indices de exposicion (IE) de todas las jornadas
#' evaluadas, determina si la exposicion es conforme, no conforme, o si
#' no permite tomar una decision sin mediciones adicionales, segun los
#' criterios de la evaluacion preliminar de UNE-EN 689.
#'
#' @param ie Numeric vector. Indices de exposicion, uno por jornada
#'   (vease [une689_ie_jornada()]). Los valores `NA` (jornadas sin datos
#'   suficientes) se ignoran.
#'
#' @return Character escalar: `.t("une689_conformity")` si todos los IE son
#'   menores que 0,1; `.t("une689_no_conformity")` si algun IE es mayor que 1;
#'   `.t("une689_no_decision")` si algun IE esta entre 0,1 y 1 (ambos inclusive) y
#'   ninguno supera 1. Devuelve `NA_character_` si no hay ningun IE valido
#'   (no hay datos suficientes para clasificar).
#'
#' @section Correccion respecto a la app original:
#' En la app Shiny original, si todas las jornadas tenian IE = `NA` (por
#' falta de datos), la comprobacion `all(IEs < 0.1, na.rm = TRUE)`
#' devolvia `TRUE` (porque `all()` sobre un vector vacio es `TRUE` en R),
#' y el resultado se informaba incorrectamente como
#' **.t("une689_conformity")** sin haber datos reales. Esta funcion corrige ese caso
#' devolviendo `NA_character_` (sin datos suficientes) en lugar de una
#' falsa conformidad. Te aviso de este cambio porque, a diferencia de los
#' puntos de INRS, no te pregunte antes de aplicarlo: informar
#' "conformidad" sin datos es un fallo de seguridad, no una decision de
#' criterio metodologico.
#'
#' @examples
#' une689_clasificar_conformidad(c(0.02))
#' une689_clasificar_conformidad(c(1, 0.9, 0.56))
#' une689_clasificar_conformidad(c(1.2, 0.05))
#'
#' @export
une689_clasificar_conformidad <- function(ie) {
  ie_validos <- ie[!is.na(ie)]
  if (length(ie_validos) == 0) return(NA_character_)

  if (all(ie_validos < 0.1)) {
    .t("une689_conformity")
  } else if (any(ie_validos > 1)) {
    .t("une689_no_conformity")
  } else if (any(ie_validos >= 0.1 & ie_validos <= 1)) {
    .t("une689_no_decision")
  } else {
    # No deberia alcanzarse nunca con datos validos; se deja por completitud.
    .t("une689_indeterminate")
  }
}

#' Comprobar el numero minimo de jornadas para la evaluacion preliminar
#'
#' La evaluacion preliminar de UNE-EN 689 exige un minimo de jornadas
#' evaluadas (habitualmente 3). Funcion de ayuda para validar esto antes
#' de calcular, tanto desde codigo como desde la futura app Shiny.
#'
#' @param n_jornadas Integer. Numero de jornadas con datos introducidos.
#' @param minimo Integer. Numero minimo exigido (por defecto 3).
#'
#' @return Logical: `TRUE` si `n_jornadas >= minimo`.
#'
#' @examples
#' une689_validar_min_jornadas(2)
#' une689_validar_min_jornadas(3)
#'
#' @export
une689_validar_min_jornadas <- function(n_jornadas, minimo = 3L) {
  n_jornadas >= minimo
}

#' Evaluacion preliminar completa UNE-EN 689 (funcion de alto nivel)
#'
#' Calcula la ED y el IE de cada jornada y clasifica la conformidad
#' global, a partir de un conjunto de muestras organizadas por jornada.
#' Pensada para usarse directamente desde codigo, sin pasar por la
#' aplicacion Shiny.
#'
#' @param datos Un `data.frame` en formato largo con columnas `jornada`
#'   (identificador de jornada, numerico o character), `concentracion`
#'   (mg/m3) y `tiempo` (horas). Una fila por muestra.
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#'
#' @return Una lista con dos elementos:
#'   \describe{
#'     \item{`tabla_jornadas`}{Un `data.frame` con columnas `jornada`,
#'       `ED` e `IE`, una fila por jornada.}
#'     \item{`resultado`}{Character escalar con la clasificacion global,
#'       vease [une689_clasificar_conformidad()].}
#'   }
#'
#' @examples
#' datos <- data.frame(
#'   jornada = c(1, 1, 2, 3, 3),
#'   concentracion = c(12, 8, 9, 5, 6),
#'   tiempo = c(4, 4, 8, 3, 5)
#' )
#' une689_evaluar_preliminar(datos, vla = 10)
#'
#' @export
une689_evaluar_preliminar <- function(datos, vla) {
  stopifnot(all(c("jornada", "concentracion", "tiempo") %in% names(datos)))

  jornadas <- sort(unique(datos$jornada))
  filas <- lapply(jornadas, function(j) {
    sub <- datos[datos$jornada == j, ]
    ed <- une689_ed_jornada(sub$concentracion, sub$tiempo)
    ie <- une689_ie_jornada(ed, vla)
    data.frame(jornada = j, ED = ed, IE = ie)
  })
  tabla_jornadas <- do.call(rbind, filas)
  rownames(tabla_jornadas) <- NULL

  resultado <- une689_clasificar_conformidad(tabla_jornadas$IE)

  list(tabla_jornadas = tabla_jornadas, resultado = resultado)
}
