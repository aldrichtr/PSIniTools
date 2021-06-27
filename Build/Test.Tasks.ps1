
# synopsis: run invoke-pester on the tests in the test directory
task run_unit_tests {
    Import-Module Pester
    $PesterConfiguration = [PesterConfiguration]@{
        Run = @{
            Path     = $Path.Test
            PassThru = $true
            Exit     = $true
        }
        Filter = @{
            Tag        = $TestTags
            ExcludeTag = $ExcludeTestTags
        }
        CodeCoverage = @{
            Enabled = $false
        }
        Output = @{
            Verbosity = $TestOutput
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = 'JUnitXml'
            OutputPath   = (join-path -path $Path.Artifact -childpath "TestResults.xml")
        }
        IncludeVSCodeMarker = $true
    }

    Import-Module $Path.ModuleFile -Force -ErrorAction Stop

    $testResults = Invoke-Pester -Configuration @PesterConfiguration
}

# synopsis: generate code coverage report
task generate_coverage_report {
    Import-Module Pester
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

    Import-Module $Path.ModuleFile -Force -ErrorAction Stop

    $Coverage = Invoke-Pester -Configuration @configuration
    Write-Build Green $Coverage

}
