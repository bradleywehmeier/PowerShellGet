function Set-ModuleSourcesVariable
{
    [CmdletBinding()]
    param(
        [switch]
        $Force,

        $Proxy,

        $ProxyCredential
    )

    $updateMerged = $false

    if(-not $script:PSGetModuleSources -or $Force)
    {
        $isPersistRequired = $false
        if(Microsoft.PowerShell.Management\Test-Path $script:PSGetModuleSourcesFilePath)
        {
            $script:PSGetModuleSources = DeSerialize-PSObject -Path $script:PSGetModuleSourcesFilePath
        }
        else
        {
            $script:PSGetModuleSources = [ordered]@{}

            if(-not $script:PSGetModuleSources.Contains($Script:PSGalleryModuleSource))
            {
                $null = Set-PSGalleryRepository -Proxy $Proxy -ProxyCredential $ProxyCredential
            }
        }

        # Already registered repositories may not have the ScriptSourceLocation property, try to populate it from the existing SourceLocation
        # Also populate the PublishLocation and ScriptPublishLocation from the SourceLocation if PublishLocation is empty/null.
        #
        $script:PSGetModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                                              $moduleSource = $script:PSGetModuleSources[$_]

                                              if(-not (Get-Member -InputObject $moduleSource -Name $script:ScriptSourceLocation))
                                              {
                                                  $scriptSourceLocation = Get-ScriptSourceLocation -Location $moduleSource.SourceLocation -Proxy $Proxy -ProxyCredential $ProxyCredential

                                                  Microsoft.PowerShell.Utility\Add-Member -InputObject $script:PSGetModuleSources[$_] `
                                                                                          -MemberType NoteProperty `
                                                                                          -Name $script:ScriptSourceLocation `
                                                                                          -Value $scriptSourceLocation

                                                  if(Get-Member -InputObject $moduleSource -Name $script:PublishLocation)
                                                  {
                                                      if(-not $moduleSource.PublishLocation)
                                                      {
                                                          $script:PSGetModuleSources[$_].PublishLocation = Get-PublishLocation -Location $moduleSource.SourceLocation
                                                      }

                                                      Microsoft.PowerShell.Utility\Add-Member -InputObject $script:PSGetModuleSources[$_] `
                                                                                              -MemberType NoteProperty `
                                                                                              -Name $script:ScriptPublishLocation `
                                                                                              -Value $moduleSource.PublishLocation
                                                  }

                                                  $isPersistRequired = $true
                                              }

                                              Microsoft.PowerShell.Utility\Add-Member -InputObject $script:PSGetModuleSources[$_] `
                                                                                      -MemberType NoteProperty `
                                                                                      -Name $script:PackageSourceScope `
                                                                                      -Value 'CurrentUser' `
                                                                                      -Force
                                          }

        if($isPersistRequired)
        {
            Save-ModuleSources
        }

        $updateMerged = $true
    }

    if(-not $script:PSGetAllUsersModuleSources -or $Force)
    {
        if(Microsoft.PowerShell.Management\Test-Path $script:PSGetAllUsersModuleSourcesFilePath)
        {
            $script:PSGetAllUsersModuleSources = DeSerialize-PSObject -Path $script:PSGetAllUsersModuleSourcesFilePath
            $script:PSGetAllUsersModuleSources.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                Microsoft.PowerShell.Utility\Add-Member -InputObject $script:PSGetAllUsersModuleSources[$_] `
                                                        -MemberType NoteProperty `
                                                        -Name $script:PackageSourceScope `
                                                        -Value 'AllUsers' `
                                                        -Force
            }
            $updateMerged = $true
        }
        else
        {
            $script:PSGetAllUsersModuleSources = [ordered]@{}
        }
    }

    if($updateMerged)
    {
        Set-MergedModuleSourcesVariable
    }
}