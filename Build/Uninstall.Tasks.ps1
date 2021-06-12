
# synopsis: remove the module from memory and delete from disk
task uninstall_module {
    Remove-Module -Name $ModuleName -Confirm
    Uninstall-Module -Name $ModuleName
}
