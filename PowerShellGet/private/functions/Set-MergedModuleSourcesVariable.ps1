function Set-MergedModuleSourcesVariable
{
    [CmdletBinding()]
    Param(
        [switch]
        $Force
    )

    if(-not $script:PSGetMergedModuleSources -or $Force) {
        $script:PSGetMergedModuleSources = [ordered]@{}

        if($script:PSGetModuleSources) {
            $script:PSGetModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                if(-not $script:PSGetMergedModuleSources.Contains($_)) {
                    $script:PSGetMergedModuleSources.Add($_, $script:PSGetModuleSources[$_])
                }
            }
        }

        if($script:PSGetAllUsersModuleSources) {
            $script:PSGetAllUsersModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                if(-not $script:PSGetMergedModuleSources.Contains($_)) {
                    $script:PSGetMergedModuleSources.Add($_, $script:PSGetAllUsersModuleSources[$_])
                }
            }
        }

        Write-Debug -Message "Merged Module Sources: $($script:PSGetMergedModuleSources.Keys)"
    }
}