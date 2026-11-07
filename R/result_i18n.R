# Translate stored result labels without changing the package-wide language.
# The calculation outputs remain unchanged; only display copies are localized.
.localize_result_labels <- function(x, keys, lang = "en") {
  if (!lang %in% c("es", "en")) stop("Unsupported display language.")
  dict <- .translations
  source <- vapply(keys, function(key) dict$en[[key]], character(1))
  source_es <- vapply(keys, function(key) dict$es[[key]], character(1))
  target <- if (identical(lang, "es")) source_es else source
  result <- as.character(x)
  idx <- match(result, source)
  missing <- is.na(idx)
  idx[missing] <- match(result[missing], source_es)
  found <- !is.na(idx)
  result[found] <- target[idx[found]]
  names(result) <- names(x)
  result
}
