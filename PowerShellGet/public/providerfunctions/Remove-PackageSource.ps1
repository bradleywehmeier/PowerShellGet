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

    $moduleSourcesCollection = Get-ModuleSourcesCollection -Scope $request.Options[$script:PackageSourceScope]

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

        $moduleSource = $moduleSourcesCollection[$moduleSourceName]

        if($moduleSource.Scope -eq 'AllUsers' -and -not (Test-RunningAsElevated))
        {
            # Throw an error when Unregister-PSRepository is used as a non-admin user and '-Scope AllUsers' is specified
            ThrowError -ExceptionName "System.ArgumentException" `
                    -ExceptionMessage ($LocalizedData.UnregisterRepositoryNeedsAdminUserForAllUsersScope -f ($ModuleSourcesToBeRemoved -Join ',')) `
                    -ErrorId 'UnregisterRepositoryNeedsAdminUserForAllUsersScope' `
                    -CallerPSCmdlet $PSCmdlet `
                    -ErrorCategory InvalidArgument
        }

        $ModuleSourcesToBeRemoved += $moduleSource
        $message = $LocalizedData.RepositoryUnregistered -f ($moduleSourceName)
        Write-Verbose $message
    }

    # Remove the module source
    $ModuleSourcesToBeRemoved | Microsoft.PowerShell.Core\ForEach-Object {
        if($_.Scope -eq 'AllUsers')
        {
            $null = $script:PSGetAllUsersModuleSources.Remove($_.Name)
        }
        else
        {
            $null = $script:PSGetModuleSources.Remove($_.Name)
        }
    }

    # Update the merged collection
    Set-MergedModuleSourcesVariable -Force

    # Persist the module sources
    Save-ModuleSources
}