function Get-SourceLocation
{
    [CmdletBinding()]
    [OutputType("string")]
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceName
    )

    $moduleSources = Get-ModuleSourcesCollection

    if($moduleSources.Contains($SourceName))
    {
        return $moduleSources[$SourceName].SourceLocation
    }
    else
    {
        return $SourceName
    }
}