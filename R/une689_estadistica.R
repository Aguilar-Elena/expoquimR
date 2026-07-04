# Tabla UT (factor de tolerancia unilateral al 95%/70%) segun UNE-EN 689,
# para tamanos de muestra n = 6 a 30. Para n > 30 se usa el valor limite
# 1,820. Objeto interno, no exportado (no necesita pasar por sysdata
# porque no depende de datos externos, es una constante del metodo).
une689_tabla_ut <- c(
  `6` = 2.187, `7` = 2.120, `8` = 2.072, `9` = 2.035, `10` = 2.005,
  `11` = 1.981, `12` = 1.961, `13` = 1.944, `14` = 1.929, `15` = 1.917,
  `16` = 1.905, `17` = 1.895, `18` = 1.886, `19` = 1.878, `20` = 1.870,
  `21` = 1.863, `22` = 1.857, `23` = 1.851, `24` = 1.846, `25` = 1.841,
  `26` = 1.836, `27` = 1.832, `28` = 1.828, `29` = 1.824, `30` = 1.820
)

#' Factor UT de UNE-EN 689 segun el tamano de muestra
#'
#' Consulta el factor de tolerancia unilateral (UT) tabulado por
#' UNE-EN 689 para un numero de jornadas `n` entre 6 y 30. Para
#' `n > 30` se usa el valor limite 1,820, tal como establece la norma.
#'
#' @param n Integer. Numero de jornadas (mediciones de ED) usadas en la
#'   evaluacion estadistica. Debe ser `>= 6`.
#'
#' @return Numeric escalar con el valor de UT, o `NA_real_` si
#'   `n < 6`.
#'
#' @examples
#' une689_ut(6)
#' une689_ut(50)
#'
#' @export
une689_ut <- function(n) {
  if (is.na(n) || n < 6) return(NA_real_)
  if (n > 30) return(1.820)
  unname(une689_tabla_ut[as.character(round(n))])
}

#' Estadisticos descriptivos de la exposicion diaria (UNE-EN 689)
#'
#' Calcula la media y desviacion tipica aritmeticas (MA, DS) y
#' geometricas (MG, DSG) de un conjunto de valores de exposicion diaria
#' (ED), necesarios para contrastar el ajuste normal y lognormal.
#'
#' @param ed Numeric vector. Valores de exposicion diaria (ED), todos
#'   estrictamente positivos.
#'
#' @return Una lista con los elementos `MA`, `DS`, `MG`, `DSG`.
#'
#' @examples
#' une689_estadisticos(c(5, 6, 7, 8, 9, 10))
#'
#' @export
une689_estadisticos <- function(ed) {
  if (any(is.na(ed)) || any(ed <= 0)) {
    stop("Todos los valores de ED deben ser numeros positivos, sin NA.", call. = FALSE)
  }
  log_ed <- log(ed)
  list(
    MA = mean(ed),
    DS = stats::sd(ed),
    MG = exp(mean(log_ed)),
    DSG = exp(stats::sd(log_ed))
  )
}

#' Contrastes de normalidad y lognormalidad (UNE-EN 689)
#'
#' Aplica el test de Shapiro-Wilk a los valores de ED (para contrastar
#' normalidad) y a su logaritmo (para contrastar lognormalidad).
#'
#' @param ed Numeric vector. Valores de exposicion diaria (ED), todos
#'   estrictamente positivos. Se requieren al menos 3 valores (minimo
#'   exigido por [stats::shapiro.test()]); UNE-EN 689 exige ademas un
#'   minimo de 6 para la evaluacion estadistica completa.
#'
#' @return Una lista con los elementos `W_normal`, `pval_normal`,
#'   `W_lognormal`, `pval_lognormal`.
#'
#' @examples
#' une689_test_normalidad(c(5, 6, 7, 8, 9, 10))
#'
#' @export
une689_test_normalidad <- function(ed) {
  test_normal <- stats::shapiro.test(ed)
  test_lognormal <- stats::shapiro.test(log(ed))

  list(
    W_normal = unname(test_normal$statistic),
    pval_normal = test_normal$p.value,
    W_lognormal = unname(test_lognormal$statistic),
    pval_lognormal = test_lognormal$p.value
  )
}

#' Determinar el tipo de distribucion (UNE-EN 689)
#'
#' Decide si los datos se ajustan mejor a una distribucion lognormal,
#' normal, o ninguna de las dos, a partir de los p-valores de
#' Shapiro-Wilk. Se da prioridad a la lognormal, siguiendo el criterio
#' habitual en higiene industrial (la exposicion suele ser lognormal).
#'
#' @param pval_normal Numeric. p-valor del test de normalidad sobre ED.
#' @param pval_lognormal Numeric. p-valor del test de normalidad sobre
#'   log(ED).
#' @param alfa Numeric. Nivel de significacion (por defecto 0,05).
#'
#' @return Character scalar: one of `"Lognormal"`, `"Normal"` or `"Neither"` (in English,
#'   the default), or the equivalent Spanish labels when `expoquimr_lang("es")` is active.
#'
#' @examples
#' une689_tipo_distribucion(pval_normal = 0.03, pval_lognormal = 0.20)
#'
#' @export
une689_tipo_distribucion <- function(pval_normal, pval_lognormal, alfa = 0.05) {
  if (pval_lognormal > alfa) {
    .t("une689_lognormal")
  } else if (pval_normal > alfa) {
    .t("une689_normal")
  } else {
    .t("une689_neither")
  }
}

#' Limite superior de confianza LSC(95,70) (UNE-EN 689)
#'
#' @param tipo Character. Distribution type as returned by [une689_tipo_distribucion()].
#'   Accepts both English (`"Lognormal"`, `"Normal"`, `"Neither"`) and Spanish labels.
#' @param ut Numeric. Factor UT, vease [une689_ut()].
#' @param MA,DS Numeric. Media y desviacion aritmeticas (solo se usan si
#'   needed when `tipo = "Normal"`); see [une689_estadisticos()].
#' @param MG,DSG Numeric. Media y desviacion geometricas (solo se usan
#'   needed when `tipo = "Lognormal"`); see [une689_estadisticos()].
#'
#' @return Numeric escalar con el LSC(95,70), o `NA_real_` si
#'   `tipo = "Neither"` (or `"Ninguna"` in Spanish).
#'
#' @examples
#' une689_lsc("Normal", ut = 2.005, MA = 7.5, DS = 1.87)
#'
#' @export
une689_lsc <- function(tipo, ut, MA = NA_real_, DS = NA_real_, MG = NA_real_, DSG = NA_real_) {
  # tipo uses internal English keys: "Lognormal", "Normal", "Neither"
  if (identical(tipo, .t("une689_lognormal")) || identical(tipo, "Lognormal")) {
    MG * DSG^ut
  } else if (identical(tipo, .t("une689_normal")) || identical(tipo, "Normal")) {
    MA + ut * DS
  } else {
    NA_real_
  }
}

#' Indice de riesgo unilateral UR (UNE-EN 689)
#'
#' @param tipo Character. Distribution type; see [une689_lsc()].
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#' @param MA,DS,MG,DSG Numeric. Vease [une689_lsc()].
#'
#' @return Numeric scalar, or `NA_real_` if `tipo = "Neither"`.
#'
#' @examples
#' une689_ur("Normal", vla = 10, MA = 7.5, DS = 1.87)
#'
#' @export
une689_ur <- function(tipo, vla, MA = NA_real_, DS = NA_real_, MG = NA_real_, DSG = NA_real_) {
  # tipo uses internal English keys: "Lognormal", "Normal", "Neither"
  if (identical(tipo, .t("une689_lognormal")) || identical(tipo, "Lognormal")) {
    (log(vla) - log(MG)) / log(DSG)
  } else if (identical(tipo, .t("une689_normal")) || identical(tipo, "Normal")) {
    (vla - MA) / DS
  } else {
    NA_real_
  }
}

#' Conformidad de la evaluacion estadistica (UNE-EN 689)
#'
#' @param ur Numeric. Indice de riesgo unilateral, vease [une689_ur()].
#' @param ut Numeric. Factor UT, vease [une689_ut()].
#'
#' @return Character scalar: `"CONFORMITY"` if `ur >= ut`, `"NON-CONFORMITY"` if
#'   `ur < ut`, or `NA_character_` if `ur` is `NA` (e.g. when neither the normal
#'   nor the lognormal fit is adequate). Labels are returned in the active language;
#'   see [expoquimr_lang()].
#'
#' @examples
#' une689_conformidad_estadistica(ur = 2.1, ut = 2.005)
#'
#' @export
une689_conformidad_estadistica <- function(ur, ut) {
  if (is.na(ur)) return(NA_character_)
  if (ur >= ut) .t("une689_conformity") else .t("une689_no_conformity")
}

#' Evaluacion estadistica completa UNE-EN 689 (funcion de alto nivel)
#'
#' Encadena el ajuste de distribucion, el calculo de UT, LSC(95,70), UR y
#' la conformidad estadistica a partir de un conjunto de valores de
#' exposicion diaria (ED). Pensada para usarse directamente desde
#' codigo, sin pasar por la aplicacion Shiny.
#'
#' @param ed Numeric vector. Valores de ED (uno por jornada), todos
#'   positivos. Se exige un minimo de 6 (vease
#'   [une689_validar_min_jornadas()]).
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#'
#' @return Una lista con los elementos `n`, `tipo`, `MA`, `DS`, `MG`,
#'   `DSG`, `W_normal`, `pval_normal`, `W_lognormal`, `pval_lognormal`,
#'   `ut`, `lsc`, `ur`, `conformidad`.
#'
#' @examples
#' une689_evaluar_estadistica(c(5, 6, 7, 8, 9, 10), vla = 10)
#'
#' @export
une689_evaluar_estadistica <- function(ed, vla) {
  n <- length(ed)
  if (!une689_validar_min_jornadas(n, minimo = 6L)) {
    stop("Se necesitan al menos 6 jornadas (valores de ED) para la evaluacion estadistica.", call. = FALSE)
  }

  est <- une689_estadisticos(ed)
  test <- une689_test_normalidad(ed)
  tipo <- une689_tipo_distribucion(test$pval_normal, test$pval_lognormal)
  ut <- une689_ut(n)
  lsc <- une689_lsc(tipo, ut, MA = est$MA, DS = est$DS, MG = est$MG, DSG = est$DSG)
  ur <- une689_ur(tipo, vla, MA = est$MA, DS = est$DS, MG = est$MG, DSG = est$DSG)
  conformidad <- une689_conformidad_estadistica(ur, ut)

  list(
    n = n,
    tipo = tipo,
    MA = est$MA, DS = est$DS, MG = est$MG, DSG = est$DSG,
    W_normal = test$W_normal, pval_normal = test$pval_normal,
    W_lognormal = test$W_lognormal, pval_lognormal = test$pval_lognormal,
    ut = ut, lsc = lsc, ur = ur, conformidad = conformidad
  )
}

#' Periodicidad recomendada, opcion 1 (MG o MA frente al VLA)
#'
#' @param valor_referencia Numeric. MG si la distribucion es lognormal,
#'   o MA si es normal (vease [une689_estadisticos()]).
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#'
#' @return Character escalar describiendo la periodicidad recomendada,
#'   en meses.
#'
#' @examples
#' une689_periodicidad_opcion1(valor_referencia = 0.8, vla = 10)
#'
#' @export
une689_periodicidad_opcion1 <- function(valor_referencia, vla) {
  if (is.na(valor_referencia) || is.na(vla)) {
    return(NA_character_)
  }
  if (valor_referencia < 0.1 * vla) {
    .t("une689_period_36")
  } else if (valor_referencia < 0.25 * vla) {
    .t("une689_period_24")
  } else if (valor_referencia < 0.5 * vla) {
    .t("une689_period_18")
  } else {
    .t("une689_period_12")
  }
}

#' Periodicidad recomendada, opcion 2 (LSC95,70 frente al VLA)
#'
#' @param lsc Numeric. LSC(95,70), vease [une689_lsc()].
#' @param vla Numeric. Valor Limite Ambiental (mg/m3).
#'
#' @return Character escalar describiendo la periodicidad recomendada,
#'   en meses, o un aviso de que la exposicion debe revisarse.
#'
#' @examples
#' une689_periodicidad_opcion2(lsc = 4, vla = 10)
#'
#' @export
une689_periodicidad_opcion2 <- function(lsc, vla) {
  if (is.na(lsc) || is.na(vla) || vla <= 0) {
    return(NA_character_)
  }
  j <- lsc / vla
  if (j < 0.25) {
    .t("une689_period_36")
  } else if (j < 0.5) {
    .t("une689_period_30")
  } else if (j < 1) {
    .t("une689_period_24")
  } else {
    .t("une689_period_review")
  }
}
