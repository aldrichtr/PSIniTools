
# synopsis: run invoke-pester on the tests in the test directory
task run_unit_tests {
    $BuildConfig = Get-BuildConfiguration

    $PesterConfiguration = [PesterConfiguration]@{
        Run = @{
            Path     = $Path.Test
            PassThru = $true
            Exit     = $true
        }
        Filter = @{
            ExcludeTag = @("ignore","broken")
        }
        CodeCoverage = @{
            Enabled = $false
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = 'JUnitXml'
            OutputPath   = (join-path -path $Path.Artifact -childpath "TestResults.xml")
        }
        IncludeVSCodeMarker = $true
    }

    $testResults = Invoke-Pester -Configuration @PesterConfiguration
}

# synopsis: generate code coverage report
task generate_coverage_report {
    $configuration = [PesterConfiguration]@{
        Run = @{
            Path     = $Path.Test
            PassThru = $true
        }
        CodeCoverage = @{
            Enabled  = $true
            Path     = $Path.Source
            OutputFormat = "JaCoCo"
            OutputPath   = (Join-Path -Path $Path.BuildOutput -ChildPath "TestCoverage.xml")
            OutputEncoding = "UTF8"
            ExcludeTests   = $true
        }
        Output = @{
            Verbosity = 'Normal'
        }
        TestResult = @{
            Enabled = $false
        }
        IncludeVSCodeMarker = $true
    }

    $Coverage = Invoke-Pester -Configuration @configuration
    Write-Build Green $Coverage

}
