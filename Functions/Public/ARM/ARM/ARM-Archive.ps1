<#
.SYNOPSIS
Creates a new Relativity ARM Archive Job.

.DESCRIPTION
The function constructs a request to create a new ARM archive job in Relativity.
It allows for extensive configuration through various parameters, enabling users to specify
details like the workspace ArtifactId, job priority, file options, and more.
If job creation is successful the response will be the Id of the newly created job.
If the job creation could not be completed the response will contain validation errors with more detailed information.

.PARAMETER WorkspaceID
The ArtifactId of the workspace to archive for the archive job. This is a mandatory parameter.
This workspace must not be in the process of upgrading or currently in use by another ARM job.

.PARAMETER JobPriority
Priority of execution for the job. Possible options include "Low", "Medium", and "High".
Default is "Medium".

.PARAMETER ArchiveDirectory
File path of the configured archive directory to save the archive to.
When this is set UseDefaultArchiveDirectory has to be false.

.PARAMETER ScheduledStartTime
Scheduled time when the job will be run.

.PARAMETER IncludeDatabaseBackup
Indicates if the workspace database backup is included in the archive.

.PARAMETER IncludeDtSearch
Indicates whether dtSearch indices will be included in the archive directory.

.PARAMETER IncludeConceptualAnalytics
Indicates whether Conceptual Analytics indices will be included in the archive directory.

.PARAMETER IncludeStructuredAnalytics
Indicates whether Structured Analytics sets will be included in the archive directory.

.PARAMETER IncludeDataGrid
Indicates whether Data Grid application data will be present in the archive directory.

.PARAMETER IncludeRepositoryFiles
 Indicates whether all files included in the workspace repository, including files from file fields, will be archived in the archive directory.

.PARAMETER IncludeLinkedFiles
Indicates whether all linked files that do not exist in the workspace file repository will be archived in the archive directory.

.PARAMETER MissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing files are detected during the archiving process.
If there is potential for any files to not be found while the job is running, skipping them will result in compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the expected location.
Default is "SkipFile".

.PARAMETER IncludeProcessing
Indicates whether Processing application data will be present in the archive directory.

.PARAMETER IncludeProcessingFiles
Indicates whether all the files and containers that have been discovered by Processing will be archived and placed in the Invariant directory.

.PARAMETER ProcessingMissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing Processing files are detected during the archiving process.
If there is potential for any files to not be found while the job is running, skipping them will result in compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the expected location.
Default is "SkipFile".

.PARAMETER IncludeExtendedWorkspaceData
 Indicates whether extended workspace information is included in the archive.
 This includes installed applications, linked relativity scripts, and non-application event handlers.

.PARAMETER ApplicationErrorExportBehavior
Indicates whether to skip applications that errored during export ("SkipApplication") or to stop ("StopJob").
Default is "SkipApplication".

.PARAMETER NotifyJobCreator
Indicates if email notifications will be sent to the job creator.

.PARAMETER NotifyJobExecutor
Indicates if email notifications will be sent to the job executor.

.PARAMETER UiJobActionsLocked
Indicates if job actions normally available on UI should be visible for the user.
This behavior can be override by adding boolean instance setting OverrideUiJobActionsLock.

.PARAMETER UseDefaultArchiveDirectory
When this option is set to true leave ArchiveDirectory empty.
ARM will select the fist valid one from configuration.

.EXAMPLE
New-RelativityArmArchiveJob -WorkspaceId 1234567 -ArchiveDirectory "\\server\path" -IncludeDatabaseBackup

This example creates a new archive job for workspace with the ArtifactId 1234567 in the specified directory and includes a database backup.

.EXAMPLE
New-RelativityArmArchiveJob -WorkspaceId 1234567 -IncludeDatabaseBackup -IncludeRepositoryFiles -UseDefaultArchiveDirectory

This example creates a new archive job for workspace with the ArtifactId 1234567 using the default archive directory and includes a database backup and repository files.

.NOTES
Ensure you have connectivity and appropriate permissions in Relativity before running this function.
#>
function New-RelativityArmArchiveJob
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Int32] $WorkspaceID,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $JobPriority = "Medium",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String] $ArchiveDirectory,
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
        [Switch] $IncludeDatabaseBackup,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDtSearch,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeConceptualAnalytics,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeStructuredAnalytics,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDataGrid,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeRepositoryFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeLinkedFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $MissingFileBehavior = "SkipFile",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessing,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessingFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ProcessingMissingFileBehavior = "SkipFile",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeExtendedWorkspaceData,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ApplicationErrorExportBehavior = "SkipApplication",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobCreator,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobExecutor,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UiJobActionsLocked,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UseDefaultArchiveDirectory
    )
    Process
    {
        $MigratorOptions = [RelativityArmArchiveJobMigratorOptions]::New($IncludeDatabaseBackup, $IncludeDtSearch, $IncludeConceptualAnalytics, $IncludeStructuredAnalytics, $IncludeDataGrid)
        $FileOptions = [RelativityArmArchiveJobFileOptions]::New($IncludeRepositoryFiles, $IncludeLinkedFiles, $MissingFileBehavior)
        $ProcessingOptions = [RelativityArmArchiveJobProcessingOptions]::New($IncludeProcessing, $IncludeProcessingFiles, $ProcessingMissingFileBehavior)
        $ExtendedWorkspaceDataOptions = [RelativityArmArchiveJobExtendedWorkspaceDataOptions]::New($IncludeExtendedWorkspaceData, $ApplicationErrorExportBehavior)
        $NotificationOptions = [RelativityArmArchiveJobNotificationOptions]::New($NotifyJobCreator, $NotifyJobExecutor)

        $RelativityArmArchiveJobCreateRequest = [RelativityArmArchiveJobCreateRequest]::New($WorkspaceID, $JobPriority, $ArchiveDirectory, $ScheduledStartTime, $MigratorOptions, $FileOptions, $ProcessingOptions, $ExtendedWorkspaceDataOptions, $NotificationOptions, $UiJobActionsLocked, $UseDefaultArchiveDirectory)

        $RelativityApiRequestBody =
        @{
            request = $RelativityArmArchiveJobCreateRequest.ToHashTable()
        }

        $RelativityApiEndpointExtended = "archive-jobs"

        $RelativityArmArchiveJobCreateResponse = Invoke-RelativityApiRequest -RelativityBusinessDomain "ARM" -RelativityApiEndpointExtended $RelativityApiEndpointExtended -RelativityApiHttpMethod "Post" -RelativityApiRequestBody $RelativityApiRequestBody

        return [RelativityArmArchiveJobCreateResponse]::New([Int32]$RelativityArmArchiveJobCreateResponse)
    }
}

<#
.SYNOPSIS
Retrieves details of a Relativity ARM Archive Job.

.DESCRIPTION
The function sends a request to retrieve details of an ARM archive job in Relativity based on the provided JobID.
The response contains various details about the job, such as the job's name, execution ID, archive path, workspace it relates to, and other configuration options.
It's important to ensure that the provided JobID corresponds to an existing job in the system.

.PARAMETER JobID
The ID of the ARM archive job to retrieve. This is a mandatory parameter.

.EXAMPLE
Get-RelativityArmArchiveJob -JobID 3026

This example retrieves details of the archive job with the ID of 3026.

.NOTES
Ensure you have connectivity and appropriate permissions in Relativity before running this function. 
The function does not modify any data but only retrieves details of a specified job.
#>
function Get-RelativityArmArchiveJob
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        #[ValidateNotNull()]
        [Int32] $JobID
    )

    Process
    {
        $RelativityApiEndpointExtended = "archive-jobs/$($JobID)"

        $RelativityArmArchiveJobReadResponse = Invoke-RelativityApiRequest -RelativityBusinessDomain "ARM" -RelativityApiEndpointExtended $RelativityApiEndpointExtended -RelativityApiHttpMethod "Get"

        $RelativityArmArchiveJobActionsHistory = [RelativityArmArchiveJobActionHistory[]]@()

        $RelativityArmArchiveJobReadResponse.JobDetails.ActionsHistory | ForEach-Object {
            $RelativityArmArchiveJobActionsHistory += [RelativityArmArchiveJobActionHistory]::New($_.Date, $_.Type, $_.UserName)
        }

        $RelativityArmArchiveJobDetails = [RelativityArmArchiveJobDetails]::New($RelativityArmArchiveJobReadResponse.JobDetails.CreatedOn, $RelativityArmArchiveJobReadResponse.JobDetails.ModifiedTime, $RelativityArmArchiveJobReadResponse.JobDetails.SubmittedBy, $RelativityArmArchiveJobReadResponse.JobDetails.State, $RelativityArmArchiveJobReadResponse.JobDetails.Priority, $RelativityArmArchiveJobActionsHistory)
        $RelativityArmArchiveJobMigratorOptions = [RelativityArmArchiveJobMigratorOptions]::New($RelativityArmArchiveJobReadResponse.MigratorOptions.IncludeDatabaseBackup, $RelativityArmArchiveJobReadResponse.MigratorOptions.IncludeDtSearch, $RelativityArmArchiveJobReadResponse.MigratorOptions.IncludeConceptualAnalytics, $RelativityArmArchiveJobReadResponse.MigratorOptions.IncludeStructuredAnalytics, $RelativityArmArchiveJobReadResponse.MigratorOptions.IncludeDataGrid)
        $RelativityArmArchiveJobFileOptions = [RelativityArmArchiveJobFileOptions]::New($RelativityArmArchiveJobReadResponse.FileOptions.IncludeRepositoryFiles, $RelativityArmArchiveJobReadResponse.FileOptions.IncludeLinkedFiles, $RelativityArmArchiveJobReadResponse.FileOptions.MissingFileBehavior)
        $RelativityArmArchiveJobProcessingOptions = [RelativityArmArchiveJobProcessingOptions]::New($RelativityArmArchiveJobReadResponse.FileOptions.IncludeProcessing, $RelativityArmArchiveJobReadResponse.FileOptions.IncludeProcessingFiles, $RelativityArmArchiveJobReadResponse.FileOptions.ProcessingMissingFileBehavior)
        $RelativityArmArchiveJobExtendedWorkspaceDataOptions = [RelativityArmArchiveJobExtendedWorkspaceDataOptions]::New($RelativityArmArchiveJobReadResponse.ExtendedWorkspaceDataOptions.IncludeExtendedWorkspaceData, $RelativityArmArchiveJobReadResponse.ExtendedWorkspaceDataOptions.ApplicationErrorExportBehavior)
        $RelativityArmArchiveJobNotificationOptions = [RelativityArmArchiveJobNotificationOptions]::New($RelativityArmArchiveJobReadResponse.NotificationOptions.NotifyJobCreator, $RelativityArmArchiveJobReadResponse.NotificationOptions.NotifyJobExecutor)

        return [RelativityArmArchiveJobReadResponse]::New($RelativityArmArchiveJobReadResponse.JobID, $RelativityArmArchiveJobReadResponse.JobName, $RelativityArmArchiveJobReadResponse.JobExecutionID, $RelativityArmArchiveJobReadResponse.JobExecutionGuid, $RelativityArmArchiveJobReadResponse.ArchivePath, $RelativityArmArchiveJobReadResponse.WorkspaceID, $RelativityArmArchiveJobReadResponse.ScheduledStartTime, $RelativityArmArchiveJobDetails, $RelativityArmArchiveJobMigratorOptions, $RelativityArmArchiveJobFileOptions, $RelativityArmArchiveJobProcessingOptions, $RelativityArmArchiveJobExtendedWorkspaceDataOptions, $RelativityArmArchiveJobNotificationOptions, $RelativityArmArchiveJobReadResponse.UiJobActionsLocked)
    }
}

<#
.SYNOPSIS
Updates settings for a Relativity ARM Archive Job.

.DESCRIPTION
The function constructs a request to update an existing ARM archive job in Relativity.
It allows for extensive configuration through various parameters, enabling users to specify
details like the workspace ArtifactId, job priority, file options, and more.
If job creation is successful the response will be a status code of 200.
If the job creation could not be completed the response will contain validation errors with more detailed information.

.PARAMETER WorkspaceID
The ArtifactId of the workspace to archive for the archive job. This is a mandatory parameter.
This workspace must not be in the process of upgrading or currently in use by another ARM job.

.PARAMETER JobPriority
Priority of execution for the job. Possible options include "Low", "Medium", and "High".
Default is "Medium".

.PARAMETER ArchiveDirectory
File path of the configured archive directory to save the archive to.
When this is set UseDefaultArchiveDirectory has to be false.

.PARAMETER ScheduledStartTime
Scheduled time when the job will be run.

.PARAMETER IncludeDatabaseBackup
Indicates if the workspace database backup is included in the archive.

.PARAMETER IncludeDtSearch
Indicates whether dtSearch indices will be included in the archive directory.

.PARAMETER IncludeConceptualAnalytics
Indicates whether Conceptual Analytics indices will be included in the archive directory.

.PARAMETER IncludeStructuredAnalytics
Indicates whether Structured Analytics sets will be included in the archive directory.

.PARAMETER IncludeDataGrid
Indicates whether Data Grid application data will be present in the archive directory.

.PARAMETER IncludeRepositoryFiles
 Indicates whether all files included in the workspace repository, including files from file fields, will be archived in the archive directory.

.PARAMETER IncludeLinkedFiles
Indicates whether all linked files that do not exist in the workspace file repository will be archived in the archive directory.

.PARAMETER MissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing files are detected during the archiving process.
If there is potential for any files to not be found while the job is running, skipping them will result in compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the expected location.
Default is "SkipFile".

.PARAMETER IncludeProcessing
Indicates whether Processing application data will be present in the archive directory.

.PARAMETER IncludeProcessingFiles
Indicates whether all the files and containers that have been discovered by Processing will be archived and placed in the Invariant directory.

.PARAMETER ProcessingMissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing Processing files are detected during the archiving process.
If there is potential for any files to not be found while the job is running, skipping them will result in compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the expected location.
Default is "SkipFile".

.PARAMETER IncludeExtendedWorkspaceData
 Indicates whether extended workspace information is included in the archive.
 This includes installed applications, linked relativity scripts, and non-application event handlers.

.PARAMETER ApplicationErrorExportBehavior
Indicates whether to skip applications that errored during export ("SkipApplication") or to stop ("StopJob").
Default is "SkipApplication".

.PARAMETER NotifyJobCreator
Indicates if email notifications will be sent to the job creator.

.PARAMETER NotifyJobExecutor
Indicates if email notifications will be sent to the job executor.

.PARAMETER UiJobActionsLocked
Indicates if job actions normally available on UI should be visible for the user.
This behavior can be override by adding boolean instance setting OverrideUiJobActionsLock.

.PARAMETER UseDefaultArchiveDirectory
When this option is set to true leave ArchiveDirectory empty.
ARM will select the fist valid one from configuration.

.EXAMPLE
Set-RelativityArmArchiveJob -JobID 54 -WorkspaceId 1234567 -ArchiveDirectory "\\server\path" -IncludeDatabaseBackup

This example updates the existing archive job with JobID 54 to a workspace with the ArtifactId 1234567 in the specified directory and includes a database backup.

.EXAMPLE
Set-RelativityArmArchiveJob -JobID 54 -WorkspaceId 1234567 -IncludeDatabaseBackup -IncludeRepositoryFiles -UseDefaultArchiveDirectory

This example updates the existing archive job with JobID 54 to a workspace with the ArtifactId 1234567 using the default archive directory and includes a database backup and repository files.

.NOTES
Ensure you have connectivity and appropriate permissions in Relativity before running this function.
#>
function Set-RelativityArmArchiveJob
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [Int32] $JobID,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Int32] $WorkspaceID,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $JobPriority = "Medium",
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String] $ArchiveDirectory,
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
        [Switch] $IncludeDatabaseBackup,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDtSearch,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeConceptualAnalytics,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeStructuredAnalytics,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDataGrid,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeRepositoryFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeLinkedFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $MissingFileBehavior = "SkipFile",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessing,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessingFiles,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ProcessingMissingFileBehavior = "SkipFile",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeExtendedWorkspaceData,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ApplicationErrorExportBehavior = "SkipApplication",
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobCreator,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobExecutor,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UiJobActionsLocked,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UseDefaultArchiveDirectory
    )
    Process
    {
        $MigratorOptions = [RelativityArmArchiveJobMigratorOptions]::New($IncludeDatabaseBackup, $IncludeDtSearch, $IncludeConceptualAnalytics, $IncludeStructuredAnalytics, $IncludeDataGrid)
        $FileOptions = [RelativityArmArchiveJobFileOptions]::New($IncludeRepositoryFiles, $IncludeLinkedFiles, $MissingFileBehavior)
        $ProcessingOptions = [RelativityArmArchiveJobProcessingOptions]::New($IncludeProcessing, $IncludeProcessingFiles, $ProcessingMissingFileBehavior)
        $ExtendedWorkspaceDataOptions = [RelativityArmArchiveJobExtendedWorkspaceDataOptions]::New($IncludeExtendedWorkspaceData, $ApplicationErrorExportBehavior)
        $NotificationOptions = [RelativityArmArchiveJobNotificationOptions]::New($NotifyJobCreator, $NotifyJobExecutor)

        $RelativityArmArchiveJobUpdateRequest = [RelativityArmArchiveJobUpdateRequest]::New($WorkspaceID, $JobPriority, $ArchiveDirectory, $ScheduledStartTime, $MigratorOptions, $FileOptions, $ProcessingOptions, $ExtendedWorkspaceDataOptions, $NotificationOptions, $UiJobActionsLocked, $UseDefaultArchiveDirectory)

        $RelativityApiRequestBody =
        @{
            request = $RelativityArmArchiveJobUpdateRequest.ToHashTable()
        }

        $RelativityApiEndpointExtended = "archive-jobs/$($JobID)"

        return Invoke-RelativityApiRequest -RelativityBusinessDomain "ARM" -RelativityApiEndpointExtended $RelativityApiEndpointExtended -RelativityApiHttpMethod "Put" -RelativityApiRequestBody $RelativityApiRequestBody
    }
}