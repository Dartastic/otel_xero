# Changelog

## [0.1.0-beta.1] - 2026-06-04

### Added

- Initial release.
- `tracedXero<T>(...)` — wraps a otel_xero call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutXeroInstrumentation()` / `Async()`.
