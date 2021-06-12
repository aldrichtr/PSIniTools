

# synopsis: Create the required directories if they do not exist
task create_project_subdirectories {
    Write-Build Yellow "Configuring $ModuleName"
    $Path.Keys | ForEach-Object {
        if (Test-Path $Path.$_ ) {
            Write-Build Green "$_ directory exists"
        }
        else {
            Write-Build Red "$_ directory missing, creating now"
            $null = New-Item $Path.$_ -ItemType Directory
        }
    }
}

# synopsis: Install any required modules for building the module
task install_developer_modules {
    Invoke-PSDepend -Path $BuildRoot
}
