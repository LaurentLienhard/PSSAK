# Contributing

Thank you for your interest in contributing to PSSAK!

## Getting Started

1. Fork the repository and clone it locally
2. Create a branch from `prod` following the naming convention: `feature/<description>`, `fix/<description>`
3. Make your changes following the code style defined in [CLAUDE.md](CLAUDE.md)
4. Ensure all tests pass and code coverage is at least 85%
5. Submit a pull request targeting the `prod` branch

## Running the Tests

```powershell
# Install Pester if not already installed
Install-Module -Name Pester -MinimumVersion 5.0 -Force

# Run all unit tests
Invoke-Pester -Path tests/Unit -Output Detailed

# Run with code coverage
Invoke-Pester -Path tests/Unit -CodeCoverage source/**/*.ps1
```

## Code Style

Please follow the conventions described in [CLAUDE.md](CLAUDE.md):

- Opening braces on a new line
- `Write-Verbose` for informational messages
- No aliases, no ternary operators
- All public functions prefixed with `PSSAK` (e.g. `Write-PSSAKLog`)
- Full error handling with `try/catch`

## Internationalization

Every public function must be documented in all four supported languages before merging:

- English (`source/en-US/`)
- French (`source/fr-FR/`)
- German (`source/de-DE/`)
- Portuguese (`source/pt-PT/`)
