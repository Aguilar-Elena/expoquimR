# expoquimR — primeros pasos (bloque COSHH)

Esto es el primer bloque del paquete: el método COSHH Essentials extraído
como funciones puras, testeadas, independientes de Shiny.

## Cómo integrarlo en tu Mac

1. Copia esta carpeta como la raíz de tu nuevo repo `expoquimR` (o pégala
   dentro si ya creaste el repo con `usethis::create_package()`).
2. Edita `DESCRIPTION`: pon tu nombre/email reales en `Authors@R` y la URL
   de GitHub definitiva.
3. Genera la licencia (falta el fichero `LICENSE` que referencia el
   `DESCRIPTION`):
   ```r
   usethis::use_mit_license("Raul Apellido")
   ```
4. Genera las tablas internas (`R/sysdata.rda`) con el script maestro,
   que junta COSHH e INRS en una sola llamada a `usethis::use_data()`
   (importante: si ejecutas `coshh_tablas.R` e `inrs_tablas.R` por
   separado con sus propios `use_data()`, el segundo te machaca el
   primero — por eso ahora hay un `build_sysdata.R`):
   ```r
   devtools::load_all()
   source("data-raw/build_sysdata.R")
   ```
5. Genera `NAMESPACE` y `man/` a partir del roxygen ya escrito en
   `R/coshh.R` y `R/inrs.R`:
   ```r
   devtools::document()
   ```
6. Corre los tests:
   ```r
   devtools::test()
   ```
7. `devtools::check()` para verificar que no hay warnings/notes antes de
   seguir añadiendo módulos.
8. Prueba las apps Shiny:
   ```r
   devtools::load_all()
   run_coshh()   # o run_inrs(), run_une689()
   ```

## Bloque INRS — correcciones aplicadas (confirmadas por Raul)

Estos 3 puntos ya están corregidos en `R/inrs.R` (revisa los tests
actualizados en `test-inrs.R`):

1. ✅ **Volatilidad por presión de vapor** — ahora usa los umbrales
   oficiales de la Tabla 8 INRS (0,5 kPa / 25 kPa) en vez de los que
   traía el formulario (10 kPa / 1 kPa).
2. ✅ **Volatilidad por gráfico** — ahora usa las dos rectas reales del
   gráfico (`linea1`, `linea2`) en vez del cociente
   temperatura/ebullición. El resultado del cálculo y el del gráfico ya
   son coherentes entre sí.
3. ✅ **Clase de peligro 1 como cajón de sastre** — si ninguna frase,
   proceso o VLA coincide con las clases 2-5, `inrs_clase_peligro()`
   ahora devuelve `"1"` por defecto (antes devolvía `NA`). Solo devuelve
   `NA` si no se proporcionó ningún criterio en absoluto.

Sigue pendiente de tu revisión, aunque no me pediste corregirlo (lo dejo
tal cual, es solo informativo):

4. **Tabla de frecuencia, filas "Semana"** — 4 filas de
   `inrs_tabla_frecuencia` nunca se usan porque la conversión de unidades
   solo genera periodo Día/Mes/Año. No afecta a los resultados actuales
   (esas filas simplemente nunca se consultan), pero si algún día quieres
   permitir introducir la frecuencia directamente en "veces por semana",
   ahí está la tabla ya lista.

## UNE-EN 689 (evaluación preliminar) — un fallo corregido sin preguntar

A diferencia de los puntos de INRS (que eran decisiones de criterio
metodológico y te las consulté antes de tocarlas), aquí encontré un
fallo de otra naturaleza: si todas las jornadas se quedaban sin datos
válidos, la comprobación original `all(IEs < 0.1, na.rm = TRUE)` daba
`TRUE` por una peculiaridad de R (`all()` sobre un vector vacío es
`TRUE`), y la app informaba **"CONFORMIDAD"** sin haber ningún dato real
detrás. Lo corregí directamente (ahora devuelve "sin datos suficientes"
en ese caso) porque declarar conformidad falsa en una evaluación de
exposición química es un problema de seguridad, no una cuestión de
criterio a consultar. Está documentado en el roxygen de
`une689_clasificar_conformidad()` y cubierto por un test específico.

## UNE-EN 689 (evaluación estadística) — notas

- El residuo de la app de ruido (`laeq_t`, `pico_estimado` sueltos fuera
  de su contexto) que había en `APP_QUIMICOS_689_v09_FINAL.R` **no se ha
  portado**: las funciones nuevas (`R/une689_estadistica.R`) están
  escritas desde cero a partir de la lógica normativa (Shapiro-Wilk,
  MG/DSG/MA/DS, UT, LSC₉₅,₇₀, UR), no copiadas línea a línea del fichero
  original, así que ese problema queda resuelto sin más.
- La tabla UT (n = 6 a 30) va como constante interna directamente en
  `R/une689_estadistica.R` (no en `data-raw/`), porque no depende de
  datos externos — es una tabla fija de la norma, no algo que vaya a
  cambiar.
- Los tests de `une689_test_normalidad()` y `une689_evaluar_estadistica()`
  comprueban la **estructura** del resultado (nombres, rangos de
  p-valor, coherencia entre `tipo`/`ur`/`lsc`/`conformidad`), no valores
  exactos de Shapiro-Wilk, porque no tengo R instalado en este entorno
  para calcular el valor de referencia exacto. Te recomiendo que cuando
  lo pruebes en tu Mac contrastes al menos un caso con un ejemplo
  resuelto a mano de la guía UNE-EN 689 (o del manual del INSST), para
  confirmar que `shapiro.test()` se está aplicando tal y como espera la
  norma.
- No incluí todavía un `une689_periodicidad()` que decida automáticamente
  "opción 1" vs "opción 2": de momento son dos funciones independientes
  (`une689_periodicidad_opcion1()`, `une689_periodicidad_opcion2()`) que
  reciben el valor que corresponda (`MG` o `MA` según el tipo de
  distribución, o el `LSC` calculado). Encajará con la futura capa Shiny,
  que es la que sabe qué opción ha elegido el usuario.

## Capa Shiny — ya está

- `R/run_apps.R`: `run_coshh()`, `run_inrs()`, `run_une689()`. Cada una
  comprueba que `shiny`/`DT`/`ggplot2` estén instalados
  (`requireNamespace()`) antes de lanzar nada, y ninguna se ejecuta al
  cargar el paquete — solo cuando el usuario las llama explícitamente,
  tal como exige la política de CRAN.
- `inst/apps/coshh/app.R`, `inst/apps/inrs/app.R`, `inst/apps/une689/app.R`:
  las tres apps llaman a las funciones exportadas del paquete
  (`coshh_evaluar()`, `inrs_evaluar()`, `une689_evaluar_preliminar()`,
  `une689_evaluar_estadistica()`, `une689_periodicidad_opcion1/2()`), no
  duplican ningún cálculo dentro del `server()`. Si algún día cambias una
  fórmula, solo hay que tocarla en `R/`, no en la app.
- Las opciones de los `selectInput` (cantidad/volatilidad en COSHH,
  procedimiento/protección/proceso en INRS) se leen en tiempo real de las
  tablas internas del paquete (`expoquimR:::coshh_tabla_riesgo`,
  `expoquimR:::inrs_tabla_procedimiento`, etc.) en vez de estar escritas
  a mano en la UI — así nunca se desincronizan si mañana cambias una
  tabla.
- La app de UNE-689 simplifica el diseño original: en vez de los dos
  contadores de jornadas separados (uno para la pestaña 1, otro para
  "jornadas extra" en la pestaña 2), hay **un único conjunto de jornadas
  compartido** entre las tres pestañas. Me pareció más claro que el
  original, pero dímelo si prefieres recuperar el comportamiento de dos
  niveles.
- `APP_EV_CUALITATIVA.R` (el placeholder con comentarios "pega aquí tu
  server COSHH/INRS") queda **resuelto de otra forma**: en vez de fusionar
  COSHH e INRS en una sola app con prefijos de id, cada método tiene su
  propia app independiente (`run_coshh()`, `run_inrs()`). Si prefieres
  una única app con pestañas para los tres métodos cualitativos +
  cuantitativo (más parecido a lo que insinuaba el placeholder original),
  dímelo y te la monto — es fácil, es el mismo patrón que ya usé en
  `une689/app.R` con `navbarPage()`.

## Lo que falta

- [x] Método COSHH
- [x] Método INRS
- [x] UNE-EN 689 evaluación preliminar
- [x] UNE-EN 689 evaluación estadística y periodicidad
- [x] Capa Shiny (`run_coshh()`, `run_inrs()`, `run_une689()`)
- [ ] Probar las 3 apps en tu Mac (`devtools::load_all()` +
      `run_coshh()` / `run_inrs()` / `run_une689()`) — yo no puedo
      ejecutarlas aquí porque no hay R instalado en este entorno, así que
      no están verificadas en tiempo de ejecución, solo revisadas a mano
      línea a línea
- [ ] Vignettes (una por método) y README con ejemplos reproducibles
- [ ] `devtools::check()` completo antes de pensar en CRAN
- [ ] Decidir si quieres una app única combinada (ver punto anterior)

## Núcleo de cálculo: completo

Con esto los cuatro bloques de cálculo puro (COSHH, INRS, UNE-689
preliminar, UNE-689 estadística) están escritos, documentados y
testeados. Es un buen punto para que hagas una pasada completa en tu Mac
(`devtools::document()`, `devtools::test()`, `devtools::check()`) antes
de seguir con la capa Shiny — así detectamos cualquier problema de
paquete (dependencias, imports, etc.) antes de que haya más código
encima.

## Un apunte sobre `coshh_grado()`

Al limpiar la lógica original detecté un caso sin cubrir: en la app
original, si una frase no empezaba por "H" y no se encontraba en la
tabla, simplemente no se le asignaba ningún grado (podía dejar el
resultado en `NA` sin más). Apliqué la regla oficial de COSHH Essentials
de forma consistente para *cualquier* frase no listada (R o H): se asigna
grado A por defecto. Revísalo en los tests (`test-coshh.R`, caso
`"H999"`) y dime si prefieres el comportamiento anterior.
