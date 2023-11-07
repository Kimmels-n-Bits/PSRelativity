<#
.SYNOPSIS
Function to update an existing Relativity ARM restore job using Relativity's REST API.

.DESCRIPTION
This function constructs the required request, calls Relativity's REST API, and processes the response to update an existing ARM retore job.

.PARAMETER JobID
The Job ID of the ARM restore job to be updated. This is a mandatory parameter.

.PARAMETER ArchivePath
The path of the ARM archive to be restored. This archive path must not be in use by another ARM job.

.PARAMETER JobPriority
Priority of execution for the job. Possible options include "Low", "Medium", and "High". Default is "Medium".

.PARAMETER ScheduledStartTime
Scheduled time when the job will be run.

.PARAMETER ExistingTargetDatabase
Target database in case the archive does not have a database backup bak file (also known as bakless archive)

.PARAMETER DatabaseServerID
ArtifactId of the target database server to restore the workspace to.

.PARAMETER ResourcePoolID
ArtifactId of the target resource pool to restore the workspace to.

.PARAMETER MatterID
ArtifactId of the target matter to restore the workspace to.

.PARAMETER CacheLocationID
ArtifactId of the target cache location to restore the workspace to.

.PARAMETER FileRepositoryID
ArtifactId of the target file repository to restore the workspace to.

.PARAMETER StructuredAnalyticsServerID
ArtifactId of the structured analytics server (in case archive contains structured analytics data) to restore the workspace to.

.PARAMETER ConceptualAnalyticsServerID
ArtifactId of the conceptual analytics server (in case archive contains conceptual analytics data) to restore the workspace to.

.PARAMETER DtSearchLocationID
ArtifactId of the dtSearch location (in case archive contains dtSearch indexes) to restore the workspace to.

.PARAMETER ReferenceFilesAsArchiveLinks
Indicates whether files should remain in the archive directory and should be referenced from the workspace database (File table) as opposed to copying to workspace repository.
Default is false.

.PARAMETER UpdateRepositoryFilePaths
Indicates whether repository files' locations should be updated to reflect their new location.
Default is true.

.PARAMETER UpdateLinkedFilePaths
Indicates whether non-repository (linked) files' locations should be updated to reflect their new location.
Default is true.

.PARAMETER AutoMapUsers
Indicates if archive users should be auto mapped by email address.

.PARAMETER UserMappings
Hashtable array of explicit user mappings from the archive to the Relativity instance.
Array must have two properties, ArchiveUserID and InstanceUserID, of type Int32.

.PARAMETER AutoMapGroups
Indicates if archive groups should be auto mapped by name.

.PARAMETER GroupMappings
Hashtable array of explicit group mappings from the archive to the Relativity instance.
Array must have two properties, ArchiveGroupID and InstanceGroupID, of type Int32.

.PARAMETER Applications
HashtableArray of non-required/3rd party applications that should be installed to the workspace.
Required Relativity applications are automatically upgraded during workspace upgrade stage and are not needed here.
Array must have two properties, Guid and ShouldRestore, of types String and Boolean respectively.

.PARAMETER NotifyJobCreator
Indicates if email notifications will be sent to the job creator.

.PARAMETER NotifyJobExecutor
Indicates if email notifications will be sent to the job executor.

.PARAMETER UiJobActionsLocked
Indicates if job actions normally available on UI should be visible for the user.
This behavior can be override by adding boolean instance setting OverrideUiJobActionsLock.

.EXAMPLE
Set-RelativityArmRestoreJob -ArchivePath "\\server\path" -DatabaseServerID 1234567 -ResourcePoolID 2345671 -MatterID 3456712 -CacheLocationID 4567123 -FileRepositoryID 5671234

This example updates an existing restore job with the specified archive path and destination options.

.NOTES
Ensure you have connectivity and appropriate permissions in Relativity before running this function.
#>
function Set-RelativityArmRestoreJob
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int32] $JobID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $ArchivePath,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Low", "Medium", "High")]
        [String] $JobPriority = "Medium",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            $date = "1970-01-01"
            [DateTime]::TryParse($_, [ref]$date)
            if($_ -eq "") { return $true }
            elseif ($date -eq [DateTime]::MinValue) { throw "Invalid DateTime for ScheduledStartTime: $($_)."}
            $true
        })]
        [String] $ScheduledStartTime,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ExistingTargetDatabase,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $DatabaseServerID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $ResourcePoolID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $MatterID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $CacheLocationID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $FileRepositoryID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $StructuredAnalyticsServerID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $ConceptualAnalyticsServerID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $DtSearchLocationID,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $ReferenceFilesAsArchiveLinks,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UpdateRepositoryFilePaths = $true,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UpdateLinkedFilePaths = $true,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $AutoMapUsers,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Hashtable[]] $UserMappings,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $AutoMapGroups,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Hashtable[]] $GroupMappings,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Hashtable[]] $Applications,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobCreator,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobExecutor,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UiJobActionsLocked
    )

    Begin
    {
        Write-Verbose "Starting Set-RelativityArmRestoreJob"
    }
    Process
    {
        try
        {
            $Params = @{
                ArchivePath = $ArchivePath
                JobPriority = $JobPriority
                ScheduledStartTime = $ScheduledStartTime
                ExistingTargetDatabase = $ExistingTargetDatabase
                DatabaseServerID = $DatabaseServerID
                ResourcePoolID = $ResourcePoolID
                MatterID = $MatterID
                CacheLocationID = $CacheLocationID
                FileRepositoryID = $FileRepositoryID
                StructuredAnalyticsServerID = $StructuredAnalyticsServerID
                ConceptualAnalyticsServerID = $ConceptualAnalyticsServerID
                DtSearchLocationID = $DtSearchLocationID
                ReferenceFilesAsArchiveLinks = $ReferenceFilesAsArchiveLinks
                UpdateRepositoryFilePaths = $UpdateRepositoryFilePaths
                UpdateLinkedFilePaths = $UpdateLinkedFilePaths
                AutoMapUsers = $AutoMapUsers
                UserMappings = $UserMappings
                AutoMapGroups = $AutoMapGroups
                GroupMappings = $GroupMappings
                Applications = $Applications
                NotifyJobCreator = $NotifyJobCreator
                NotifyJobExecutor = $NotifyJobExecutor
                UiJobActionsLocked = $UiJobActionsLocked
            }

            $Request = Get-RelativityArmRestoreJobCreateOrUpdateRequest @Params

            $RequestBody = $Request.ToHashTable()

            [String[]]$Resources = @("restore-jobs", $JobID.ToString())

            $ApiEndpoint = Get-RelativityApiEndpoint -BusinessDomain "relativity-arm" -Version "v1" -Resources $Resources

            Write-Debug "Preparing to invoke PUT method at Relativity API endpoint '$($ApiEndPoint)' with RequestBody $($RequestBody | ConvertTo-Json -Depth 10)"
            Write-Verbose "Invoking PUT method at Relativity API endpoint: $($ApiEndPoint)"
            if ($PSCmdlet.ShouldProcess($ApiEndpoint))
            {
                $ApiResponse = Invoke-RelativityApiRequest -ApiEndpoint $ApiEndpoint -HttpMethod "Put" -RequestBody $RequestBody

                $Response = [RelativityApiSuccessResponse]::New($ApiResponse.Success)
                Write-Verbose "Successfully updated ARM restore job with ID: $($JobID)"
            }

            return $Response
        }
        catch
        {
            Write-Error "An error occurred: $($_.Exception) type: $($_.GetType().FullName)"
            Write-Verbose "API Endpoint: $($ApiEndpoint)"
            Write-Verbose "JobID: $($JobID)"
            Write-Verbose "ArchivePath: $($ArchivePath)"
            Write-Verbose "JobPriority: $($JobPriority)"
            Write-Verbose "ScheduledStartTime: $($ScheduledStartTime)"
            Write-Verbose "ExistingTargetDatabase: $($ExistingTargetDatabase)"
            Write-Verbose "DatabaseServerID: $($DatabaseServerID)"
            Write-Verbose "ResourcePoolID: $($ResourcePoolID)"
            Write-Verbose "MatterID: $($MatterID)"
            Write-Verbose "CacheLocationID: $($CacheLocationID)"
            Write-Verbose "FileRepositoryID: $($FileRepositoryID)"
            Write-Verbose "StructuredAnalyticsServerID: $($StructuredAnalyticsServerID)"
            Write-Verbose "ConceptualAnalyticsServerID: $($ConceptualAnalyticsServerID)"
            Write-Verbose "DtSearchLocationID: $($DtSearchLocationID)"
            Write-Verbose "ReferenceFilesAsArchiveLinks: $($ReferenceFilesAsArchiveLinks)"
            Write-Verbose "UpdateRepositoryFilePaths: $($UpdateRepositoryFilePaths)"
            Write-Verbose "UpdateLinkedFilePaths: $($UpdateLinkedFilePaths)"
            Write-Verbose "AutoMapUsers: $($AutoMapUsers)"
            Write-Verbose "UserMappings $($UserMappings | ConvertTo-Json)"
            Write-Verbose "AutoMapGroups: $($AutoMapGroups)"
            Write-Verbose "GroupMappings: $($GroupMappings | ConvertTo-Json)"
            Write-Verbose "Applications: $($Applications | ConvertTo-Json)"
            Write-Verbose "NotifyJobCreator: $($NotifyJobCreator)"
            Write-Verbose "NotifyJobExecutor: $($NotifyJobExecutor)"
            Write-Verbose "UiJobActionsLocked: $($UiJobActionsLocked)"
            throw
        }
    }
    End
    {
        Write-Verbose "Completed Set-RelativityArmRestoreJob"
    }
}
