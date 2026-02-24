BeforeAll {
    # Load from source to ensure the class is properly initialized
    $projectPath = Join-Path -Path $PSScriptRoot -ChildPath '../../..'
    $sourcePath = Join-Path -Path $projectPath -ChildPath 'source/Classes'
    $classPath = Join-Path -Path $sourcePath -ChildPath '01_ADComputer.ps1'
    . $classPath
}

Describe 'ADComputer Class - Unit Tests' {

    Context 'Constructors' {

        It 'Should create an ADComputer instance with ComputerName only' {
            $computer = [ADComputer]::new('PC001')

            $computer.ComputerName | Should -Be 'PC001'
            $computer.Credential | Should -BeNullOrEmpty
            $computer.DomainController | Should -BeNullOrEmpty
            $computer.MemberOf | Should -BeOfType [System.Collections.Generic.List[string]]
            $computer.MemberOf.Count | Should -Be 0
        }

        It 'Should create an ADComputer instance with ComputerName and Credential' {
            $credential = [System.Management.Automation.PSCredential]::new('user', (ConvertTo-SecureString 'pass' -AsPlainText -Force))
            $computer = [ADComputer]::new('PC001', $credential)

            $computer.ComputerName | Should -Be 'PC001'
            $computer.Credential | Should -Not -BeNullOrEmpty
            $computer.Credential.UserName | Should -Be 'user'
            $computer.MemberOf | Should -BeOfType [System.Collections.Generic.List[string]]
        }

        It 'Should create an ADComputer instance with ComputerName, Credential, and DomainController' {
            $credential = [System.Management.Automation.PSCredential]::new('user', (ConvertTo-SecureString 'pass' -AsPlainText -Force))
            $computer = [ADComputer]::new('PC001', $credential, 'DC01.contoso.com')

            $computer.ComputerName | Should -Be 'PC001'
            $computer.Credential | Should -Not -BeNullOrEmpty
            $computer.DomainController | Should -Be 'DC01.contoso.com'
            $computer.MemberOf | Should -BeOfType [System.Collections.Generic.List[string]]
        }
    }

    Context 'Get() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
        }

        It 'Should populate properties when Get-ADComputer succeeds' {
            $mockADComputer = @{
                Name                   = 'PC001'
                DNSHostName            = 'PC001.contoso.com'
                OperatingSystem        = 'Windows 10 Enterprise'
                OperatingSystemVersion = '10.0 (22H2)'
                DistinguishedName      = 'CN=PC001,OU=Workstations,DC=contoso,DC=com'
                Enabled                = $true
                LastLogonDate          = [datetime]::new(2024, 1, 15)
                Description            = 'Test PC'
                Location               = 'Building A'
                IPv4Address            = '192.168.1.100'
                ObjectSID              = [psobject]@{ Value = 'S-1-5-21-3623811015-3361044348-30300820-1013' }
                Created                = [datetime]::new(2023, 1, 1)
                Modified               = [datetime]::new(2024, 1, 10)
            }

            Mock -CommandName Get-ADComputer -MockWith { return $mockADComputer }

            $computer.Get()

            $computer.ComputerName | Should -Be 'PC001'
            $computer.DNSHostName | Should -Be 'PC001.contoso.com'
            $computer.OperatingSystem | Should -Be 'Windows 10 Enterprise'
            $computer.OperatingSystemVersion | Should -Be '10.0 (22H2)'
            $computer.DistinguishedName | Should -Be 'CN=PC001,OU=Workstations,DC=contoso,DC=com'
            $computer.Enabled | Should -Be $true
            $computer.LastLogonDate | Should -Be ([datetime]::new(2024, 1, 15))
            $computer.Description | Should -Be 'Test PC'
            $computer.Location | Should -Be 'Building A'
            $computer.IPv4Address | Should -Be '192.168.1.100'
            $computer.SID | Should -Be 'S-1-5-21-3623811015-3361044348-30300820-1013'
            $computer.Created | Should -Be ([datetime]::new(2023, 1, 1))
            $computer.Modified | Should -Be ([datetime]::new(2024, 1, 10))

            Assert-MockCalled -CommandName Get-ADComputer -Times 1 -Exactly
        }

        It 'Should pass Credential and Server parameters when provided' {
            $credential = [System.Management.Automation.PSCredential]::new('user', (ConvertTo-SecureString 'pass' -AsPlainText -Force))
            $computerWithCreds = [ADComputer]::new('PC001', $credential, 'DC01.contoso.com')

            Mock -CommandName Get-ADComputer -MockWith { return @{ Name = 'PC001'; Enabled = $true } }

            $computerWithCreds.Get()

            Assert-MockCalled -CommandName Get-ADComputer -Times 1 -Exactly -ParameterFilter {
                $Server -eq 'DC01.contoso.com'
            }
        }

        It 'Should throw an error when Get-ADComputer fails' {
            Mock -CommandName Get-ADComputer -MockWith { throw [System.Management.Automation.ItemNotFoundException]::new('Object not found') }

            { $computer.Get() } | Should -Throw
        }
    }

    Context 'Enable() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
            $computer.Enabled = $false
        }

        It 'Should enable the computer account' {
            Mock -CommandName Enable-ADAccount -MockWith { }

            $computer.Enable()

            $computer.Enabled | Should -Be $true
            Assert-MockCalled -CommandName Enable-ADAccount -Times 1 -Exactly
        }

        It 'Should throw an error when Enable-ADAccount fails' {
            Mock -CommandName Enable-ADAccount -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Enable() } | Should -Throw
        }
    }

    Context 'Disable() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
            $computer.Enabled = $true
        }

        It 'Should disable the computer account' {
            Mock -CommandName Disable-ADAccount -MockWith { }

            $computer.Disable()

            $computer.Enabled | Should -Be $false
            Assert-MockCalled -CommandName Disable-ADAccount -Times 1 -Exactly
        }

        It 'Should throw an error when Disable-ADAccount fails' {
            Mock -CommandName Disable-ADAccount -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Disable() } | Should -Throw
        }
    }

    Context 'Move() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
            $computer.DistinguishedName = 'CN=PC001,OU=OldOU,DC=contoso,DC=com'
        }

        It 'Should move the computer to a target OU' {
            $targetOU = 'OU=NewOU,DC=contoso,DC=com'
            Mock -CommandName Move-ADObject -MockWith { }

            $computer.Move($targetOU)

            Assert-MockCalled -CommandName Move-ADObject -Times 1 -Exactly -ParameterFilter {
                $TargetPath -eq $targetOU
            }
        }

        It 'Should throw ArgumentException when TargetOU is null' {
            { $computer.Move($null) } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'Should throw ArgumentException when TargetOU is empty' {
            { $computer.Move('') } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'Should throw an error when Move-ADObject fails' {
            Mock -CommandName Move-ADObject -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Move('OU=NewOU,DC=contoso,DC=com') } | Should -Throw
        }
    }

    Context 'Delete() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
        }

        It 'Should delete the computer object' {
            Mock -CommandName Remove-ADComputer -MockWith { }

            $computer.Delete()

            Assert-MockCalled -CommandName Remove-ADComputer -Times 1 -Exactly -ParameterFilter {
                $Confirm -eq $false
            }
        }

        It 'Should throw an error when Remove-ADComputer fails' {
            Mock -CommandName Remove-ADComputer -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Delete() } | Should -Throw
        }
    }

    Context 'Update() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
            $computer.Description = 'Updated description'
            $computer.Location = 'Building B'
        }

        It 'Should update the computer object with Description and Location' {
            Mock -CommandName Set-ADComputer -MockWith { }

            $computer.Update()

            Assert-MockCalled -CommandName Set-ADComputer -Times 1 -Exactly -ParameterFilter {
                $Description -eq 'Updated description' -and $Location -eq 'Building B'
            }
        }

        It 'Should throw an error when Set-ADComputer fails' {
            Mock -CommandName Set-ADComputer -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Update() } | Should -Throw
        }
    }

    Context 'Rename() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
            $computer.DistinguishedName = 'CN=PC001,OU=Workstations,DC=contoso,DC=com'
        }

        It 'Should rename the computer object' {
            Mock -CommandName Rename-ADObject -MockWith { }

            $computer.Rename('PC002')

            $computer.ComputerName | Should -Be 'PC002'
            Assert-MockCalled -CommandName Rename-ADObject -Times 1 -Exactly -ParameterFilter {
                $NewName -eq 'PC002'
            }
        }

        It 'Should throw ArgumentException when NewName is null' {
            { $computer.Rename($null) } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'Should throw ArgumentException when NewName is empty' {
            { $computer.Rename('') } | Should -Throw -ExceptionType ([System.ArgumentException])
        }

        It 'Should throw an error when Rename-ADObject fails' {
            Mock -CommandName Rename-ADObject -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.Rename('PC002') } | Should -Throw
        }
    }

    Context 'Refresh() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
        }

        It 'Should call Get() to refresh properties' {
            $mockADComputer = @{
                Name                   = 'PC001'
                DNSHostName            = 'PC001.contoso.com'
                OperatingSystem        = 'Windows 10 Enterprise'
                OperatingSystemVersion = '10.0 (22H2)'
                DistinguishedName      = 'CN=PC001,OU=Workstations,DC=contoso,DC=com'
                Enabled                = $true
                LastLogonDate          = [datetime]::new(2024, 1, 15)
                Description            = 'Test PC'
                Location               = 'Building A'
                IPv4Address            = '192.168.1.100'
                ObjectSID              = [psobject]@{ Value = 'S-1-5-21-3623811015-3361044348-30300820-1013' }
                Created                = [datetime]::new(2023, 1, 1)
                Modified               = [datetime]::new(2024, 1, 10)
            }

            Mock -CommandName Get-ADComputer -MockWith { return $mockADComputer }

            $computer.Refresh()

            $computer.ComputerName | Should -Be 'PC001'
            $computer.Enabled | Should -Be $true
            Assert-MockCalled -CommandName Get-ADComputer -Times 1 -Exactly
        }
    }

    Context 'GetGroupMembership() Method' {

        BeforeEach {
            $computer = [ADComputer]::new('PC001')
        }

        It 'Should retrieve and populate group membership' {
            $mockGroups = @(
                [psobject]@{ DistinguishedName = 'CN=Group1,OU=Groups,DC=contoso,DC=com' },
                [psobject]@{ DistinguishedName = 'CN=Group2,OU=Groups,DC=contoso,DC=com' }
            )

            Mock -CommandName Get-ADPrincipalGroupMembership -MockWith { return $mockGroups }

            $result = $computer.GetGroupMembership()

            $result.Count | Should -Be 2
            $result[0] | Should -Be 'CN=Group1,OU=Groups,DC=contoso,DC=com'
            $result[1] | Should -Be 'CN=Group2,OU=Groups,DC=contoso,DC=com'
            Assert-MockCalled -CommandName Get-ADPrincipalGroupMembership -Times 1 -Exactly
        }

        It 'Should throw an error when Get-ADPrincipalGroupMembership fails' {
            Mock -CommandName Get-ADPrincipalGroupMembership -MockWith { throw [System.UnauthorizedAccessException]::new('Access denied') }

            { $computer.GetGroupMembership() } | Should -Throw
        }

        It 'Should return empty list when computer has no group memberships' {
            Mock -CommandName Get-ADPrincipalGroupMembership -MockWith { return @() }

            $result = $computer.GetGroupMembership()

            $result.Count | Should -Be 0
        }
    }

    Context 'ToString() Method' {

        It 'Should return the ComputerName' {
            $computer = [ADComputer]::new('PC001')

            $result = $computer.ToString()

            $result | Should -Be 'PC001'
        }
    }

    Context 'Property Initialization' {

        It 'Should initialize MemberOf as a List[string]' {
            $computer = [ADComputer]::new('PC001')

            $computer.MemberOf | Should -BeOfType [System.Collections.Generic.List[string]]
            $computer.MemberOf.Count | Should -Be 0
        }

        It 'Should have null/empty string properties initially' {
            $computer = [ADComputer]::new('PC001')

            $computer.DNSHostName | Should -BeNullOrEmpty
            $computer.OperatingSystem | Should -BeNullOrEmpty
            $computer.Description | Should -BeNullOrEmpty
            $computer.Location | Should -BeNullOrEmpty
            $computer.IPv4Address | Should -BeNullOrEmpty
            $computer.SID | Should -BeNullOrEmpty
        }
    }
}
