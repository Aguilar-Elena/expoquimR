#' srr_stats
#'
#' All of the following standards initially have `@srrstatsTODO` tags.
#' These may be moved at any time to any other locations in your code.
#' Once addressed, please modify the tag from `@srrstatsTODO` to `@srrstats`,
#' or `@srrstatsNA`, ensuring that references to every one of the following
#' standards remain somewhere within your code.
#' (These comments may be deleted at any time.)
#'
#' @srrstatsVerbose TRUE
#'
#' @srrstats {G1.0} Primary methodological references for COSHH Essentials, the INRS simplified chemical-risk method, and EN 689 are listed in DESCRIPTION and the package documentation.
#' @srrstats {G1.1} expoquimR implements established occupational-hygiene methods rather than claiming novel statistical algorithms; its contribution is an integrated R implementation combining COSHH Essentials, INRS, and EN 689 workflows.
#' @srrstats {G1.2} The current development state and anticipated continued maintenance of expoquimR are documented in the Life cycle section of CONTRIBUTING.md. 
#' @srrstats {G1.3} Statistical terminology used by expoquimR is explicitly described in function documentation, the README, and the UNE-EN 689 vignette, including normal and lognormal distributions, Shapiro-Wilk testing, arithmetic and geometric summaries, tolerance limits, confidence and coverage, and risk indices.
#' @srrstats {G1.4} All exported functions are documented with roxygen2.
#' @srrstats {G1.4a} Package-level internal helper functions are documented using roxygen2 with @noRd. Local helper functions defined inside exported functions remain encapsulated within their documented parent functions. 
#' @srrstats {G2.0} Input lengths are explicitly validated for scalar and vector arguments through internal validation helpers and existing function-specific checks.
#' @srrstats {G2.0a} Function-level documentation explicitly states relevant input-length requirements, including equal-length concentration/time vectors and minimum ED sample sizes for UNE-EN 689 statistical assessment.
#' @srrstats {G2.1} Numeric input types are explicitly validated before statistical calculations are performed.
#' @srrstats {G2.1a} Function-level documentation explicitly identifies vector input types, including numeric exposure vectors and character hazard-phrase vectors.
#' @srrstats {G2.2} Parameters expected to be scalar are explicitly restricted to length one.
#' @srrstats {G2.3} Univariate character inputs are constrained or normalised as appropriate; permitted categorical values and case-handling behaviour are documented at function level.
#' @srrstats {G2.3a} Enumerated character inputs use match.arg() or equivalent validation where applicable, including INRS quantity, frequency, substance-type, and liquid-method parameters.
#' @srrstats {G2.3b} Character inputs are normalised with tolower()/trimws() where case-insensitive matching is appropriate; constrained categorical parameters are otherwise handled through explicit argument matching.
#' @srrstats {G2.4} Input preprocessing performs explicit type conversion where required, particularly when importing external tabular data and when normalising internal categorical values.
#' @srrstats {G2.4a} Integer-valued fields are explicitly converted with as.integer() where required, including UNE-EN 689 day and additive-group identifiers imported from Excel.
#' @srrstats {G2.4b} Continuous measurement and exposure fields imported from Excel are explicitly converted with as.numeric() before analytical processing.
#' @srrstats {G2.4c} Explicit as.character() conversion is used where numeric or categorical internal values must be matched as character values.
#' @srrstats {G2.6} One-dimensional numerical inputs are explicitly checked for unsupported class structures before analytical processing; classed vectors such as Date or domain-specific numeric classes are rejected with informative diagnostics rather than silently stripped of attributes.
#' @srrstats {G2.7} The preliminary UNE-EN 689 interface accepts base data frames, data-frame subclasses, and named two-dimensional matrices as tabular input.
#' @srrstats {G2.8} Tabular inputs are normalised during initial preprocessing to a base data.frame before analytical sub-functions are called.
#' @srrstats {G2.9} Conversion of data-frame subclasses to base data.frame emits an explicit diagnostic message because class-specific attributes may not be preserved.
#' @srrstats {G2.10} Tabular inputs are normalised to base data.frame before column extraction, providing consistent extraction semantics independent of the original supported tabular class.
#' @srrstats {G2.11} Required analytical columns with unsupported class attributes are explicitly detected and rejected with informative diagnostics.
#' @srrstats {G2.12} List columns in required UNE-EN 689 analytical fields are explicitly detected and rejected with informative diagnostics and dedicated tests.
#' @srrstats {G2.13} Missing values are explicitly checked during preprocessing in COSHH, INRS, UNE-EN 689, and Excel-import routines before analytic calculations are performed.
#' @srrstats {G2.15} Inputs are explicitly checked for missing values before statistical routines such as mean(), sd(), and shapiro.test() are called; operations that intentionally omit missing values do so explicitly.
#' @srrstats {G2.16} Numeric inputs used in core statistical calculations are checked for non-finite values including Inf, -Inf and NaN. 
#' @srrstats {G3.0} Floating-point equality is avoided; the UNE-EN 689 full-shift duration comparison uses an explicit numerical tolerance, while exact equality comparisons elsewhere concern integer counts or categorical values. 
#' @srrstats {G4.0} HTML report output filenames are normalised automatically; `.html` is appended when the user supplies a filename without an extension.

#' @srrstats {G5.1} Package-supplied Excel templates used in tests and examples are distributed under inst/plantillas and are therefore available to users; additional inline fixtures are visible in the public test suite.
#' @srrstats {G5.2} Error and message behaviour is explicitly exercised through the test suite, including validation failures, Excel-import failures, report input validation, Shiny application lookup, graphical argument validation, and UNE-EN 689 statistical preconditions.
#' @srrstats {G5.2a} Package-generated conditions have been audited across the R source tree; 41 stop/message expressions were identified and all 41 are unique, with importer-specific prefixes used where otherwise similar dependency or missing-column errors could be ambiguous.
#' @srrstats {G5.2b} Explicit tests verify expected error or message text for core validation conditions and representative package-generated conditions, including numeric validation, tabular normalisation, graphical arguments, Excel structure, language handling, report validation, Shiny application lookup, and UNE-EN 689 sample-size requirements.
#' @srrstats {G5.3} Tests explicitly verify that representative valid outputs from the core COSHH, INRS, and UNE-EN 689 computational routines contain no unexpected NA, NaN, Inf, or -Inf values.
#' @srrstats {G5.4} Correctness tests compare deterministic COSHH, INRS, and UNE-EN 689 calculations against fixed expected values, including exposure indices, descriptive statistics, geometric statistics, tolerance-related quantities, and conformity classifications.
#' @srrstats {G5.8} Edge-condition behaviour is explicitly tested for unsupported input types, empty vectors, non-finite values, and out-of-domain numeric values.
#' @srrstats {G5.8a} Zero-length numeric input is explicitly tested and rejected where unsupported.
#' @srrstats {G5.8b} Unsupported input types are explicitly tested and rejected for core numeric routines.
#' @srrstats {G5.8c} All-NA and all-identical exposure vectors are explicitly tested. All-NA exposure data are rejected, while identical valid observations produce the expected zero-variance summary; statistical evaluation of identical observations produces an explicit diagnostic.
#' @srrstats {G5.8d} Inputs outside the methodological domain are explicitly tested, including insufficient sample sizes and non-positive occupational exposure values.
#' @srrstats {G5.9} Numerical noise susceptibility is explicitly tested for deterministic occupational-hygiene calculations.
#' @srrstats {G5.9a} Tests verify that perturbations at approximately machine-precision scale do not materially alter UNE-EN 689 numerical summaries or COSHH categorical classifications.
#' @srrstats {EA1.0} The package documentation identifies occupational hygienists, occupational safety and health researchers, prevention practitioners, and engineers as target users.
#' @srrstats {EA1.1} The package documentation identifies the supported data, including qualitative chemical hazard/exposure descriptors and quantitative occupational exposure measurements.
#' @srrstats {EA1.2} The documented questions include qualitative risk classification, semi-quantitative prioritisation, quantitative exposure assessment, OEL conformity, additive exposure, and monitoring-interval decisions.
#' @srrstats {EA1.3} Exported functions document their expected input parameters and data structures through roxygen2 help pages and methodological vignettes.
#' @srrstats {EA2.6} Vector inputs with additional attributes or class structures are explicitly pre-processed; unsupported classed vectors are rejected with informative diagnostics rather than being silently coerced.
#' @srrstats {EA3.0} expoquimR automates extraction and reporting of occupational-hygiene statistics and decision outputs that are otherwise commonly calculated and interpreted manually under the implemented methodologies.
#' @srrstats {EA3.1} expoquimR provides standardised and reproducible comparison of occupational chemical exposure inputs, intermediate calculations, risk classifications, and conformity outputs across COSHH Essentials, INRS, and UNE-EN 689 through a common R, Excel, and interactive workflow.
#' @srrstats {EA4.0} Analytical functions return stable and predictable types appropriate to their inputs and calculations; scalar classifications, numeric statistics, data-frame outputs, and structured list outputs are explicitly tested for type consistency.
#' @srrstats {EA5.0} UNE-EN 689 graphical output is generated through a shared plotting helper designed to provide accessible labels, readable sizing, redundant visual encodings, and explicit units.
#' @srrstats {EA5.0a} UNE-EN 689 plots use a minimum base theme size of 12 and annotation text sized for legibility in both Shiny and rendered reports.
#' @srrstats {EA5.0b} UNE-EN 689 plots use a colour-blind-friendly palette together with distinct line types, so interpretation does not depend on colour alone.
#' @srrstats {EA5.2} Numeric values presented through Shiny and rendered reports are explicitly formatted using round(), sprintf(), knitr table precision, DT numeric formatting, or the controlled graphical digits parameter rather than relying on default numeric printing.
#' @srrstats {EA5.4} Numeric values displayed in UNE-EN 689 graphical annotations are explicitly rounded to a controlled number of digits, and this behaviour is tested.
#' @srrstats {EA5.5} UNE-EN 689 graphical axes explicitly report the available exposure units, including mg/m\u00b3 for daily exposure.
#' @srrstats {EA6.0} Return values from the analytical API are explicitly tested for structure, type, dimensions, names, column types, and numerical values as appropriate.
#' @srrstats {EA6.0a} Tests explicitly verify classes and types of returned lists, data frames, scalar values, and their principal components.
#' @srrstats {EA6.0b} Dimensions of tabular outputs are explicitly tested for the COSHH, INRS, and UNE-EN 689 analytical wrappers.
#' @srrstats {EA6.0c} Column and component names of structured return objects are explicitly tested.
#' @srrstats {EA6.0d} Column types of principal data.frame outputs are explicitly tested to ensure stable return structures.
#' @srrstats {EA6.0e} Tests of single-valued numeric outputs use explicit numerical tolerances; categorical and integer-valued outputs are tested using exact equality as appropriate.
#' @srrstats {EA6.1} Graphical output properties are explicitly tested, including ggplot class, axis labels and units, layer structure, distinct colour and line encodings, annotation rounding, and graphical input validation.
#' @noRd
NULL

#' NA_standards
#'
#' Any non-applicable standards can have their tags changed from `@srrstatsTODO`
#' to `@srrstatsNA`, and placed together in this block, along with explanations
#' for why each of these standards have been deemed not applicable.
#' (These comments may also be deleted at any time.)
#' @srrstatsNA {G1.5} No performance claims in associated publications are made for expoquimR, so there are no publication performance results requiring reproduction.
#' @srrstatsNA {G1.6} expoquimR does not make comparative computational-performance claims against alternative R implementations.
#' @srrstatsNA {G2.4d} The computational API does not require conversion of inputs to factor type.
#' @srrstatsNA {G2.4e} The computational API does not require factor inputs and therefore does not require factor-to-other-type conversion.
#' @srrstatsNA {G2.5} The computational API does not require ordered or unordered factor inputs.
#' @srrstatsNA {G2.14c} Automatic imputation is intentionally not implemented because imputing occupational exposure measurements or risk-assessment inputs could alter the scientific meaning of the assessment; missing-data handling is instead explicit.
#' @srrstatsNA {G3.1} expoquimR does not implement covariance estimation or rely on covariance calculations as part of its occupational-hygiene algorithms.
#' @srrstatsNA {G3.1a} No covariance methods are implemented, so user-selectable covariance algorithms are not applicable.
#' @srrstatsNA {G5.4a} The package implements established occupational-hygiene methods rather than a novel statistical method.
#' @srrstatsNA {G5.4c} Correctness testing does not rely on stored numerical outputs from published papers; fixed expected values and methodological calculations are used instead.
#' @srrstatsNA {G5.5} The implemented algorithms are deterministic and do not use random-number generation.
#' @srrstatsNA {G5.6} Parameter-recovery testing is not applicable because expoquimR does not estimate latent or simulated model parameters.
#' @srrstatsNA {G5.6a} No stochastic parameter-recovery procedure is implemented.
#' @srrstatsNA {G5.6b} Neither the implemented methods nor their tests contain random components requiring multiple random seeds.
#' @srrstatsNA {G5.7} The implemented methods are deterministic rule-based and formula-based occupational-hygiene procedures rather than iterative estimation algorithms for which convergence/performance behaviour is a scientific output.
#' @srrstatsNA {G5.9b} The package has no random seeds, stochastic initial conditions, or stochastic algorithms.
#' @srrstatsNA {G5.10} No extended test suite is currently required because the package test suite is lightweight and does not depend on long-running analyses or large external assets.
#' @srrstatsNA {G5.11} No large external data sets or other downloadable assets are required for testing.
#' @srrstatsNA {G5.11a} Tests do not download external assets, so download-failure handling for extended tests is not applicable.
#' @srrstatsNA {G5.12} There are no platform-, memory-, runtime-, or artefact-specific requirements for an extended test suite because no extended tests are required.
#' @srrstatsNA {EA2.0} expoquimR does not implement extensive relational table filtering and join workflows requiring an index-column system.
#' @srrstatsNA {EA2.1} No index-column system is required because the package does not operate on relational table collections.
#' @srrstatsNA {EA2.2} No explicit index-column system is required by the package workflow.
#' @srrstatsNA {EA2.2a} No index-column class system is required.
#' @srrstatsNA {EA2.2b} No table index attribute is required.
#' @srrstatsNA {EA2.3} expoquimR does not implement general-purpose relational table joins.
#' @srrstatsNA {EA2.4} The package does not require a relational table class system such as dm.
#' @srrstatsNA {EA2.5} The package does not operate on collections of relational tables requiring index validation.
#' @srrstatsNA {EA5.6} expoquimR does not internally bundle third-party dynamic-visualisation libraries.
#' @srrstatsNA {G5.0} No generally accepted standard reference dataset such as a NIST statistical dataset is applicable to the combined COSHH Essentials, INRS, and UNE-EN 689 occupational-hygiene workflows; deterministic reference values and package fixtures are used instead.
#' @srrstatsNA {EA5.1} expoquimR does not explicitly specify or override font families; graphical output inherits typefaces from ggplot2 and the rendering environment, while only accessible text sizing is specified.
#' @srrstatsNA {EA5.3} expoquimR does not generate column-based summary-statistics displays of the kind addressed by this standard; tabular outputs contain analytical results rather than metadata summaries of input columns.
#' @srrstatsNA {EA4.2} Primary expoquimR analytical routines intentionally return standard base-R scalar, data.frame, and list objects rather than a custom EDA class; these objects have sensible default print behaviour, while graphical presentation is provided explicitly through the dedicated UNE-EN 689 plotting layer, so custom default print/plot/summary methods are not applicable.
#' @srrstatsNA {G2.14} Missing-value handling in expoquimR is method-specific rather than user-selectable: analytical routines reject missing values where complete observations are required, omit incomplete paired measurements only where the implemented methodology explicitly permits this, or return NA when a valid classification cannot be made. A global user-selectable missing-data policy could produce scientifically invalid occupational-hygiene decisions.
#' @srrstatsNA {G2.14a} Missing data do not have a single package-wide error policy because appropriate behaviour depends on the implemented occupational-hygiene method; routines requiring complete statistical samples explicitly error on missing data.
#' @srrstatsNA {G2.14b} Ignoring missing observations is only performed in specific method-defined contexts, such as paired concentration/time preprocessing; offering a general ignore-missing option with warnings would permit methodologically inappropriate omission.
#' @srrstatsNA {G5.4b} expoquimR implements published occupational-hygiene methods rather than replacing a single previous software implementation for which a fixed reference implementation is available. Correctness is therefore tested against deterministic reference calculations, documented decision rules, and package fixtures.
#' @srrstatsNA {EA4.1} Analytical calculations intentionally retain full numeric precision rather than exposing a parameter that changes computational precision. Numeric precision is controlled explicitly only at the presentation layer through rounding, table formatting, report formatting, and graphical display parameters.
#' @noRd
NULL
