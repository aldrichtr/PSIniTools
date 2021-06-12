
# synopsis: Install the module to the current user scope
task install_artifact_to_currentuser_scope {
    Install-Module -Repository $ModuleName -Scope CurrentUser -Name $ModuleName
}
