function Write-PSSAKProgressBar
{
    <#
    .SYNOPSIS
        Displays a progress bar with optional ETA calculation.

    .DESCRIPTION
        Wraps Write-Progress to provide automatic percentage calculation, optional
        estimated time remaining (ETA) based on a provided start time, and support
        for nested progress bars via the Id and ParentId parameters.

        Call this function on each iteration of a loop, then call it again with
        -Completed when the operation finishes to close the bar cleanly.

    .PARAMETER Activity
        The title displayed above the progress bar.

    .PARAMETER Current
        The current item index (1-based). Must be between 1 and Total.

    .PARAMETER Total
        The total number of items to process. Must be greater than 0.

    .PARAMETER Status
        Optional text displayed below the progress bar.
        Defaults to 'Current / Total' when not specified.

    .PARAMETER Id
        The identifier of this progress bar. Used to display multiple nested bars.
        Defaults to 0.

    .PARAMETER ParentId
        The identifier of the parent progress bar for nested display.
        Defaults to -1 (no parent).

    .PARAMETER StartTime
        The datetime when the operation started. When provided, the function
        calculates and displays the estimated time remaining (ETA).

    .PARAMETER Completed
        When specified, closes the progress bar. Use this at the end of a loop.
        Only -Activity and -Id are used when -Completed is specified.

    .PARAMETER NoTimeEstimate
        When specified, suppresses the ETA display even if -StartTime is provided.

    .OUTPUTS
        None. This function does not return any output.

    .EXAMPLE
        $files = Get-ChildItem -Path C:\Logs
        $start = [datetime]::UtcNow
        $i = 0
        foreach ($file in $files)
        {
            $i++
            Write-PSSAKProgressBar -Activity 'Processing log files' -Current $i -Total $files.Count -Status $file.Name -StartTime $start
        }
        Write-PSSAKProgressBar -Activity 'Processing log files' -Completed

        Displays a progress bar with ETA while iterating over files.

    .EXAMPLE
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

        Displays two nested progress bars.

    .EXAMPLE
        Write-PSSAKProgressBar -Activity 'Importing data' -Current 50 -Total 200 -NoTimeEstimate

        Displays a progress bar at 25% without ETA.
    #>

    [CmdletBinding()]
    [OutputType([void])]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Activity,

        [Parameter()]
        [int]$Current = 0,

        [Parameter()]
        [int]$Total = 0,

        [Parameter()]
        [string]$Status,

        [Parameter()]
        [int]$Id = 0,

        [Parameter()]
        [int]$ParentId = -1,

        [Parameter()]
        [datetime]$StartTime,

        [Parameter()]
        [switch]$Completed,

        [Parameter()]
        [switch]$NoTimeEstimate
    )

    BEGIN {}

    PROCESS
    {
        if ($Completed)
        {
            $completedParams = @{
                Activity  = $Activity
                Id        = $Id
                ParentId  = $ParentId
                Completed = $true
            }

            Write-Progress @completedParams
            return
        }

        if ($Total -le 0)
        {
            Write-Warning -Message "Write-PSSAKProgressBar: Total must be greater than 0. Received: $Total"
            return
        }

        if ($Current -lt 0)
        {
            Write-Warning -Message "Write-PSSAKProgressBar: Current cannot be negative. Received: $Current"
            $Current = 0
        }

        if ($Current -gt $Total)
        {
            Write-Warning -Message "Write-PSSAKProgressBar: Current ($Current) exceeds Total ($Total). Clamping to Total."
            $Current = $Total
        }

        $percentComplete = [Math]::Round(($Current / $Total) * 100, 1)

        if ($PSBoundParameters.ContainsKey('Status'))
        {
            $statusText = $Status
        }
        else
        {
            $statusText = "$Current / $Total"
        }

        $writeProgressParams = @{
            Activity        = $Activity
            Status          = $statusText
            PercentComplete = $percentComplete
            Id              = $Id
            ParentId        = $ParentId
        }

        if ($PSBoundParameters.ContainsKey('StartTime') -and -not $NoTimeEstimate -and $Current -gt 0)
        {
            $elapsed = ([datetime]::UtcNow - $StartTime).TotalSeconds

            if ($elapsed -gt 0)
            {
                $rate = $Current / $elapsed
                $secondsRemaining = ($Total - $Current) / $rate
                $writeProgressParams['SecondsRemaining'] = [Math]::Round($secondsRemaining)
            }
        }

        Write-Progress @writeProgressParams
    }

    END {}
}
