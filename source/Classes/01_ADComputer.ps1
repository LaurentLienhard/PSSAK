<#
.SYNOPSIS
    Represents an Active Directory Computer object with methods for management and manipulation.

.DESCRIPTION
    The ADComputer class is a wrapper around Active Directory computer objects.
    It encapsulates properties and provides methods for querying, enabling, disabling,
    moving, renaming, and deleting computer objects in Active Directory.
    All methods interact directly with AD using Get-ADComputer, Set-ADComputer, and related cmdlets.

.EXAMPLE
    $computer = [ADComputer]::new('PC001')
    $computer.Get()
    $computer.Enable()

.NOTES
    Requires ActiveDirectory PowerShell module.
    Minimum PowerShell version: 7.0
#>

class ADComputer
{
    #region Properties

    [string]$ComputerName
    [string]$DNSHostName
    [string]$OperatingSystem
    [string]$OperatingSystemVersion
    [string]$DistinguishedName
    [bool]$Enabled
    [nullable[datetime]]$LastLogonDate
    [string]$Description
    [string]$Location
    [string]$IPv4Address
    [string]$SID
    [nullable[datetime]]$Created
    [nullable[datetime]]$Modified
    [System.Collections.Generic.List[string]]$MemberOf

    hidden [System.Management.Automation.PSCredential]$Credential
    hidden [string]$DomainController

    #endregion

    #region Constructors

    ADComputer([string]$Name)
    {
        $this.ComputerName = $Name
        $this.MemberOf = [System.Collections.Generic.List[string]]::new()
    }

    ADComputer([string]$Name, [System.Management.Automation.PSCredential]$Credential)
    {
        $this.ComputerName = $Name
        $this.Credential = $Credential
        $this.MemberOf = [System.Collections.Generic.List[string]]::new()
    }

    ADComputer([string]$Name, [System.Management.Automation.PSCredential]$Credential, [string]$DomainController)
    {
        $this.ComputerName = $Name
        $this.Credential = $Credential
        $this.DomainController = $DomainController
        $this.MemberOf = [System.Collections.Generic.List[string]]::new()
    }

    #endregion

    #region Methods

    <#
    .SYNOPSIS
        Retrieves the computer object from Active Directory and populates all properties.

    .DESCRIPTION
        Queries Active Directory using Get-ADComputer to fetch the current computer object
        and populates all properties of this class with the retrieved data.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Get()
    #>
    [void] Get()
    {
        $getAdParams = @{
            Identity      = $this.ComputerName
            ErrorAction   = 'Stop'
            Properties    = @(
                'ComputerName',
                'DNSHostName',
                'OperatingSystem',
                'OperatingSystemVersion',
                'DistinguishedName',
                'Enabled',
                'LastLogonDate',
                'Description',
                'Location',
                'IPv4Address',
                'ObjectSID',
                'Created',
                'Modified'
            )
        }

        if ($null -ne $this.Credential)
        {
            $getAdParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $getAdParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Retrieving computer object: $($this.ComputerName)"
            $adComputer = Get-ADComputer @getAdParams

            $this.ComputerName = $adComputer.Name
            $this.DNSHostName = $adComputer.DNSHostName
            $this.OperatingSystem = $adComputer.OperatingSystem
            $this.OperatingSystemVersion = $adComputer.OperatingSystemVersion
            $this.DistinguishedName = $adComputer.DistinguishedName
            $this.Enabled = $adComputer.Enabled
            $this.LastLogonDate = $adComputer.LastLogonDate
            $this.Description = $adComputer.Description
            $this.Location = $adComputer.Location
            $this.IPv4Address = $adComputer.IPv4Address
            $this.SID = $adComputer.ObjectSID.Value
            $this.Created = $adComputer.Created
            $this.Modified = $adComputer.Modified

            Write-Verbose -Message "Successfully retrieved computer object: $($this.ComputerName)"
        }
        catch
        {
            Write-Error -Message "Failed to retrieve computer object '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Enables the computer account in Active Directory.

    .DESCRIPTION
        Enables the computer account using Enable-ADAccount cmdlet.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Get()
        $computer.Enable()
    #>
    [void] Enable()
    {
        $enableParams = @{
            Identity    = $this.ComputerName
            ErrorAction = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $enableParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $enableParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Enabling computer account: $($this.ComputerName)"
            Enable-ADAccount @enableParams
            $this.Enabled = $true
            Write-Verbose -Message "Successfully enabled computer account: $($this.ComputerName)"
        }
        catch
        {
            Write-Error -Message "Failed to enable computer account '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Disables the computer account in Active Directory.

    .DESCRIPTION
        Disables the computer account using Disable-ADAccount cmdlet.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Get()
        $computer.Disable()
    #>
    [void] Disable()
    {
        $disableParams = @{
            Identity    = $this.ComputerName
            ErrorAction = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $disableParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $disableParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Disabling computer account: $($this.ComputerName)"
            Disable-ADAccount @disableParams
            $this.Enabled = $false
            Write-Verbose -Message "Successfully disabled computer account: $($this.ComputerName)"
        }
        catch
        {
            Write-Error -Message "Failed to disable computer account '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Moves the computer object to a different Organizational Unit.

    .DESCRIPTION
        Moves the computer object to a target OU using Move-ADObject cmdlet.

    .PARAMETER TargetOU
        The distinguished name of the target organizational unit.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Move('OU=Workstations,DC=contoso,DC=com')
    #>
    [void] Move([string]$TargetOU)
    {
        if ([string]::IsNullOrWhiteSpace($TargetOU))
        {
            throw [System.ArgumentException]::new('TargetOU cannot be null or empty', 'TargetOU')
        }

        $moveParams = @{
            Identity      = $this.DistinguishedName
            TargetPath    = $TargetOU
            ErrorAction   = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $moveParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $moveParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Moving computer '$($this.ComputerName)' to OU: $TargetOU"
            Move-ADObject @moveParams
            $this.DistinguishedName = "CN=$($this.ComputerName),$TargetOU"
            Write-Verbose -Message "Successfully moved computer '$($this.ComputerName)' to: $TargetOU"
        }
        catch
        {
            Write-Error -Message "Failed to move computer '$($this.ComputerName)' to '$TargetOU': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Deletes the computer object from Active Directory.

    .DESCRIPTION
        Removes the computer object from Active Directory using Remove-ADComputer cmdlet.
        This is a destructive operation and cannot be undone.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Delete()
    #>
    [void] Delete()
    {
        $deleteParams = @{
            Identity    = $this.ComputerName
            Confirm     = $false
            ErrorAction = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $deleteParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $deleteParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Deleting computer object: $($this.ComputerName)"
            Remove-ADComputer @deleteParams
            Write-Verbose -Message "Successfully deleted computer object: $($this.ComputerName)"
        }
        catch
        {
            Write-Error -Message "Failed to delete computer object '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Updates the computer object properties in Active Directory.

    .DESCRIPTION
        Updates the computer object in Active Directory with current property values using Set-ADComputer.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Get()
        $computer.Description = 'Updated description'
        $computer.Update()
    #>
    [void] Update()
    {
        $updateParams = @{
            Identity    = $this.ComputerName
            ErrorAction = 'Stop'
        }

        if ([string]::IsNullOrWhiteSpace($this.Description) -eq $false)
        {
            $updateParams['Description'] = $this.Description
        }

        if ([string]::IsNullOrWhiteSpace($this.Location) -eq $false)
        {
            $updateParams['Location'] = $this.Location
        }

        if ($null -ne $this.Credential)
        {
            $updateParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $updateParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Updating computer object: $($this.ComputerName)"
            Set-ADComputer @updateParams
            Write-Verbose -Message "Successfully updated computer object: $($this.ComputerName)"
        }
        catch
        {
            Write-Error -Message "Failed to update computer object '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Renames the computer object in Active Directory.

    .DESCRIPTION
        Renames the computer object using Rename-ADObject cmdlet.

    .PARAMETER NewName
        The new name for the computer object.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Rename('PC002')
    #>
    [void] Rename([string]$NewName)
    {
        if ([string]::IsNullOrWhiteSpace($NewName))
        {
            throw [System.ArgumentException]::new('NewName cannot be null or empty', 'NewName')
        }

        $renameParams = @{
            Identity    = $this.DistinguishedName
            NewName     = $NewName
            ErrorAction = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $renameParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $renameParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Renaming computer from '$($this.ComputerName)' to '$NewName'"
            Rename-ADObject @renameParams
            $this.ComputerName = $NewName
            Write-Verbose -Message "Successfully renamed computer to: $NewName"
        }
        catch
        {
            Write-Error -Message "Failed to rename computer '$($this.ComputerName)' to '$NewName': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Refreshes the computer object by re-fetching data from Active Directory.

    .DESCRIPTION
        Calls the Get() method to refresh all properties from Active Directory.
        Useful when you want to ensure you have the latest data without creating a new object.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $computer.Get()
        # ... do some operations ...
        $computer.Refresh()
    #>
    [void] Refresh()
    {
        Write-Verbose -Message "Refreshing computer object: $($this.ComputerName)"
        $this.Get()
    }

    <#
    .SYNOPSIS
        Retrieves all group memberships for the computer object.

    .DESCRIPTION
        Returns a list of groups that the computer object is a member of using Get-ADPrincipalGroupMembership.

    .OUTPUTS
        System.Collections.Generic.List[string]
        A list of group distinguished names.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        $groups = $computer.GetGroupMembership()
        $groups | ForEach-Object { Write-Output $_ }
    #>
    [System.Collections.Generic.List[string]] GetGroupMembership()
    {
        $this.MemberOf = [System.Collections.Generic.List[string]]::new()

        $groupParams = @{
            Identity    = $this.ComputerName
            ErrorAction = 'Stop'
        }

        if ($null -ne $this.Credential)
        {
            $groupParams['Credential'] = $this.Credential
        }

        if ($null -ne $this.DomainController)
        {
            $groupParams['Server'] = $this.DomainController
        }

        try
        {
            Write-Verbose -Message "Retrieving group membership for computer: $($this.ComputerName)"
            $groups = Get-ADPrincipalGroupMembership @groupParams

            foreach ($group in $groups)
            {
                $this.MemberOf.Add($group.DistinguishedName)
            }

            Write-Verbose -Message "Successfully retrieved $($this.MemberOf.Count) group memberships for: $($this.ComputerName)"
            return $this.MemberOf
        }
        catch
        {
            Write-Error -Message "Failed to retrieve group membership for computer '$($this.ComputerName)': $($_.Exception.Message)"
            throw
        }
    }

    <#
    .SYNOPSIS
        Returns a string representation of the computer object.

    .DESCRIPTION
        Returns the computer name as the string representation of this object.

    .OUTPUTS
        System.String
        The computer name.

    .EXAMPLE
        $computer = [ADComputer]::new('PC001')
        [string]$name = $computer.ToString()
    #>
    [string] ToString()
    {
        return $this.ComputerName
    }

    #endregion
}
