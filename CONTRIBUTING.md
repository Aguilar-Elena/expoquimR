# Contributing to expoquimR

Thank you for considering contributing to expoquimR.

expoquimR is an open-source R package for qualitative and quantitative
assessment of occupational exposure to chemical agents. Contributions
that improve methodological accuracy, reproducibility, documentation,
testing, accessibility, or usability are welcome.

## Reporting issues

Please use the GitHub issue tracker to report:

- bugs or unexpected behaviour;
- inconsistencies with the documented occupational hygiene methods;
- documentation problems;
- usability issues;
- suggestions for additional tests;
- proposals for new functionality.

When reporting a calculation-related issue, please include a minimal
reproducible example whenever possible.

Do not include confidential, identifiable, or commercially sensitive
workplace data in public issues.

## Methodological changes

Changes affecting COSHH Essentials, the INRS methodology, UNE-EN 689, or
any other occupational hygiene calculation must:

1.  identify the methodological source supporting the change;
2.  explain the reason for the modification;
3.  include or update automated tests where applicable; and
4.  preserve the distinction between computational implementation and
    professional occupational hygiene judgement.

Changes to established methodological rules should not be introduced
solely because they appear more intuitive or convenient.

## Development workflow

Please create a dedicated branch for each contribution.

Before submitting a pull request:

1.  install the development dependencies;
2.  run the relevant unit tests;
3.  run a full package check;
4.  update documentation where necessary; and
5.  describe clearly what has changed and why.

A typical local check can be performed with:

``` R
devtools::test()
devtools::check()
```

Pull requests should be focused on one issue or one coherent group of
changes.

## Testing

New functionality should include tests whenever reasonably possible.

For numerical calculations, tests should compare results against known,
independently established, or analytically derived reference values
rather than only checking that a function executes without error.

Edge cases, invalid input, missing values, and expected warnings or
errors should also be tested where relevant.

## Documentation

User-facing functions should be documented using roxygen2 conventions.

Changes affecting methodology should also be reflected in the relevant
vignette or README section.

## Code review

All contributions may be reviewed for:

- methodological correctness;
- reproducibility;
- clarity;
- backwards compatibility;
- test coverage;
- documentation; and
- consistency with the scope of expoquimR.

## Scientific and professional responsibility

expoquimR supports occupational hygiene assessment but does not replace
professional judgement.

Contributors should avoid changes that imply that sampling strategy,
representativeness of measurements, toxicological interpretation, or
preventive decision-making can be determined automatically where
professional evaluation is required.

## Questions

For questions about contributing, open a GitHub issue or contact the
package maintainer:

Raúl Aguilar-Elena <raguilar@universidadviu.com>

## Life cycle

This package is in a stable state of development, with some degree of
active subsequent development as envisioned by the primary authors.

## Life cycle

This package is in a stable state of development, with some degree of
active subsequent development as envisioned by the primary authors.
