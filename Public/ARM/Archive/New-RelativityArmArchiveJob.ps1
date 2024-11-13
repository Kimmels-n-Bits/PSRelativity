<#
.SYNOPSIS
Function to create a new Relativity ARM archive job using Relativity's REST API.

.DESCRIPTION
This function constructs the required request, calls Relativity's REST API, and processes the response to create a new
ARM archive job.

.PARAMETER ArtifactID
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
 Indicates whether all files included in the workspace repository, including files from file fields, will be archived
 in the archive directory.

.PARAMETER IncludeLinkedFiles
Indicates whether all linked files that do not exist in the workspace file repository will be archived in the archive
directory.

.PARAMETER MissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing files are detected during the archiving
process. If there is potential for any files to not be found while the job is running, skipping them will result in
compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the
expected location.
Default is "SkipFile".

.PARAMETER IncludeProcessing
Indicates whether Processing application data will be present in the archive directory.

.PARAMETER IncludeProcessingFiles
Indicates whether all the files and containers that have been discovered by Processing will be archived and placed in
the Invariant directory.

.PARAMETER ProcessingMissingFileBehavior
Indicates whether to skip ("SkipFile") or stop ("StopJob") when missing Processing files are detected during the
archiving process. If there is potential for any files to not be found while the job is running, skipping them will
result in compiling a downloadable list of the files that were missing and allow the job to complete without error.
Setting this to stop will immediately stop on the first missing file and cannot resume until the file is placed in the
expected location.
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
New-RelativityArmArchiveJob -ArtifactID 1234567 -ArchiveDirectory "\\server\path" -IncludeDatabaseBackup

This example creates a new archive job for workspace with the ArtifactId 1234567 in the specified directory and
includes a database backup.

.EXAMPLE
New-RelativityArmArchiveJob `
    -ArtifactID 1234567 `
    -IncludeDatabaseBackup `
    -IncludeRepositoryFiles `
    -UseDefaultArchiveDirectory

This example creates a new archive job for workspace with the ArtifactId 1234567 using the default archive directory
and includes a database backup and repository files.

.NOTES
Ensure you have connectivity and appropriate permissions in Relativity before running this function.
#>
function New-RelativityArmArchiveJob
{
    [CmdletBinding(SupportsShouldProcess)]
    Param
    (
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNull()]
        [ValidateRange(1000000, [Int32]::MaxValue)]
        [Int32] $ArtifactID,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("Low", "Medium", "High")]
        [String] $JobPriority = "Medium",
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [String] $ArchiveDirectory,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
                $date = "1970-01-01"
                [DateTime]::TryParse($_, [ref]$date)
                if ($_ -eq "") { return $true }
                elseif ($date -eq [DateTime]::MinValue) { throw "Invalid DateTime for ScheduledStartTime: $($_)." }
                $true
            })]
        [String] $ScheduledStartTime,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDatabaseBackup,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDtSearch,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeConceptualAnalytics,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeStructuredAnalytics,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeDataGrid,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeRepositoryFiles,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeLinkedFiles,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("SkipFile", "StopJob")]
        [String] $MissingFileBehavior = "SkipFile",
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessing,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeProcessingFiles,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("SkipFile", "StopJob")]
        [String] $ProcessingMissingFileBehavior = "SkipFile",
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $IncludeExtendedWorkspaceData,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet("SkipApplication", "StopJob")]
        [String] $ApplicationErrorExportBehavior = "SkipApplication",
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobCreator,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $NotifyJobExecutor,
        [Parameter(ParameterSetName = "ProvidedArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UiJobActionsLocked,
        [Parameter(ParameterSetName = "DefaultArchiveDirectory", Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
        [Switch] $UseDefaultArchiveDirectory
    )

    Begin
    {
        Write-Verbose "Starting New-RelativityArmArchiveJob"
    }
    Process
    {
        try
        {
            $Params = @{
                ArtifactID = $ArtifactID
                JobPriority = $JobPriority
                ArchiveDirectory = $ArchiveDirectory
                ScheduledStartTime = $ScheduledStartTime
                IncludeDatabaseBackup = $IncludeDatabaseBackup
                IncludeDtSearch = $IncludeDtSearch
                IncludeConceptualAnalytics = $IncludeConceptualAnalytics
                IncludeStructuredAnalytics = $IncludeStructuredAnalytics
                IncludeDataGrid = $IncludeDataGrid
                IncludeRepositoryFiles = $IncludeRepositoryFiles
                IncludeLinkedFiles = $IncludeLinkedFiles
                MissingFileBehavior = $MissingFileBehavior
                IncludeProcessing = $IncludeProcessing
                IncludeProcessingFiles = $IncludeProcessingFiles
                ProcessingMissingFileBehavior = $ProcessingMissingFileBehavior
                IncludeExtendedWorkspaceData = $IncludeExtendedWorkspaceData
                ApplicationErrorExportBehavior = $ApplicationErrorExportBehavior
                NotifyJobCreator = $NotifyJobCreator
                NotifyJobExecutor = $NotifyJobExecutor
                UiJobActionsLocked = $UiJobActionsLocked
                UseDefaultArchiveDirectory = $UseDefaultArchiveDirectory
            }

            $Request = Get-RelativityArmArchiveJobCreateOrUpdateRequest @Params

            $RequestBody = $Request.ToHashTable()

            [String[]] $Resources = @("archive-jobs")

            $ApiEndpoint = Get-RelativityApiEndpoint `
                -BusinessDomain "relativity-arm" `
                -Version "v1" `
                -Resources $Resources

            Write-Debug "Preparing to invoke POST method at Relativity API endpoint '$($ApiEndpoint)' with RequestBody $($RequestBody | ConvertTo-Json -Depth 10)"
            Write-Verbose "Invoking POST method at Relativity API endpoint: $($ApiEndpoint)"
            if ($PSCmdlet.ShouldProcess($ApiEndpoint))
            {
                $ApiResponse = Invoke-RelativityApiRequest `
                    -ApiEndpoint $ApiEndpoint `
                    -HttpMethod "Post" `
                    -RequestBody $RequestBody

                $Response = [RelativityArmJobCreateResponse]::New( [Int32] $ApiResponse )
                Write-Verbose "Successfully created ARM archive job with ID: $($Response.JobID)"
            }

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
        Write-Verbose "Completed New-RelativityArmArchiveJob"
    }
}