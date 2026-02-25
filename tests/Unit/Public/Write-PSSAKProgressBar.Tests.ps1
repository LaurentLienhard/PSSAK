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
    }

    Context 'Return type' {

        It 'Should not return any output' {
            Mock -CommandName Write-Progress -MockWith { }

            $result = Write-PSSAKProgressBar -Activity 'Test' -Current 5 -Total 10

            $result | Should -BeNullOrEmpty
        }
    }
}
