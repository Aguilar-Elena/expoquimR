#' Clasificar la volatilidad de un liquido segun el metodo COSHH Essentials
#'
#' Compara la temperatura de ebullicion de la sustancia con su temperatura
#' de proceso para asignar una clase de volatilidad ("Baja", "Media" o
#' "Alta"), siguiendo los umbrales del metodo COSHH Essentials.
#'
#' @param t_ebullicion Numeric. Punto de ebullicion de la sustancia, en
#'   grados Celsius.
#' @param t_proceso Numeric. Temperatura a la que se manipula la sustancia,
#'   en grados Celsius.
#'
#' @return Character escalar: `"Baja"`, `"Media"` o `"Alta"`.
#'
#' @examples
#' coshh_clasificar_volatilidad(t_ebullicion = 111, t_proceso = 20)
#' coshh_clasificar_volatilidad(t_ebullicion = 56, t_proceso = 40)
#'
#' @export
coshh_clasificar_volatilidad <- function(t_ebullicion, t_proceso) {
  stopifnot(is.numeric(t_ebullicion), is.numeric(t_proceso))
  if (anyNA(t_ebullicion) || anyNA(t_proceso)) {
    stop("t_ebullicion y t_proceso no pueden ser NA.", call. = FALSE)
  }

  ifelse(
    t_ebullicion > 5 * t_proceso + 50, "Baja",
    ifelse(t_ebullicion > 2 * t_proceso + 10, "Media", "Alta")
  )
}

#' Determinar el grado de peligrosidad COSHH a partir de frases R/H
#'
#' Busca cada frase de riesgo (R) o de peligro (H) introducida en la tabla
#' de asignacion de grados del metodo COSHH Essentials (grados A a E) y
#' devuelve el grado mas desfavorable encontrado. Cualquier frase que no
#' figure explicitamente en los grupos B-E se asigna al grado A, siguiendo
#' la regla del metodo original.
#'
#' @param frases Character escalar con una o varias frases separadas por
#'   comas, p. ej. `"H315, H319"` o `"R20/21/22"`.
#'
#' @return Character escalar con el grado (`"A"` a `"E"`), o `NA_character_`
#'   si `frases` esta vacio o es `NA`.
#'
#' @examples
#' coshh_grado("H315, H319")
#' coshh_grado("R23/24/25")
#'
#' @export
coshh_grado <- function(frases) {
  if (is.null(frases) || is.na(frases) || !nzchar(trimws(frases))) {
    return(NA_character_)
  }

  tokens <- trimws(toupper(strsplit(frases, ",")[[1]]))
  tokens <- tokens[nzchar(tokens)]
  if (length(tokens) == 0) return(NA_character_)

  tabla <- coshh_tabla_grados
  orden <- c("A", "B", "C", "D", "E")

  grado_de_token <- function(token) {
    for (i in seq_len(nrow(tabla))) {
      lista_r <- trimws(toupper(strsplit(tabla$frases_r[i], ",")[[1]]))
      lista_h <- trimws(toupper(strsplit(tabla$frases_h[i], ",")[[1]]))
      if (token %in% lista_r || token %in% lista_h) {
        return(tabla$grado[i])
      }
    }
    # Regla COSHH: cualquier frase no listada en B-E pertenece al grado A
    "A"
  }

  grados <- vapply(tokens, grado_de_token, character(1))
  orden[max(match(grados, orden))]
}

#' Calcular el nivel de riesgo COSHH
#'
#' Consulta la matriz peligrosidad x cantidad x volatilidad del metodo
#' COSHH Essentials para obtener el nivel de riesgo potencial (1 a 4). Las
#' sustancias de grado `"E"` (cancerigenas, mutagenas o similares) obtienen
#' siempre el nivel maximo, con independencia de la cantidad o volatilidad.
#'
#' @param grado Character. Grado de peligrosidad (`"A"` a `"E"`), tal como
#'   lo devuelve [coshh_grado()].
#' @param cantidad Character. Uno de `"Pequeña"`, `"Mediana"` o `"Grande"`.
#' @param volatilidad Character. Uno de `"Baja"`, `"Media"` o `"Alta"`
#'   (vease [coshh_clasificar_volatilidad()] para liquidos; para solidos
#'   corresponde a la pulverulencia).
#'
#' @return Integer con el nivel de riesgo (1 a 4), o `NA_integer_` si la
#'   combinacion no esta definida en la tabla o si `grado` es `NA`.
#'
#' @examples
#' coshh_riesgo(grado = "C", cantidad = "Mediana", volatilidad = "Alta")
#' coshh_riesgo(grado = "E", cantidad = "Pequeña", volatilidad = "Baja")
#'
#' @export
coshh_riesgo <- function(grado, cantidad, volatilidad) {
  if (is.na(grado)) return(NA_integer_)
  if (grado == "E") return(4L)

  resultado <- coshh_tabla_riesgo[
    coshh_tabla_riesgo$peligrosidad == grado &
      coshh_tabla_riesgo$cantidad == cantidad &
      coshh_tabla_riesgo$volatilidad == volatilidad,
    "riesgo",
    drop = TRUE
  ]

  if (length(resultado) == 0) NA_integer_ else as.integer(resultado[1])
}

#' Obtener las medidas de control recomendadas para un nivel de riesgo COSHH
#'
#' @param nivel_riesgo Integer o character. Nivel de riesgo (1 a 4), tal
#'   como lo devuelve [coshh_riesgo()].
#'
#' @return Character escalar con las medidas de control recomendadas, o
#'   `NA_character_` si el nivel no esta definido.
#'
#' @examples
#' coshh_medidas(3)
#'
#' @export
coshh_medidas <- function(nivel_riesgo) {
  if (is.na(nivel_riesgo)) return(NA_character_)
  nivel_riesgo <- as.character(nivel_riesgo)

  resultado <- coshh_tabla_medidas[
    coshh_tabla_medidas$nivel_riesgo == nivel_riesgo,
    "medidas_control",
    drop = TRUE
  ]

  if (length(resultado) == 0) NA_character_ else resultado[1]
}

#' Evaluar una sustancia con el metodo COSHH Essentials (funcion de alto nivel)
#'
#' Encadena [coshh_grado()], [coshh_clasificar_volatilidad()] (si procede),
#' [coshh_riesgo()] y [coshh_medidas()] para producir una fila de resultado
#' completa a partir de los datos brutos de una sustancia. Pensada para
#' usarse directamente desde codigo (scripts, informes, `purrr::pmap`,
#' vignettes) sin pasar por la aplicacion Shiny.
#'
#' @param nombre Character. Nombre identificativo de la sustancia.
#' @param frases Character. Frases R/H, ver [coshh_grado()].
#' @param cantidad Character. Uno de `"Pequeña"`, `"Mediana"`, `"Grande"`.
#' @param es_liquido Logical. `TRUE` si la sustancia es liquida (se
#'   calculara la volatilidad a partir de `t_ebullicion`/`t_proceso`);
#'   `FALSE` si es solida (se usara `pulverulencia` directamente).
#' @param t_ebullicion,t_proceso Numeric. Necesarios solo si
#'   `es_liquido = TRUE`. Vease [coshh_clasificar_volatilidad()].
#' @param pulverulencia Character. Necesario solo si `es_liquido = FALSE`.
#'   Uno de `"Baja"`, `"Media"`, `"Alta"`.
#'
#' @return Un `data.frame` de una fila con las columnas `sustancia`,
#'   `frases`, `grado`, `volatilidad`, `cantidad`, `riesgo` y `medidas`.
#'
#' @examples
#' coshh_evaluar(
#'   nombre = "Toluendo",
#'   frases = "H315, H336",
#'   cantidad = "Mediana",
#'   es_liquido = TRUE,
#'   t_ebullicion = 111,
#'   t_proceso = 20
#' )
#'
#' @export
coshh_evaluar <- function(nombre,
                           frases,
                           cantidad,
                           es_liquido,
                           t_ebullicion = NA_real_,
                           t_proceso = NA_real_,
                           pulverulencia = NA_character_) {
  grado <- coshh_grado(frases)

  volatilidad <- if (isTRUE(es_liquido)) {
    coshh_clasificar_volatilidad(t_ebullicion, t_proceso)
  } else {
    pulverulencia
  }

  riesgo <- coshh_riesgo(grado, cantidad, volatilidad)
  medidas <- coshh_medidas(riesgo)

  data.frame(
    sustancia = nombre,
    frases = frases,
    grado = grado,
    volatilidad = volatilidad,
    cantidad = cantidad,
    riesgo = riesgo,
    medidas = medidas,
    stringsAsFactors = FALSE
  )
}
