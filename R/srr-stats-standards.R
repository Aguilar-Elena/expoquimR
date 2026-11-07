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
#' @srrstats {G1.2} The current development state and anticipated continued maintenance of expoquimR are documented in the Life cycle section of CONTRIBUTING.md.
#' @srrstats {G1.4} All exported functions are documented with roxygen2.
#' @srrstats {G1.4a} Package-level internal helper functions are documented using roxygen2 with @noRd. Local helper functions defined inside exported functions remain encapsulated within their documented parent functions.

#' @srrstats {EA1.0} The package documentation identifies occupational hygienists, occupational safety and health researchers, prevention practitioners, and engineers as target users.
#' @srrstats {EA1.1} The package documentation identifies the supported data, including qualitative chemical hazard/exposure descriptors and quantitative occupational exposure measurements.
#' @srrstats {EA1.3} Exported functions document their expected input parameters and data structures through roxygen2 help pages and methodological vignettes.
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
