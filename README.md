# PSSAK - PowerShell Swiss Army Knife

<div align="center">
  <img src=".assets/PSSAK-LOGO-transparent.png" alt="PSSAK Logo" width="200" />
</div>

## Overview

**PSSAK** (PowerShell Swiss Army Knife) is a PowerShell **resource module** designed to provide foundational utilities that other modules can rely on. Instead of implementing repetitive boilerplate in every module, import PSSAK and get consistent, tested, and ready-to-use functions for logging, progress display, output formatting, and more.

## Key Features

- **Progress Bars** - Display rich, customizable progress bars with automatic ETA for long-running operations
- **Multi-Language Support** - Available in English, French, German, and Portuguese
- **Production-Ready** - Full error handling, comprehensive testing (85%+ code coverage), and PSScriptAnalyzer compliance
- **Extensive Documentation** - Complete help files in 4 languages

## Current Capabilities

### `Write-PSSAKProgressBar`

Displays a progress bar with automatic percentage calculation and optional estimated time remaining (ETA).

| Parameter | Type | Description |
|---|---|---|
| `-Activity` | String | Title displayed above the bar *(mandatory)* |
| `-Current` | Int32 | Current item index |
| `-Total` | Int32 | Total number of items |
| `-Status` | String | Text below the bar (default: `Current / Total`) |
| `-Id` | Int32 | Bar identifier for nested bars (default: `0`) |
| `-ParentId` | Int32 | Parent bar identifier (default: `-1`) |
| `-StartTime` | DateTime | Operation start time — enables ETA calculation |
| `-Completed` | Switch | Closes the bar cleanly |
| `-NoTimeEstimate` | Switch | Suppresses ETA even when `-StartTime` is provided |

#### Example — Simple progress bar

```powershell
$files = Get-ChildItem -Path C:\Logs
$start = [datetime]::UtcNow
$i = 0
foreach ($file in $files)
{
    $i++
    Write-PSSAKProgressBar -Activity 'Processing log files' `
        -Current $i -Total $files.Count -Status $file.Name -StartTime $start
}
Write-PSSAKProgressBar -Activity 'Processing log files' -Completed
```

#### Example — Nested progress bars

```powershell
for ($s = 1; $s -le $servers.Count; $s++)
{
    Write-PSSAKProgressBar -Activity 'Servers' -Current $s -Total $servers.Count -Id 1
    for ($f = 1; $f -le $files.Count; $f++)
    {
        Write-PSSAKProgressBar -Activity 'Files' -Current $f -Total $files.Count -Id 2 -ParentId 1
    }
    Write-PSSAKProgressBar -Activity 'Files' -Completed -Id 2
}
Write-PSSAKProgressBar -Activity 'Servers' -Completed -Id 1
```

## Requirements

- **PowerShell**: 7.0 or higher

## Installation

```powershell
Install-Module -Name PSSAK
```

## Roadmap

- [x] Progress bar (`Write-PSSAKProgressBar`)
- [ ] Structured logging (file, console, event log)
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
