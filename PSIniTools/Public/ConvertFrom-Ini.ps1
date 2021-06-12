
<#
.SYNOPSIS
    Converts an ini structure to a hashtable
.EXAMPLE
    Get-Content -Path /path/to/my/inifile.ini | ConvertFrom-Ini
#>
Function ConvertFrom-Ini {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false,
        ValueFromPipeline = $true )]
        [string] $InputObject,
        [Parameter(Mandatory = $false)]
        [string]$Root = 'root'
    )
    begin {
        $ini = @{}
        $comments = $true # process comments
        $commentsName = 'comments'
    }
    process {
        switch -regex ($InputObject) {
            "^\[(.+)\]$" {
                # Section
                Write-Verbose "'$InputObject' : matches Section"
                $section = $Matches.1
                $ini[$section] = @{}
                continue
            }

            "^([;#].*)$" {
                # Comment
                Write-Verbose "'$InputObject' : matches Comment"
                if ($comments) {
                    if (-not ($section)) {
                        $section = $Root
                        $ini[$section] = @{}
                    }
                    Write-Verbose "Adding to $section $commentsName"
                    if ($ini[$section].ContainsKey($commentsName)) {
                        $ini[$section][$commentsName] += $InputObject
                    } else {
                        $ini[$section][$commentsName] = $InputObject
                    }

                }
                continue
            }

            "^(.+?)\s*=\s*(.*)$" {
                # Key
                Write-Verbose "'$InputObject' : matches Key"
                if ( -not ($section)) {
                    $section = $Root
                    $ini[$section] = @{}
                }
                $name, $value = $matches[1..2]
                $ini[$section][$name] = $value
                continue
            }
        }
    }
    end {
        return $ini
    }
}
