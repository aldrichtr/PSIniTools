

# synopsis: Update the exported functions using the names of the files in the Public folder
task update_exported_functions {
    $target_psd = Join-Path -Path $Path.Staging -ChildPath "$ModuleName.psd1"

    if (-not (Test-Path $target_psd)) {
        Write-Build Yellow "Staging the Manifest file"
        Copy-Item -Path (Join-Path -Path $Path.Source -ChildPath "$ModuleName.psd1") -Destination $target_psd
    }

    # This relies on the convention of naming the file with the function name
    [string[]] $exports = ( Get-ChildItem -Path "$( $Path.Source )\Public" -File -Filter "*.ps1" -Recurse ).BaseName

    Set-ModuleFunctions -Name $target_psd -FunctionsToExport $exports
}

task find_changed_files {
    Write-Build Yellow "- Finding previous released module version"
    [string] $diffBranch = switch -Regex ( git tag -l --sort=-version:refname "v*"  ) {
        '^v(\d+\.\d+\.\d+.\d+)$' {
            $Matches[0]

            break
        }
        DEFAULT {
            git rev-list --max-parents=0 HEAD
        }
    }
    Write-Build Yellow "- Diff'ing current location against $diffBranch"

    [string[]] $script:ChangedFiles = @( git diff "$diffBranch" --name-only --diff-filter=d ) | ForEach-Object {
        [string] $filePath = $PSItem
        [string] $fileFilterRegex = "(Private|Public|Diagnostics)(\/|\\).+(?<!build|variables|$moduleName)\.ps1$"

        Write-Host -NoNewline -ForegroundColor DarkGray " - $filePath : "
        if ( $filePath -match $fileFilterRegex ) {
            Write-Host -ForegroundColor Green "+ Added for analysis"
            $filePath
        }
        else {
            Write-Host -ForegroundColor DarkGray "~ Filtered"
        }
    }
    Write-Build DarkGray "#### Filtered file names using regex: $fileFilterRegex"
    Write-Build Yellow "- $( @( $script:ChangedFiles ).count ) files changed"
}
# synopsis: Update the version field in the manifest
task update_manifest_version {
    # Major.Minor.Revision.Build
    # feature updates Minor
    # bugfix updates Revision
    # every build updates Build (local, CI)
    # Major is only manual based on "breaking changes"

    [System.IO.FileInfo] $target_psd = Join-Path -Path $Path.Staging -ChildPath "$ModuleName.psd1"

    if (-not ( Test-Path $target_psd.FullName ) ) {
        Write-Build Yellow "Staging the Manifest file"
        Copy-Item -Path ( Join-Path -Path $Path.Source -ChildPath "$ModuleName.psd1" ) -Destination $target_psd.FullName
    }

    [string]$gitLog = git log --pretty=format:"%s" --merges -n 1

    Write-Build Yellow "- Discovering previous branch name"

    if ( [regex]::IsMatch( $gitLog, "Merge branch \'(.+?)\' into" ) ) {
        [string]$fromBranch = [regex]::Match( $gitLog, "Merge branch \'(.+?)\' into" ).Groups[1].Value
    }
    else {
        [string]$fromBranch = $env:CI_COMMIT_BRANCH
        $PreRelease = $true
    }

    Write-Build Yellow "- Using Branch Name: $fromBranch"

    #Parses the CHANGELOG.MD to get the base version string
    [version]$moduleVersion = switch -Regex ( git tag -l --sort=-version:refname "v*"  ) {
        '^v(\d+\.\d+\.\d+.\d+)$' {
            [version]::Parse( $Matches[1] )

            break
        }
        default {
            [version]::Parse( 'v0.0.0.1' )
        }
    }
    Write-Build Yellow "- Current Module Version Tag is: $moduleVersion"

    $Matches.Clear()

    #If an online build, then use the build ID otherwise the number of commits in the branch
    $Script:ModuleRevisionNumber = $(
        if ( $env:BUILD_NUMBER ) {
            Write-Host "- Using environment Build Number $env:BUILD_NUMBER"
            $env:BUILD_NUMBER
        }
        else {
            git rev-list HEAD --count
        }
    )
    [int] $majorVersion = $moduleVersion.Major
    [int] $minorVersion = $moduleVersion.Minor
    [int] $buildVersion = $moduleVersion.Build

    switch -Regex ( $fromBranch ) {
        '(?i)^release' {
            $majorVersion++
            Write-Build Yellow "- Release branch type, increasing major version to: $majorVersion"
        }
        '(?i)^feature' {
            $minorVersion++
            Write-Build Yellow "- Feature branch type, increasing minor version to: $minorVersion"
        }
        '(?i)^bugfix' {
            $buildVersion++
            Write-Build Yellow "- Bugfix branch type, increasing buildVersion version to: $buildVersion"
        }
        '(?i)^hotfix' {
            $buildVersion++
            Write-Build Yellow "- Hotfix branch type, increasing buildVersion version to: $buildVersion"
        }
        default {
            $Script:SkipTag = $true
            Write-Build magenta " - Not a standard branch. Rev of module version not possible. Use standard branch names: release = Major, feature = Minor, bugfix = Build, hotfix = Build."
        }
    }
    # This will be the [System.Version] ( i.e. 3.4.0.115 )
    $Script:ModuleVersion = [version]::Parse( [string]::Format( '{0}.{1}.{2}.{3}', $majorVersion, $minorVersion, $buildVersion, $Script:ModuleRevisionNumber ) )

    Write-Build Yellow "- Using ModuleVersion number: ( $( $Script:ModuleVersion.ToString() ) )"

    $newContent = ( Get-Content -Path $target_psd.FullName ) -replace "(\s*ModuleVersion\s*\=\s*)('[0-9]{1,2}.[0-9]{1,2}.[0-9]{1,2}(.[0-9]{1,7}){0,1}')\s*$", "`${1}'$( $Script:ModuleVersion.ToString( 4 ) )'" -replace "(\s*BuildNumber\s*\=\s*)('0')\s*$", "`${1}'$( $Script:ModuleRevisionNumber )'"

    if ( $IsPreRelease.IsPresent ) {
        $newContent = $newContent -replace "(\s*Prerelease\s*\=\s*)('')\s*$", "`${1}'build$RevisionNumber'"
    }
    [System.IO.File]::WriteAllLines( $target_psd.FullName, $newContent, [System.Text.UTF8Encoding]::new( $false ) )
}