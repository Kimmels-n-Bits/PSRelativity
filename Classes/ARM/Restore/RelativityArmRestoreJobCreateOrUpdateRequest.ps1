class RelativityArmRestoreJobOptions : RelativityArmRestoreJobBase
{
    [String] $JobPriority
    [RelativityArmRestoreJobUserMappingOption] $UserMapping
    [RelativityArmRestoreJobGroupMappingOption] $GroupMapping

    RelativityArmRestoreJobOptions(
        [String] $archivePath,
        [String] $jobPriority,
        [String] $scheduledStartTime,
        [String] $existingTargetDatabase,
        [RelativityArmRestoreJobDestinationOptions] $destinationOptions,
        [RelativityArmRestoreJobMigratorsDestinationOptions] $migratorsDestinationOptions,
        [RelativityArmRestoreJobAdvancedFileOptions] $advancedFileOptions,
        [RelativityArmRestoreJobUserMappingOption] $userMapping,
        [RelativityArmRestoreJobGroupMappingOption] $groupMapping,
        [RelativityArmRestoreJobApplication[]] $applications,
        [RelativityArmJobNotificationOptions] $notificationOptions,
        [Boolean] $uiJobActionsLocked
    ): base(
        $archivePath,
        $scheduledStartTime,
        $existingTargetDatabase,
        $destinationOptions,
        $migratorsDestinationOptions,
        $advancedFileOptions,
        $applications,
        $notificationOptions,
        $uiJobActionsLocked
    )
    {
        $this.JobPriority = $jobPriority
        $this.UserMapping = $userMapping
        $this.GroupMapping = $groupMapping
    }

    [Hashtable] ToHashTable()
    {
        $ReturnValue = ([RelativityArmRestoreJobBase] $this).ToHashTable()

        $ReturnValue.Add("JobPriority", $this.JobPriority)
        $ReturnValue.Add("UserMapping", $this.UserMapping.ToHashTable())
        $ReturnValue.Add("GroupMapping", $this.GroupMapping.ToHashTable())

        return $ReturnValue
    }
}

class RelativityArmRestoreJobCreateOrUpdateRequest
{
    [RelativityArmRestoreJobOptions] $Request

    RelativityArmRestoreJobCreateOrUpdateRequest(
        [RelativityArmRestoreJobOptions] $request
    )
    {
        $this.Request = $request
    }

    [Hashtable] ToHashTable()
    {
        $ReturnValue = @{}
        
        $ReturnValue.Add("Request", $this.Request.ToHashTable())

        return $ReturnValue
    }
}