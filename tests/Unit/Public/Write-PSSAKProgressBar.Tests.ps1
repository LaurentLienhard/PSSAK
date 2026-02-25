BeforeAll {
    $projectPath = Join-Path -Path $PSScriptRoot -ChildPath '../../..'
    $functionPath = Join-Path -Path $projectPath -ChildPath 'source/Public/Write-PSSAKProgressBar.ps1'
    . $functionPath
}

Describe 'Write-PSSAKProgressBar - Unit Tests' {

    Context '-Completed switch' {

        It 'Should call Write-Progress with -Completed when -Completed is specified' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Completed

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $Activity -eq 'Test'
            }
        }

        It 'Should pass Id and ParentId to Write-Progress when -Completed is specified' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Completed -Id 2 -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $Id -eq 2 -and $ParentId -eq 1
            }
        }

        It 'Should not call Write-Warning when -Completed is specified without Total' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Completed

            Assert-MockCalled -CommandName Write-Warning -Times 0
        }
    }

    Context 'Input validation' {

        It 'Should emit a warning and return when Total is 0' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 0

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            Assert-MockCalled -CommandName Write-Progress -Times 0
        }

        It 'Should emit a warning and return when Total is negative' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total -10

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            Assert-MockCalled -CommandName Write-Progress -Times 0
        }

        It 'Should emit a warning and clamp Current to 0 when Current is negative' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current -5 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should emit a warning and clamp Current to Total when Current exceeds Total' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 150 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 100
            }
        }
    }

    Context 'Percentage calculation' {

        It 'Should calculate 50% when Current is half of Total' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 50
            }
        }

        It 'Should calculate 100% when Current equals Total' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 100 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should calculate 0% when Current is 0' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should compute percentage with one decimal place for non-integer fractions' {
            Mock -CommandName Write-Progress -MockWith { }

            # 1/3 * 100 = 33.333... -> rounded to 33.3
            $computed = [Math]::Round((1 / 3) * 100, 1)
            $computed | Should -Be 33.3

            # Verify the function calls Write-Progress without error for this input
            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 3
            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly
        }
    }

    Context '-Status parameter' {

        It 'Should use the provided Status text' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Status 'Processing file.txt'

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Status -eq 'Processing file.txt'
            }
        }

        It 'Should default Status to "Current / Total" when not specified' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 3 -Total 10

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Status -eq '3 / 10'
            }
        }
    }

    Context '-Id and -ParentId parameters' {

        It 'Should default Id to 0' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Id -eq 0
            }
        }

        It 'Should pass the specified Id to Write-Progress' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Id 3

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Id -eq 3
            }
        }

        It 'Should default ParentId to -1 (no parent)' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $ParentId -eq -1
            }
        }

        It 'Should pass the specified ParentId to Write-Progress' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Id 2 -ParentId 1

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $ParentId -eq 1
            }
        }
    }

    Context '-StartTime and ETA calculation' {

        It 'Should include SecondsRemaining when StartTime is provided and Current is greater than 0' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-10)

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $SecondsRemaining -gt 0
            }
        }

        It 'Should not include SecondsRemaining when Current is 0' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-5)

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when -NoTimeEstimate is specified' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-10)

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime -NoTimeEstimate

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when StartTime is not provided' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when elapsed time is 0 or less' {
            Mock -CommandName Write-Progress -MockWith { }

            # Start time in the future, so elapsed will be negative
            $futureTime = [datetime]::UtcNow.AddSeconds(10)

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $futureTime

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }

        It 'Should not include SecondsRemaining when NoTimeEstimate is true without StartTime' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -NoTimeEstimate

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }
    }

    Context 'Return type' {

        It 'Should not return any output' {
            Mock -CommandName Write-Progress -MockWith { }

            $result = Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 10

            $result | Should -BeNullOrEmpty
        }
    }

    Context 'Combined parameters' {

        It 'Should handle all parameters together: Current, Total, Status, Id, ParentId, StartTime' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-5)

            Write-PSSAKProgressBar -Activity 'TestActivity' -Current 25 -Total 100 `
                -Status 'Processing item 25' -Id 2 -ParentId 1 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Activity -eq 'TestActivity' -and
                $Status -eq 'Processing item 25' -and
                $PercentComplete -eq 25 -and
                $Id -eq 2 -and
                $ParentId -eq 1 -and
                $null -ne $SecondsRemaining
            }
        }

        It 'Should handle Status with Completed switch' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Completed -Id 1

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Completed -eq $true -and $Activity -eq 'Test' -and $Id -eq 1
            }
        }

        It 'Should correctly calculate 25% progress' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 25 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 25
            }
        }

        It 'Should correctly calculate 75% progress' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 75 -Total 100

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 75
            }
        }
    }

    Context 'Edge cases' {

        It 'Should handle Total = 1 with Current = 1' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 1

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should handle very large numbers' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 500000 -Total 1000000

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 50
            }
        }

        It 'Should warn with correct message when Total is 0' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 0

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                $Message -like '*Total must be greater than 0*' -and $Message -like '*0*'
            }
        }

        It 'Should warn with correct message when Current is negative' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current -15 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                $Message -like '*Current cannot be negative*' -and $Message -like '*-15*'
            }
        }

        It 'Should warn with correct message when Current exceeds Total' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 150 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                $Message -like '*Current*exceeds Total*' -and $Message -like '*150*' -and $Message -like '*100*'
            }
        }
    }

    Context 'Additional parameter combinations' {

        It 'Should work with Current = 0 and explicit Status' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 10 -Status 'Starting'

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 0 -and $Status -eq 'Starting'
            }
        }

        It 'Should work with Current = Total and explicit Status' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 100 -Total 100 -Status 'Complete'

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 100 -and $Status -eq 'Complete'
            }
        }

        It 'Should work with Id without ParentId' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -Id 5

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Id -eq 5 -and $ParentId -eq -1
            }
        }

        It 'Should work with ParentId without Id' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 1 -Total 10 -ParentId 2

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Id -eq 0 -and $ParentId -eq 2
            }
        }

        It 'Should work with StartTime and NoTimeEstimate together' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-10)

            Write-PSSAKProgressBar -Activity 'Test' -Current 50 -Total 100 -StartTime $startTime -NoTimeEstimate

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -eq $SecondsRemaining
            }
        }

        It 'Should have correct default Status format' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 7 -Total 14

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Status -eq '7 / 14'
            }
        }

        It 'Should not warn when Current is 0 and Total is valid' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 0 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 0
            Assert-MockCalled -CommandName Write-Progress -Times 1
        }
    }

    Context 'Parameter boundary conditions' {

        It 'Should handle Current clamp at 0 when negative with specific percentage' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current -100 -Total 500

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 0
            }
        }

        It 'Should handle Current clamp at Total when exceeds with specific percentage' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 300 -Total 200

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $PercentComplete -eq 100
            }
        }

        It 'Should include all parameters in Write-Progress call' {
            Mock -CommandName Write-Progress -MockWith { }

            Write-PSSAKProgressBar -Activity 'TestAct' -Current 30 -Total 60 -Status 'TestStatus' -Id 10 -ParentId 5

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $Activity -eq 'TestAct' -and $Status -eq 'TestStatus' -and
                $PercentComplete -eq 50 -and $Id -eq 10 -and $ParentId -eq 5
            }
        }

        It 'Should compute ETA correctly with positive elapsed time' {
            Mock -CommandName Write-Progress -MockWith { }

            $startTime = [datetime]::UtcNow.AddSeconds(-5)
            Write-PSSAKProgressBar -Activity 'Test' -Current 20 -Total 100 -StartTime $startTime

            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly -ParameterFilter {
                $null -ne $SecondsRemaining -and $SecondsRemaining -gt 0
            }
        }

        It 'Should handle negative Total same as zero Total' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total -50

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly
            Assert-MockCalled -CommandName Write-Progress -Times 0
        }

        It 'Should clamp Current to 0 before any other processing' {
            Mock -CommandName Write-Progress -MockWith { }
            Mock -CommandName Write-Warning -MockWith { }

            Write-PSSAKProgressBar -Activity 'Test' -Current -50 -Total 100

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -ParameterFilter {
                $Message -like '*negative*'
            }
            Assert-MockCalled -CommandName Write-Progress -Times 1 -Exactly
        }
    }

}
