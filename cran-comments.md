## Resubmission note

This submission supersedes a previous submission of expoquimR (same
version, 0.1.0) made via the web form on approximately June 25, 2026,
which has not received any response after several weeks. No email was
ever received from CRAN regarding that submission (accept, reject, or
request for changes).

Since then, all function argument names, output column names and internal
variable names have been translated from Spanish to English throughout the
package, which was the main change I would have made in response to review
feedback in any case. Please treat this as the current, correct version to
review; the earlier pending submission can be discarded.

## R CMD check results

0 errors | 0 warnings | 1 note

* NOTE: unable to verify current time — network-related (local clock check
  against an NTP server), not package-related. Not expected to appear on
  CRAN's build machines.

(A previous NOTE about the hidden `.github` directory was caused by a
double-escaping bug in `.Rbuildignore`; this has been fixed.)

## Test environments

* Local: macOS 26.3 (aarch64), R 4.4.0
* rhub v2 (GitHub Actions): ubuntu-latest R-devel, windows-latest R-devel,
  macos-arm64 R-devel — all passed
* win-builder: R Under development (2026-07-24 r90297 ucrt) — 1 NOTE only
  (New submission; expected for a first CRAN submission)

## Downstream dependencies

None — this is a new submission.
