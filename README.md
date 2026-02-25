# PSSAK - PowerShell Swiss Army Knife

<div align="center">
  <img src=".assets/PSSAK-LOGO-transparent.png" alt="PSSAK Logo" width="200" />
</div>

## Overview

**PSSAK** (PowerShell Swiss Army Knife) is a PowerShell **resource module** designed to provide foundational utilities that other modules can rely on. Instead of implementing repetitive boilerplate in every module, import PSSAK and get consistent, tested, and ready-to-use functions for logging, progress display, output formatting, and more.

## Key Features

- **Structured Logging** - Write consistent log entries with severity levels, timestamps, and configurable targets (console, file, event log)
- **Progress Bars** - Display rich, customizable progress bars for long-running operations
- **Output Formatting** - Helpers for tables, banners, colored output, and structured messages
- **Multi-Language Support** - Available in English, French, German, and Portuguese
- **Production-Ready** - Full error handling, comprehensive testing (85%+ code coverage), and PSScriptAnalyzer compliance

## Requirements

- **PowerShell**: 7.0 or higher

## Installation

```powershell
Install-Module -Name PSSAK
```

## Usage

```powershell
Import-Module PSSAK

# Logging
Write-PSSAKLog -Message 'Starting process' -Level Information
Write-PSSAKLog -Message 'Something went wrong' -Level Error

# Progress
Show-PSSAKProgress -Activity 'Processing files' -PercentComplete 42
```

## Roadmap

- [ ] Structured logging (file, console, event log)
- [ ] Customizable progress bars
- [ ] Output formatting utilities (tables, banners, colored output)
- [ ] Timer / stopwatch helpers
- [ ] Configuration management utilities

## Support

For issues, feature requests, or contributions, please visit the [GitHub repository](https://github.com/LaurentLienhard/PSSAK).

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please ensure:

- All code is documented in 4 languages (en-US, fr-FR, de-DE, pt-PT)
- Tests achieve 85%+ code coverage
- Code passes PSScriptAnalyzer validation
- Commit messages follow the format: `<Type>: <Subject> — <Description>`
