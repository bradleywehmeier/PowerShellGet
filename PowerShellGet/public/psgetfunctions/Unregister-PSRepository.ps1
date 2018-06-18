function Unregister-PSRepository
{
    <#
    .ExternalHelp PSModule-help.xml
    #>
    [CmdletBinding(HelpUri='https://go.microsoft.com/fwlink/?LinkID=517130')]
    Param
    (
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("CurrentUser","AllUsers")]
        [string]
        $Scope
    )

    Begin
    {
        Get-PSGalleryApiAvailability -Repository $Name
    }

    Process
    {
        $PSBoundParameters["Provider"] = $script:PSModuleProviderName
        $PSBoundParameters["MessageResolver"] = $script:PackageManagementMessageResolverScriptBlock

        $null = $PSBoundParameters.Remove("Name")

        if($Scope)
        {
            $PSBoundParameters[$script:PackageSourceScope] = $Scope
        }
        $null = $PSBoundParameters.Remove("Scope")

        foreach ($moduleSourceName in $Name)
        {
            # Check if $moduleSourceName contains any wildcards
            if(Test-WildcardPattern $moduleSourceName)
            {
                $message = $LocalizedData.RepositoryNameContainsWildCards -f ($moduleSourceName)
                Write-Error -Message $message -ErrorId "RepositoryNameContainsWildCards" -Category InvalidOperation
                continue
            }

            $PSBoundParameters["Source"] = $moduleSourceName

            $null = PackageManagement\Unregister-PackageSource @PSBoundParameters
        }
    }
}