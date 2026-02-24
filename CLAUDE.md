# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PSSAK (PowerShell's Swiss Army Knife) is a PowerShell administration tools module. The repository is hosted at https://github.com/LaurentLienhard/PSSAK.

## PowerShell Module Conventions

When developing this module, follow standard PowerShell module structure:
- Module manifest: `PSSAK.psd1`
- Root module file: `PSSAK.psm1`
- Use Pester for testing
- Use PSScriptAnalyzer for linting

## Git Workflow

### Branch Strategy

**When working on a new feature:**
1. Always create a **new branch from `prod`**
2. Use **descriptive branch names** following the pattern: `feature/<description>`, `fix/<description>`, `docs/<description>`
   - Examples: `feature/add-user-validation`, `fix/pipeline-handling`, `docs/french-help`
3. Keep the branch name **lowercase** with **hyphens** separating words
4. Each feature gets its **own dedicated branch**

### Pre-Commit Requirements

- **README.md must be updated before every `git commit` and `git push`** to reflect changes (new functions, API changes, new dependencies, etc.)
- **All tests must pass** before committing
- **Code must pass PSScriptAnalyzer** linting before committing
- **All translations must be complete** for the four supported languages before committing

### Commit Message Guidelines

**Every commit message MUST:**
- Be **clear, descriptive, and complete**
- Follow the format: `<Type>: <Subject> — <Description>`
- Use **English** only
- Start with a **type** prefix (see below)
- Provide sufficient context to understand the change without reading the code

**Commit Types:**
- `feat:` - New feature or functionality
- `fix:` - Bug fix
- `docs:` - Documentation changes (README, help files, comments)
- `test:` - Test additions or modifications
- `refactor:` - Code refactoring (no behavior change)
- `chore:` - Build, dependencies, tooling, .gitignore, etc.
- `i18n:` - Internationalization/translation updates

**Commit Message Format:**

```
feat: Add Get-PSAKUser function — Retrieves user information from Active Directory
This function queries AD for user objects and returns formatted PSCustomObject
with Name, SID, and Enabled properties. Includes full Pester test coverage (85%+).
```

```
fix: Correct pipeline handling in Set-PSAKPermission — Fixes issue #42
Previously failed when receiving objects via pipeline. Now properly handles
ValueFromPipeline parameter attribute and preserves object properties.
```

```
docs: Add French help files for Get-PSAKUser — Completes i18n requirement
Added source/fr-FR/Get-PSAKUser.help.txt with complete French documentation
to meet i18n release requirement.
```

**What to include in the message:**
- ✅ What changed and why
- ✅ If it fixes an issue, reference the issue number (#42)
- ✅ Any breaking changes or API modifications
- ✅ New function names or removed functions
- ✅ Dependencies added or updated
- ✅ i18n status if applicable

**What NOT to do:**
- ❌ Vague messages like "Update code", "Minor changes", "Work in progress"
- ❌ Messages without context: "Fixed bug" (which bug? how?)
- ❌ Partial i18n commits (all 4 languages or none)
- ❌ Combining unrelated changes in one commit

## Internationalization (i18n)

### Supported Languages

The PSSAK module must be available in **all four languages** before any `git push`:
1. **English** (en-US)
2. **French** (fr-FR)
3. **German** (de-DE)
4. **Portuguese** (pt-BR)

### Requirements for Help Files

- Help files MUST be placed in language-specific directories: `source/en-US/`, `source/fr-FR/`, `source/de-DE/`, `source/pt-BR/`
- Each function public help must have corresponding `.ps1xml` documentation files in **all four language directories**
- Use `New-ExternalHelp` to generate XML help files from comment-based help

### Requirements for Push

**BEFORE EVERY `git push`:**
- ✅ All help files must exist in all four languages
- ✅ All UI messages and documentation must be translated
- ✅ Test files must contain localized content for each language
- ✅ No partial or incomplete translations are allowed
- ✅ Use PSScriptAnalyzer with locale-specific rules for each language

### Translation Guidelines

- Use consistent terminology across all languages
- Store translatable strings in resource files (`.psd1` or XML)
- Use `Get-UICulture` to provide localized messages at runtime
- Document all terminology in a translation glossary for consistency

## Code Style

### General Rules
- **All code, functions, and documentation must be written in English**
- Comment-based help must be placed **immediately after the function name** (inside the function, before `[CmdletBinding()]`)
- **Every function (Public and Private) and every class must have a corresponding Pester test file**
- Tests must use mocks for external dependencies (no real API/AD/network calls)
- Each function/class must achieve **minimum 85% code coverage**
- **Prefer `Write-Verbose` over `Write-Host` or `Write-Output`** for informational messages
- **Always generate or update help files in `source/en-US/`** when adding or modifying functions

### Function Structure
- Use **uppercase** for `BEGIN`, `PROCESS`, `END` blocks
- Use `[CmdletBinding()]` for all functions
- Use `[OutputType()]` attribute when returning specific types
- Support pipeline input with `ValueFromPipeline` and `ValueFromPipelineByPropertyName`
- Use `[Parameter()]` attribute with `Mandatory`, `HelpMessage`, `Position` as needed
- Use validation attributes: `[ValidateSet()]`, `[ValidateNotNullOrEmpty()]`, `[ValidateRange()]`

### Naming Conventions

#### Function Naming - REQUIRED MODULE PREFIX

**All public functions MUST be prefixed with `PSSAK` to avoid naming conflicts.**

**Format**: `<Verb>-PSSAK<Noun>`

**Examples:**
- `Get-PSSAKInfo`
- `Test-PSSAKHealth`
- `Set-PSSAKPermission`

All verbs must be from `Get-Verb` approved list.

#### Private Functions

Private functions (in `source/Private/`) may use simpler names without the full prefix but using the full `PSSAK` prefix is recommended for consistency.

### Code Formatting

**Brace Placement:**
- Opening braces on **new line**: `OpenBraceOnSameLine = false`
- New line after opening brace: `true`
- New line after closing brace: `true`
- Whitespace before opening brace: `true`

**Spacing & Operators:**
- Whitespace before opening parenthesis: `true`
- Whitespace around operators: `true`
- Whitespace after separator: `true`
- Align property value pairs: `true`

**Pipeline Formatting:**
- Pipeline indentation style: `IncreaseIndentationAfterEveryPipeline`
- Single-line blocks ignored: `false`

**File Formatting:**
- Trim trailing whitespace: `true`
- Trim final newlines: `true`
- Insert final newline: `true`

**Example formatted code:**
```powershell
function Get-Example
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $result = Get-Content -Path $Name |
        Where-Object { $_ -match 'pattern' } |
        Select-Object -Property Property1, Property2

    return $result
}
```

### Coding Conventions
- Use **splatting** for commands with multiple parameters:
  ```powershell
  $params = @{
      ComputerName = $Computer
      ErrorAction  = 'Stop'
  }
  Invoke-Command @params
  ```
- Use `[PSCustomObject]@{}` for structured output objects
- Use `[System.Collections.Generic.List[T]]::new()` instead of `ArrayList` for collections
- Use `try/catch` blocks with specific exception types when possible
- Use `[SuppressMessageAttribute()]` to bypass PSScriptAnalyzer rules only when justified

### Parameter Patterns
- Credential parameter pattern (optional credentials):
  ```powershell
  [Parameter()]
  [System.Management.Automation.PSCredential]$Credential
  ```
- Check for credential with `$PSBoundParameters.ContainsKey('Credential')`

### Error Handling - REQUIRED

All functions MUST implement comprehensive error handling:
- **Catch specific exceptions first** before generic `[System.Exception]`
- **Set `-ErrorAction Stop`** on all external commands
- **Use try-catch-finally** for resource cleanup
- **Provide context in error messages** with relevant variable values
- Use `Write-Error` for terminating errors, `Write-Warning` for non-terminating issues

**Error message format:**
```powershell
# Contextual messages with variable values
Write-Error "Failed to process '$Name' in domain '$($env:USERDOMAIN)': $($_.Exception.Message)"
```

### Class Structure
- Use `#region` comments to organize sections: `#region <Properties>`, `#region <Constructor>`, `#region <Methods>`
- Prefix class files with numbers for load order (e.g., `01_Server.ps1`, `02_Service.ps1`)
- Use `HIDDEN` keyword for internal properties (e.g., credentials)

### Object-Oriented Design Philosophy

**Prefer classes over functions whenever possible.** Use classes for entities with multiple related properties or state. Functions are acceptable for simple stateless utilities, formatters, validators, or orchestration.

### PowerShell Compatibility

- **Minimum**: PowerShell 7.0
- **No aliases or ternary operators**: always use full cmdlet names and `if/else` for readability
- Always place `$null` on the left side of comparisons: `$null -eq $variable`, `$null -ne $variable` (avoids unexpected behavior with collections)
- `ForEach-Object -Parallel` may be used when necessary to optimize function performance
- Use `Join-Path` for cross-platform path handling

### Performance

- Use `[System.Collections.Generic.List[T]]::new()` instead of array concatenation (`+=`)
- Use splatting for clean, maintainable code
- Prefer pipeline filtering over sequential loops
- Use strongly typed collections for better performance
