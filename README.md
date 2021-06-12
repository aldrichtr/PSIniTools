# PSIniTools
Work with ini formatted files

# Getting Started
## Using PowerShell Module
This process will walk you through installing the module and basic commands.
1. Ensure the IMEF PowerShell Repository is configured

```powershell
PS > Register-PSRepository -Name IMEF -SourceLocation https://psrepo.imefdm.usmc.mil/nuget
```
2. Install PowerShell module

```powershell
PS > Install-Module -Repository IMEF -Name PSIniTools
```

3. Discover commands in the module

```powershell
PS > Get-Command -Module PSIniTools
```

4. Once you find a command that you want to use, read the help to discover how to use the command.

```powershell
PS > Get-Help -Command < Command Name >
```

## Contributing to Module
This process will configure your environment for
1. Ensure the IMEF PowerShell Repository is configured

```powershell
PS > Register-PSRepository -Name IMEF -SourceLocation https://psrepo.imefdm.usmc.mil/nuget
```

2. Install required build PowerShell module

```powershell
PS > Install-Module -Repository IMEF -Name PsDepend
```
3. Clone Repo down to machine

```
git clone https://git.imefdm.usmc.mil/project/path.git
cd path
```
4. Install any missing build dependencies

```powershell
PS > Invoke-PSDepend -Target CurrentUser
```


