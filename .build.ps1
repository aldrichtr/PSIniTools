
param(
    # BuildRoot is automatically set by Invoke-Build, but it could be
    # modified here so that hierarchical builds can be done
    [Parameter()]
    [string]
    $BuildRoot = $BuildRoot,

    # The name of this module, used in many directory and file names
    [Parameter()]
    [string]
    $ModuleName = 'PSIniTools',

    # Define tests to be run
    [Parameter()]
    [Alias("Tests")]
    [string[]]$TestTags = "*",

    # Define tests to be excluded
    [Parameter()]
    [Alias("Exclude")]
    [string[]]$ExcludeTestTags = @("ignore", "exclude"),

    # Test output verbosity
    [Parameter()]
    [ValidateSet("None", "Minimal", "Normal", "Detailed", "Diagnostic")]
    [string]$TestOutput = "Normal",

    # Default directory conventions here, all based on BuildRoot
    [Parameter()]
    [Hashtable]
    $Path = @{
        "Staging"        = "$BuildRoot\stage\$ModuleName"
        "Tools"          = "$BuildRoot\tools"
        "Source"         = "$BuildRoot\$ModuleName"
        "Test"           = "$BuildRoot\tests"
        "Build"          = "$BuildRoot\build"
        "BuildOutput"    = "$BuildRoot\artifact"
        "Artifact"       = "$BuildRoot\artifact"
        "ModuleFile"     = "$BuildRoot\stage\$ModuleName\$ModuleName.psm1"
        "ModuleManifest" = "$BuildRoot\stage\$ModuleName\$ModuleName.psd1"

    },

    # Build Type
    [Parameter()]
    [ValidateSet("Testing", "Debug", "Release")]
    [string]
    $Type = "Testing",

    # Increment the Version field
    [Parameter()]
    [ValidateSet("Major", "Minor", "Build")]
    [string]
    $VersionIncrement = "Build"
)

Get-ChildItem -Path $Path.Build -Filter "*.Tasks.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}

# synopsis: Setup the project and tools
task Configure {
    Write-Build Blue "Configuring the $ModuleName project"
},
create_project_subdirectories,
install_developer_modules,
add_developer_tools

task Stage {
    Write-Build Blue "Create a local module"
},
write_file_header,
copy_source_content_to_psm1,
update_exported_functions

# synopsis: Remove any generated files or build artifacts
task Clean {
    Write-Build Blue "Cleaning the project"
},
remove_artifact_files,
remove_staging_files,
remove_temp_repository

# synopsis: Validate code quality
task Test {
    Write-Build Blue "Testing $ModuleName"
},
Clean,
Stage,
run_unit_tests

# synopsis: Create a nupkg file from the source files
task Build {
    Write-Build Blue "Beginning the build of $ModuleName. Build type: $Type"
},
Clean,
Stage,
update_manifest_version,
find_changed_files,
register_local_artifact_repository,
publish_to_temp_repository,
remove_temp_repository,
publish_to_gitlab_feed



# Invoke-Build will Stage by default
task . Stage

