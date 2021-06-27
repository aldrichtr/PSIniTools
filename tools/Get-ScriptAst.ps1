

Function Get-ScriptAst {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$ScriptBlock
    )
    $tokens = $null
    $parse_errors = $null


    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput( $ScriptBlock, [ref]$tokens, [ref]$parse_errors)
    }
    catch {
        throw "There was an error parsing the input`n$_"
    }
    $ast
}
