BeforeAll {
    $projectPath = Join-Path -Path $PSScriptRoot -ChildPath '../../..'
    $functionPath = Join-Path -Path $projectPath -ChildPath 'source/Public/Write-PSSAKProgressBar.ps1'
    . $functionPath
}

Describe 'Write-PSSAKProgressBar' {

    Context 'Completed parameter behavior' {

        It 'Should call Write-Progress with Completed switch when specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Completed

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $Activity -eq 'Test'
            }
        }

        It 'Should pass Id when Completed and Id specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Completed -Id 2

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $Id -eq 2
            }
        }

        It 'Should pass ParentId when Completed and ParentId specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Completed -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $ParentId -eq 1
            }
        }

        It 'Should return early when Completed without processing Current/Total' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Completed -Current 999 -Total 0

            Assert-MockCalled -CommandName Write-Warning -Times 0
            Assert-MockCalled -CommandName Write-Progress -Times 1
        }
    }

    Context 'Total parameter validation' {

        It 'Should warn and return when Total is 0' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 0

            Assert-MockCalled -CommandName Write-Warning -Times 1
            Assert-MockCalled -CommandName Write-Progress -Times 0
        }

        It 'Should warn with correct message when Total is 0' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 0

            Assert-MockCalled -CommandName Write-Warning -Times 1 -ParameterFilter {
                $Message -like '*Total must be greater than 0*'
            }
        }

        It 'Should warn and return when Total is negative' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total -10

            Assert-MockCalled -CommandName Write-Warning -Times 1
            Assert-MockCalled -CommandName Write-Progress -Times 0
        }
    }

    Context 'Current parameter validation' {

        It 'Should warn and clamp Current to 0 when negative' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current -5 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -ParameterFilter {
                $Message -like '*cannot be negative*'
            }
            Assert-MockCalled -CommandName Write-Progress -Times 1 -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should warn and clamp Current to Total when exceeds' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 150 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -ParameterFilter {
                $Message -like '*exceeds Total*'
            }
            Assert-MockCalled -CommandName Write-Progress -Times 1 -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should allow Current = 0 without warning' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 0
            Assert-MockCalled -CommandName Write-Progress -Times 1
        }
    }

    Context 'Percentage calculation' {

        It 'Should calculate 0% when Current is 0' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should calculate 50% when Current is 50 and Total is 100' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 50
            }
        }

        It 'Should calculate 25% when Current is 25 and Total is 100' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 25 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 25
            }
        }

        It 'Should calculate 100% when Current equals Total' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 100 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should calculate 75% when Current is 75 and Total is 100' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 75 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 75
            }
        }

        It 'Should handle large numbers correctly' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 500000 -Total 1000000

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 50
            }
        }
    }

    Context 'Status parameter' {

        It 'Should use custom Status when provided' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Status 'Processing file.txt'

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Status -eq 'Processing file.txt'
            }
        }

        It 'Should default to "Current / Total" format when Status not specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 3 -Total 10

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Status -eq '3 / 10'
            }
        }

        It 'Should default to "0 / 100" when Current and Total default to 0' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Status -eq '0 / 100'
            }
        }

        It 'Should use Status with clamped Current value' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 150 -Total 100 -Status 'Complete'

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Status -eq 'Complete'
            }
        }
    }

    Context 'Id and ParentId parameters' {

        It 'Should default Id to 0' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Id -eq 0
            }
        }

        It 'Should use custom Id when specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Id 3

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Id -eq 3
            }
        }

        It 'Should default ParentId to -1' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $ParentId -eq -1
            }
        }

        It 'Should use custom ParentId when specified' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $ParentId -eq 1
            }
        }

        It 'Should support nested progress bars with Id and ParentId' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Child' -Current 1 -Total 10 -Id 2 -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Id -eq 2 -and $ParentId -eq 1
            }
        }
    }

    Context 'StartTime and ETA calculation' {

        It 'Should include SecondsRemaining when StartTime and Current > 0' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-10)
            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $null -ne $SecondsRemaining -and $SecondsRemaining -gt 0
            }
        }

        It 'Should not include SecondsRemaining when Current is 0 with StartTime' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-5)
            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                -not $PSBoundParameters.ContainsKey('SecondsRemaining') -or $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when NoTimeEstimate is true' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-10)
            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime -NoTimeEstimate

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                -not $PSBoundParameters.ContainsKey('SecondsRemaining') -or $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when StartTime not provided' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                -not $PSBoundParameters.ContainsKey('SecondsRemaining') -or $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when elapsed time is not positive' {
            Mock -CommandName Write-Progress

            $futureTime = [datetime]::UtcNow.AddSeconds(10)
            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $futureTime

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                -not $PSBoundParameters.ContainsKey('SecondsRemaining') -or $null -eq $SecondsRemaining
            }
        }
    }

    Context 'Output behavior' {

        It 'Should not return any output' {
            Mock -CommandName Write-Progress

            $result = Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 10

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Complex scenarios' {

        It 'Should handle all parameters together' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-5)
            Write-PSSAKProgressBar -Activity 'TestActivity' -Current 25 -Total 100 `
                -Status 'Processing item 25' -Id 2 -ParentId 1 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Activity -eq 'TestActivity' -and
                $Status -eq 'Processing item 25' -and
                $PercentComplete -eq 25 -and
                $Id -eq 2 -and
                $ParentId -eq 1 -and
                $null -ne $SecondsRemaining
            }
        }

        It 'Should handle edge case: Total = 1' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 1

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should handle Current clamping and custom Status together' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 150 -Total 100 -Status 'Finalizing'

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 100 -and $Status -eq 'Finalizing'
            }
        }

        It 'Should handle StartTime with NoTimeEstimate together' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-10)
            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime -NoTimeEstimate

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                -not $PSBoundParameters.ContainsKey('SecondsRemaining') -or $null -eq $SecondsRemaining
            }
        }

        It 'Should warn and still progress when Current is negative' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current -100 -Total 500

            Assert-MockCalled -CommandName Write-Warning -Times 1
            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should use all default values correctly' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Activity -eq 'Test' -and
                $Id -eq 0 -and
                $ParentId -eq -1
            }
        }

        It 'Should calculate Status correctly when neither Current nor Total provided' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Status -eq '0 / 100'
            }
        }

        It 'Should handle Completed with nested progress bar setup' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Child' -Current 5 -Total 10 -Id 2 -ParentId 1
            Write-PSSAKProgressBar -Activity 'Child' -Completed -Id 2 -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -Times 2
        }

        It 'Should compute ETA when exactly 25% complete' {
            Mock -CommandName Write-Progress

            $startTime = [datetime]::UtcNow.AddSeconds(-10)
            Write-PSSAKProgressBar -Activity 'Test' -Current 25 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 25 -and $null -ne $SecondsRemaining
            }
        }

        It 'Should handle various percentage values' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Test' -Current 10 -Total 40

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $PercentComplete -eq 25
            }
        }

        It 'Should pass Activity parameter correctly to Write-Progress' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'CustomActivity' -Current 1 -Total 2

            Assert-MockCalled -CommandName Write-Progress -ParameterFilter {
                $Activity -eq 'CustomActivity'
            }
        }

        It 'Should work with minimum parameters' {
            Mock -CommandName Write-Progress

            Write-PSSAKProgressBar -Activity 'Min' -Current 1 -Total 2

            Assert-MockCalled -CommandName Write-Progress -Times 1
        }

        It 'Should warn once for negative Current' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current -1 -Total 10

            Assert-MockCalled -CommandName Write-Warning -Times 1
        }

        It 'Should warn once for Total <= 0' {
            Mock -CommandName Write-Progress
            Mock -CommandName Write-Warning

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total -1

            Assert-MockCalled -CommandName Write-Warning -Times 1
        }
    }

}
