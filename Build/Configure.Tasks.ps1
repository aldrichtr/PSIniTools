

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

task add_developer_tools {
    Get-ChildItem -Path $Path.Tools -Filter "*.ps1" -Recurse | ForEach-Object {
        . $_.FullName
    }

}

task init_git_repo {
    git init
    git add README.md
    git commit -m"initial project creation"
}
