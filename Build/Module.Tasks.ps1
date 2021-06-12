
# synopsis: Write a file header for the module file
task write_file_header {
    [System.IO.FileInfo] $target_module = "$($Path.Staging)\$ModuleName.psm1"
    Set-Content -Path $target_module.FullName -Value ("#" * 80)
    Add-Content -Path $target_module.FullName -Value "# $ModuleName : $([datetime]::Now)`n`n"
}

# synopsis: Assemble the contents of individual source files into the psm1 file
task copy_source_content_to_psm1 {

    [string[]] $source_types = @("Enum", "Classes", "Private", "Public")
    [System.IO.FileInfo] $target_module = "$($Path.Staging)\$ModuleName.psm1"

    # keep track of how many files were imported
    $file_count = 0

    foreach ($sourceType in $source_types ) {
        $src_path = Join-Path -Path $Path.Source -ChildPath $sourceType
        if (Test-Path $src_path) {
            Write-Build Green "Assembling $sourceType files"

            # Create a section header
            Add-Content -Path $target_module.FullName -Value ("#" * 80)
            Add-Content -Path $target_module.FullName -Value "# $sourceType Section`n`n"

            Get-ChildItem -Path $src_path -Include "*.ps1" -Recurse | Foreach-Object {
                Write-Build Blue "Adding $($_.BaseName) to $($ModuleName)"
                Get-Content -Path $_ | Add-Content -Path $target_module.FullName
                $file_count++
            }
        }
    }
    Write-Build Green "( $file_count ) files assembled into $target_module"
}

task add_functions_to_export {
    [string[]] $functions = ( Get-ChildItem -Path "$( $Path.Source )\Public" -Name *.ps1 ).Name -replace '.ps1'

    Update-ModuleManifest -FunctionsToExport $functions -Path "$($Path.Staging)\$ModuleName.psd1"
}