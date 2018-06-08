function Remove-PackageSource
{
    [CmdletBinding()]
    param
    (
        [string]
        $Name
    )

    Write-Debug ($LocalizedData.ProviderApiDebugMessage -f ('Remove-PackageSource'))

    Set-ModuleSourcesVariable -Force

    $scope = $request.Options[$script:PackageSourceScope]
    if($scope -eq 'AllUsers')
    {
        $moduleSourcesCollection = $script:PSGetAllUsersModuleSources
    }
    else
    {
        $moduleSourcesCollection = $script:PSGetModuleSources
    }

    $ModuleSourcesToBeRemoved = @()

    foreach ($moduleSourceName in $Name)
    {
        if($request.IsCanceled)
        {
            return
        }

        # Check if $Name contains any wildcards
        if(Test-WildcardPattern $moduleSourceName)
        {
            $message = $LocalizedData.RepositoryNameContainsWildCards -f ($moduleSourceName)
            Write-Error -Message $message -ErrorId "RepositoryNameContainsWildCards" -Category InvalidOperation -TargetObject $moduleSourceName
            continue
        }

        # Check if the specified module source name is in the registered module sources
        if(-not $moduleSourcesCollection.Contains($moduleSourceName))
        {
            $message = $LocalizedData.RepositoryNotFound -f ($moduleSourceName)
            Write-Error -Message $message -ErrorId "RepositoryNotFound" -Category InvalidOperation -TargetObject $moduleSourceName
            continue
        }

        $ModuleSourcesToBeRemoved += $moduleSourceName
        $message = $LocalizedData.RepositoryUnregistered -f ($moduleSourceName)
        Write-Verbose $message
    }

    if($scope -eq 'AllUsers' -and -not (Test-RunningAsElevated))
    {
        # Throw an error when Unregister-PSRepository is used as a non-admin user and '-Scope AllUsers' is specified
        ThrowError -ExceptionName "System.ArgumentException" `
                   -ExceptionMessage ($LocalizedData.UnregisterRepositoryNeedsAdminUserForAllUsersScope -f ($ModuleSourcesToBeRemoved -Join ',')) `
                   -ErrorId 'UnregisterRepositoryNeedsAdminUserForAllUsersScope' `
                   -CallerPSCmdlet $PSCmdlet `
                   -ErrorCategory InvalidArgument
    }

    # Remove the module source
    $ModuleSourcesToBeRemoved | Microsoft.PowerShell.Core\ForEach-Object { $null = $moduleSourcesCollection.Remove($_) }

    # Update the merged collection
    Set-MergedModuleSourcesVariable -Force

    # Persist the module sources
    Save-ModuleSources
}