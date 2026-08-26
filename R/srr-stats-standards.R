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
#' @srrstatsTODO {G1.3} *All statistical terminology should be clarified and unambiguously defined.* 
#' @srrstats {G1.4} All exported functions are documented with roxygen2.
#' @srrstats {G1.4a} Package-level internal helper functions are documented using roxygen2 with @noRd. Local helper functions defined inside exported functions remain encapsulated within their documented parent functions. 
#' @srrstats {G2.0} Input lengths are explicitly validated for scalar and vector arguments through internal validation helpers and existing function-specific checks.
#' @srrstatsTODO {G2.0a} Provide explicit secondary documentation of any expectations on lengths of inputs
#' @srrstats {G2.1} Numeric input types are explicitly validated before statistical calculations are performed.
#' @srrstatsTODO {G2.1a} *Provide explicit secondary documentation of expectations on data types of all vector inputs.*
#' @srrstats {G2.2} Parameters expected to be scalar are explicitly restricted to length one.
#' @srrstatsTODO {G2.3} *For univariate character input:*
#' @srrstats {G2.3a} Enumerated character inputs use match.arg() or equivalent validation where applicable, including INRS quantity, frequency, substance-type, and liquid-method parameters.
#' @srrstats {G2.3b} Character inputs are normalised with tolower()/trimws() where case-insensitive matching is appropriate; constrained categorical parameters are otherwise handled through explicit argument matching.
#' @srrstatsTODO {G2.4} *Provide appropriate mechanisms to convert between different data types, potentially including:*
#' @srrstatsTODO {G2.4a} *explicit conversion to `integer` via `as.integer()`*
#' @srrstatsTODO {G2.4b} *explicit conversion to continuous via `as.numeric()`*
#' @srrstatsTODO {G2.4c} *explicit conversion to character via `as.character()` (and not `paste` or `paste0`)*
#' @srrstatsTODO {G2.6} *Software which accepts one-dimensional input should ensure values are appropriately pre-processed regardless of class structures.* 
#' @srrstatsTODO {G2.7} *Software should accept as input as many of the above standard tabular forms as possible, including extension to domain-specific forms.* 
#' @srrstatsTODO {G2.8} *Software should provide appropriate conversion or dispatch routines as part of initial pre-processing to ensure that all other sub-functions of a package receive inputs of a single defined class or type.*
#' @srrstatsTODO {G2.9} *Software should issue diagnostic messages for type conversion in which information is lost (such as conversion of variables from factor to character; standardisation of variable names; or removal of meta-data such as those associated with [`sf`-format](https://r-spatial.github.io/sf/) data) or added (such as insertion of variable or column names where none were provided).* 
#' @srrstatsTODO {G2.10} *Software should ensure that extraction or filtering of single columns from tabular inputs should not presume any particular default behaviour, and should ensure all column-extraction operations behave consistently regardless of the class of tabular data used as input.* 
#' @srrstatsTODO {G2.11} *Software should ensure that `data.frame`-like tabular objects which have columns which do not themselves have standard class attributes (typically, `vector`) are appropriately processed, and do not error without reason. This behaviour should be tested. Again, columns created by the [`units` package](https://github.com/r-quantities/units/) provide a good test case.*
#' @srrstatsTODO {G2.12} *Software should ensure that `data.frame`-like tabular objects which have list columns should ensure that those columns are appropriately pre-processed either through being removed, converted to equivalent vector columns where appropriate, or some other appropriate treatment such as an informative error. This behaviour should be tested.* 
#' @srrstats {G2.13} Missing values are explicitly checked during preprocessing in COSHH, INRS, UNE-EN 689, and Excel-import routines before analytic calculations are performed.
#' @srrstatsTODO {G2.14} *Where possible, all functions should provide options for users to specify how to handle missing (`NA`) data, with options minimally including:*
#' @srrstatsTODO {G2.14a} *error on missing data*
#' @srrstatsTODO {G2.14b} *ignore missing data with default warnings or messages issued*
#' @srrstatsTODO {G2.15} *Functions should never assume non-missingness, and should never pass data with potential missing values to any base routines with default `na.rm = FALSE`-type parameters (such as [`mean()`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/mean.html), [`sd()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/sd.html) or [`cor()`](https://stat.ethz.ch/R-manual/R-devel/library/stats/html/cor.html)).*
#' @srrstats {G2.16} Numeric inputs used in core statistical calculations are checked for non-finite values including Inf, -Inf and NaN. 
#' @srrstatsTODO {G3.0} *Statistical software should never compare floating point numbers for equality. All numeric equality comparisons should either ensure that they are made between integers, or use appropriate tolerances for approximate equality.* 
#' @srrstatsTODO {G4.0} *Statistical Software which enables outputs to be written to local files should parse parameters specifying file names to ensure appropriate file suffixes are automatically generated where not provided.* 
#' @srrstatsTODO {G5.0} *Where applicable or practicable, tests should use standard data sets with known properties (for example, the [NIST Standard Reference Datasets](https://www.itl.nist.gov/div898/strd/), or data sets provided by other widely-used R packages).*
#' @srrstats {G5.1} Package-supplied Excel templates used in tests and examples are distributed under inst/plantillas and are therefore available to users; additional inline fixtures are visible in the public test suite.
#' @srrstatsTODO {G5.2} *Appropriate error and warning behaviour of all functions should be explicitly demonstrated through tests. In particular,*
#' @srrstatsTODO {G5.2a} *Every message produced within R code by `stop()`, `warning()`, `message()`, or equivalent should be unique*
#' @srrstatsTODO {G5.2b} *Explicit tests should demonstrate conditions which trigger every one of those messages, and should compare the result with expected values.*
#' @srrstatsTODO {G5.3} *For functions which are expected to return objects containing no missing (`NA`) or undefined (`NaN`, `Inf`) values, the absence of any such values in return objects should be explicitly tested.* 
#' @srrstats {G5.4} Correctness tests compare deterministic COSHH, INRS, and UNE-EN 689 calculations against fixed expected values, including exposure indices, descriptive statistics, geometric statistics, tolerance-related quantities, and conformity classifications.
#' @srrstatsTODO {G5.4b} *For new implementations of existing methods, correctness tests should include tests against previous implementations. Such testing may explicitly call those implementations in testing, preferably from fixed-versions of other software, or use stored outputs from those where that is not possible.*
#' @srrstats {G5.8} Edge-condition behaviour is explicitly tested for unsupported input types, empty vectors, non-finite values, and out-of-domain numeric values.
#' @srrstats {G5.8a} Zero-length numeric input is explicitly tested and rejected where unsupported.
#' @srrstats {G5.8b} Unsupported input types are explicitly tested and rejected for core numeric routines.
#' @srrstatsTODO {G5.8c} *Data with all-`NA` fields or columns or all identical fields or columns*
#' @srrstatsTODO {G5.8d} *Data outside the scope of the algorithm (for example, data with more fields (columns) than observations (rows) for some regression algorithms)*
#' @srrstatsTODO {G5.9} **Noise susceptibility tests** *Packages should test for expected stochastic behaviour, such as through the following conditions:*
#' @srrstatsTODO {G5.9a} *Adding trivial noise (for example, at the scale of `.Machine$double.eps`) to data does not meaningfully change results*
#' @srrstats {EA1.0} The package documentation identifies occupational hygienists, occupational safety and health researchers, prevention practitioners, and engineers as target users.
#' @srrstats {EA1.1} The package documentation identifies the supported data, including qualitative chemical hazard/exposure descriptors and quantitative occupational exposure measurements.
#' @srrstats {EA1.2} The documented questions include qualitative risk classification, semi-quantitative prioritisation, quantitative exposure assessment, OEL conformity, additive exposure, and monitoring-interval decisions.
#' @srrstats {EA1.3} Exported functions document their expected input parameters and data structures through roxygen2 help pages and methodological vignettes.
#' @srrstatsTODO {EA2.6} *Routines should appropriately process vector data regardless of additional attributes* 
#' @srrstats {EA3.0} expoquimR automates extraction and reporting of occupational-hygiene statistics and decision outputs that are otherwise commonly calculated and interpreted manually under the implemented methodologies.
#' @srrstatsTODO {EA3.1} *EDA software should enable standardised comparison of inputs, processes, models, or outputs which previous or reference implementations otherwise only enable in some comparably unstandardised form.* 
#' @srrstatsTODO {EA4.0} *EDA Software should ensure all return results have types which are consistent with input types.* 
#' @srrstatsTODO {EA4.1} *EDA Software should implement parameters to enable explicit control of numeric precision*
#' @srrstatsTODO {EA4.2} *The primary routines of EDA Software should return objects for which default `print` and `plot` methods give sensible results. Default `summary` methods may also be implemented.* 
#' @srrstatsTODO {EA5.0} *Graphical presentation in EDA software should be as accessible as possible or practicable. In particular, EDA software should consider accessibility in terms of:*
#' @srrstatsTODO {EA5.0a} *Typeface sizes, which should default to sizes which explicitly enhance accessibility*
#' @srrstatsTODO {EA5.0b} *Default colour schemes, which should be carefully constructed to ensure accessibility.*
#' @srrstatsTODO {EA5.1} *Any explicit specifications of typefaces which override default values provided through other packages (including the `graphics` package) should consider accessibility* 
#' @srrstatsTODO {EA5.2} *Screen-based output should never rely on default print formatting of `numeric` types, rather should also use some version of `round(., digits)`, `formatC`, `sprintf`, or similar functions for numeric formatting according the parameter described in* **EA4.1**.
#' @srrstatsTODO {EA5.3} *Column-based summary statistics should always indicate the `storage.mode`, `class`, or equivalent defining attribute of each column.* 
#' @srrstatsTODO {EA5.4} *All visualisations should ensure values are rounded sensibly (for example, via `pretty()` function).*
#' @srrstatsTODO {EA5.5} *All visualisations should include units on all axes where such are specified or otherwise obtainable from input data or other routines.* 
#' @srrstatsTODO {EA6.0} *Return values from all functions should be tested, including tests for the following characteristics:*
#' @srrstatsTODO {EA6.0a} *Classes and types of objects*
#' @srrstatsTODO {EA6.0b} *Dimensions of tabular objects*
#' @srrstatsTODO {EA6.0c} *Column names (or equivalent) of tabular objects*
#' @srrstatsTODO {EA6.0d} *Classes or types of all columns contained within `data.frame`-type tabular objects *
#' @srrstatsTODO {EA6.0e} *Values of single-valued objects; for `numeric` values either using `testthat::expect_equal()` or equivalent with a defined value for the `tolerance` parameter, or using `round(..., digits = x)` with some defined value of `x` prior to testing equality.* 
#' @srrstatsTODO {EA6.1} *The properties of graphical output from EDA software should be explicitly tested, for example via the [`vdiffr` package](https://github.com/r-lib/vdiffr) or equivalent.* 
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
#' @noRd
NULL
