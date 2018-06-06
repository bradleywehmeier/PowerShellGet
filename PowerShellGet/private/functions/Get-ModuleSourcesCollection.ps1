function Get-ModuleSourcesCollection
{
    param (
        [Parameter()]
        [AllowNull()]
        [string]
        $Scope
    )

    Set-ModuleSourcesVariable

    switch ($Scope) {
        'CurrentUser' { $script:PSGetModuleSources }
        'AllUsers' { $script:PSGetAllUsersModuleSources }
        Default { $script:PSGetMergedModuleSources }
    }
}