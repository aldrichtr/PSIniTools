
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

    # Default directory conventions here, all based on BuildRoot
    [Parameter()]
    [Hashtable]
    $Path = @{
        "Staging"     = "$BuildRoot\stage\$ModuleName"
        "Tools"       = "$BuildRoot\stage\tools"
        "Source"      = "$BuildRoot\$ModuleName"
        "Test"        = "$BuildRoot\tests"
        "Build"       = "$BuildRoot\build"
        "BuildOutput" = "$BuildRoot\artifact"
        "Artifact"    = "$BuildRoot\artifact"
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

# synopsis: Create a nupkg file from the source files
task Build Clean, write_file_header,
find_changed_files,
copy_source_content_to_psm1,
update_exported_functions,
update_manifest_version,
register_local_artifact_repository,
publish_to_temp_repository,
remove_temp_repository,
publish_to_gitlab_feed, {
    Write-Build Blue "Beginning the build of $ModuleName. Build type: $Type"
}

# synopsis: Remove any generated files or build artifacts
task Clean create_project_subdirectories, remove_artifact_files,
remove_staging_files,
remove_temp_repository

# synopsis: Validate code quality
task Test  run_unit_tests

task . Build


