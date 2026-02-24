# PSSAK - PowerShell's Swiss Army Knife

<div align="center">
  <img src=".assets/PSSAK-LOGO.png" alt="PSSAK Logo" width="200" />
</div>

## Overview

**PSSAK** (PowerShell's Swiss Army Knife) is a comprehensive PowerShell module designed to simplify and standardize common IT administration tasks. It provides a complete toolkit for system administrators, with a strong focus on Active Directory management through an object-oriented approach.

## Key Features

✅ **Object-Oriented Design** - PowerShell classes for better modularity and code reusability
✅ **Multi-Language Support** - Available in English, French, German, and Portuguese
✅ **Production-Ready** - Full error handling, comprehensive testing (85%+ code coverage), and PSScriptAnalyzer compliance
✅ **Extensive Documentation** - Complete help files in 4 languages
✅ **Active Directory Management** - Manage computer objects, users, groups, and permissions

## Current Capabilities

### ADComputer Class
Wrapper for Active Directory computer object management:

- **14 Properties**: ComputerName, DNSHostName, OperatingSystem, OperatingSystemVersion, DistinguishedName, Enabled, LastLogonDate, Description, Location, IPv4Address, SID, Created, Modified, MemberOf
- **10 Methods**:
  - `Get()` - Retrieve computer information from AD
  - `Enable()` / `Disable()` - Manage account state
  - `Move()` - Relocate to different OU
  - `Delete()` - Remove from AD
  - `Update()` - Apply property changes
  - `Rename()` - Rename computer object
  - `Refresh()` - Reload data from AD
  - `GetGroupMembership()` - List group memberships
  - `ToString()` - String representation

### Example Usage

```powershell
# Create and retrieve computer information
$computer = [ADComputer]::new('WORKSTATION-01')
$computer.Get()
Write-Output "OS: $($computer.OperatingSystem)"

# Manage computer accounts
$computer.Enable()
$computer.Description = 'Engineering Workstation'
$computer.Update()

# Query group membership
$groups = $computer.GetGroupMembership()
```

## Requirements

- **PowerShell**: 7.0 or higher
- **Module**: Active Directory PowerShell module (part of RSAT)
- **Permissions**: Appropriate Active Directory permissions for operations

## Installation

*Installation instructions coming soon*

## Roadmap

- [ ] ADUser class for user management
- [ ] ADGroup class for group management
- [ ] System management utilities
- [ ] Network configuration tools
- [ ] Service and process management

## Support

For issues, feature requests, or contributions, please visit the [GitHub repository](https://github.com/LaurentLienhard/PSSAK).

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please ensure:
- All code is well-documented in 4 languages
- Tests achieve 85%+ code coverage
- Code passes PSScriptAnalyzer validation
- Commit messages follow the format: `<Type>: <Subject> — <Description>`

---

**PSSAK** - Making PowerShell administration simpler, one class at a time. 🚀
