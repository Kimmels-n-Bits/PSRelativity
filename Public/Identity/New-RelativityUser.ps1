function New-RelativityUser
{
    <#
        .SYNOPSIS
            Function creates a NEW Relativity user.
            REQUIRED PARAMETERS: FName, LName, ClientID, TypeID, Email
        .DESCRIPTION
            This function constructs the required request, 
            calls Relativity's REST API, 
            creates a user, 
            and returns a [RelativityIdentityV1UserModelsUserResponse].


        .PARAMETER AllowSettingsChange
            Gets or sets a Boolean value indicating whether the user will be able to change a limited number of their settings.
        .PARAMETER ClientID
            Gets or sets the [RelativityIdentityV1SharedSecurable[T]] identifier for the client associated with the user
        .PARAMETER ClientSecured
            Sets Client Secured or not.
        .PARAMETER DV_DefaultFilterVisibility
            Gets or sets a Boolean value indicating whether filters on all columns are visible by default.
        .PARAMETER DV_AllowDocumentSkipPreferenceChange
            Gets or sets whether the user has the ability to change their preference to skip documents during review that no longer meet the original conditions of a view due to propagation.
        .PARAMETER DV_AllowDocumentViewerChange
            Gets or sets a Boolean value indicating whether the user will be able to change the document viewer modes.
        .PARAMETER DV_AllowKeyboardShortcuts
            Gets or sets a Boolean value indicating whether the user can see the keyboard shortcuts icon in the core reviewer interface.
        .PARAMETER DV_DefaultSelectedFileType
            Gets or sets the default viewer mode.
        .PARAMETER DV_DocumentViewer
            Gets or sets the which viewer the user can access when reviewing documents.
        .PARAMETER DV_SkipDefaultPreference
            Gets or sets a Boolean value indicating whether the user advances to the next document in the queue that matches the defined view conditions when the user clicks Save and Next.
        .PARAMETER DisableOnDate
            Gets or sets the date when the user's Relativity access will be auto-disabled.
        .PARAMETER Email
            Gets or sets the user's email address in the format name@domain.extension.
        .PARAMETER EmailPreference
            Gets or sets the user's preference for email notifications when adding or deleting Users or Groups.
        .PARAMETER FName
            Gets or sets the user's first name.
        .PARAMETER ItemListPageLength
            Gets or sets the default list length for all view in Relativity for the user.
        .PARAMETER Keywords
            Gets or sets any keywords associated with the user.
        .PARAMETER LName
            Gets or sets the user's last name.
        .PARAMETER Notes
            Gets or sets an optional description or other information about the user.
        .PARAMETER RelativityAccessEnabled
            Gets or sets whether the user can to log in to Relativity and be considered for billing under your Relativity license.
        .PARAMETER SavedSearchDefaultsToPublic
            Gets or sets a Boolean value indicating whether saved searches are public or private by default.
        .PARAMETER TrustedIPs
            Gets or sets an ARRAY of IP address or addresses that are valid locations from which the user can log in from.
        .PARAMETER TypeID
            Gets or sets the user's typeID. Type is for reference purposes only and has no impact on access or billing.
            Relativity sets this to 663 Internal, by default.

        .EXAMPLE
            New-RelativityUser `
                -FName "joe" `
                -LName "smith" `
                -ClientID 1234567 `
                -TypeID 1059571 `
                -Email "j.smith@nowhere.com" `
                -AllowSettingsChange `
                -RelativityAccessEnabled `
                -DV_AllowKeyboardShortcuts `
                -DV_DefaultSelectedFileType "Default" `
                -DV_DocumentViewer "HTML"

                This example will CREATE a new user named "Joe Smith", with some options set.

        .NOTES
            HTTP Response will be a [RelativityIdentityV1UserModelsUserResponse] object.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    Param
    (
        [Switch] $AllowSettingsChange,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32] $ClientID,
        [Switch] $ClientSecured,
        [Switch] $DV_DefaultFilterVisibility,
        [Switch] $DV_AllowDocumentSkipPreferenceChange,
        [Switch] $DV_AllowDocumentViewerChange,
        [Switch] $DV_AllowKeyboardShortcuts,
        [String] $DV_DefaultSelectedFileType = "Default",
        [String] $DV_DocumentViewer = "Default",
        [Switch] $DV_SkipDefaultPreference,
        [Nullable[DateTime]] $DisableOnDate = $null,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [String] $Email,
        [String] $EmailPreference = "Default",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [String] $FName,
        [Nullable[Int32]] $ItemListPageLength,
        [String] $Keywords,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [String] $LName,
        [String] $Notes,
        [Switch] $RelativityAccessEnabled,
        [Switch] $SavedSearchDefaultsToPublic,
        [Collections.Generic.List[String]] $TrustedIPs,
        [ValidateScript({
                if ($null -ne $_) { $_ -ge 1 -and $_ -le [Int32]::MaxValue }
                else { $true }
            })]
        [Nullable[Int32]] $TypeID
    )

    Begin
    {
        Write-Verbose "Starting $($MyInvocation.MyCommand.Name)"
    }
    Process
    {
        try
        {
            $Request = [RelativityIdentityV1UserModelsUserRequest]::New(
                $AllowSettingsChange.IsPresent,
                $null,
                $DV_DefaultFilterVisibility.IsPresent,
                $DisableOnDate,
                $null,
                $Email,
                $EmailPreference,
                $FName,
                $ItemListPageLength,
                $Keywords,
                $LName,
                $Notes,
                $RelativityAccessEnabled.IsPresent,
                $SavedSearchDefaultsToPublic.IsPresent,
                $TrustedIPs,
                $TypeID)

            #region Client
            if ($ClientID -ne $null)
            {
                $Request.Client = [RelativityIdentityV1SharedSecurable]::New(
                    $ClientSecured.IsPresent,
                    [RelativityIdentityV1SharedObjectIdentifier]::New(
                        $ClientID
                    )
                )
            }
            else
            {
                $Request.Client = [RelativityIdentityV1SharedSecurable]::New($ClientSecured.IsPresent, $null)
            }
            #endregion Client

            #region DocumentViewerProperties
            $Request.DocumentViewerProperties = [RelativityIdentityV1UserModelsDocumentViewerProperties]::New(
                $DV_AllowDocumentSkipPreferenceChange.IsPresent,
                $DV_AllowDocumentViewerChange.IsPresent,
                $DV_AllowKeyboardShortcuts.IsPresent,
                $DV_DefaultSelectedFileType,
                $DV_DocumentViewer,
                $DV_SkipDefaultPreference.IsPresent
            )
            #endregion DocumentViewerProperties


            $RequestBody = $Request.ToHashTable()

            $ApiEndpoint = Get-RelativityApiEndpoint `
                -BusinessDomain "Relativity-Identity" `
                -Version "v1" `
                -Resources @("users")

            Write-Debug "Preparing to invoke POST method at Relativity API endpoint '$($ApiEndpoint)' with RequestBody $($RequestBody | ConvertTo-Json -Depth 10)"
            Write-Verbose "Invoking POST method at Relativity API endpoint: $($ApiEndpoint)"

            $ApiResponse = Invoke-RelativityApiRequest -ApiEndpoint $ApiEndpoint -HttpMethod "Post" -RequestBody $RequestBody
            Write-Debug $ApiResponse

            $Response = [RelativityIdentityV1UserModelsUserResponse]::New($ApiResponse)
            return $Response
        }
        catch
        {
            Write-Error "An error occurred: $($_.Exception) type: $($_.GetType().FullName)"
            Write-Verbose "Logging parameter values:"

            (Get-Command -Name $PSCmdlet.MyInvocation.InvocationName).Parameters | ForEach-Object {
                $_.Values | ForEach-Object {
                    $Parameter = Get-Variable -Name $_.Name -ErrorAction SilentlyContinue

                    if ($null -ne $Parameter)
                    {
                        Write-Verbose "$($Parameter.Name): $($Parameter.Value)"
                    }
                }
            }

            Write-Verbose "API Endpoint: $($ApiEndpoint)"
            throw
        }
    }
    End
    {
        Write-Verbose "Completed $($MyInvocation.MyCommand.Name)"
    }
}