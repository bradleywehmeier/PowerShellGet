function Get-SourceName
{
    [CmdletBinding()]
    [OutputType("string")]
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Location,

        [Parameter()]
        [AllowNull()]
        [string]
        $Scope
    )

    $moduleSources = Get-ModuleSourcesCollection -Scope $Scope

    foreach($psModuleSource in $moduleSources.Values)
    {
        if(($psModuleSource.Name -eq $Location) -or
           ($psModuleSource.SourceLocation -eq $Location) -or
           ((Get-Member -InputObject $psModuleSource -Name $script:ScriptSourceLocation) -and
           ($psModuleSource.ScriptSourceLocation -eq $Location)))
        {
            return $psModuleSource.Name
        }
    }
}