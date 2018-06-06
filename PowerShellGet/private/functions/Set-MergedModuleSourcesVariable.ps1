function Set-MergedModuleSourcesVariable
{
    [CmdletBinding()]
    Param(
        [switch]
        $Force
    )

    if(-not $script:PSGetMergedModuleSources -or $Force) {
        $merged = [ordered]@{}

        if($script:PSGetModuleSources) {
            $script:PSGetModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                if(-not $merged.Contains($_)) {
                    $merged.Add($_, $script:PSGetModuleSources[$_])
                }
            }
        }

        if($script:PSGetAllUsersModuleSources) {
            $script:PSGetAllUsersModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                if(-not $merged.Contains($_)) {
                    $merged.Add($_, $script:PSGetAllUsersModuleSources[$_])
                }
            }
        }

        $script:PSGetMergedModuleSources = $merged.AsReadOnly()
    }
}