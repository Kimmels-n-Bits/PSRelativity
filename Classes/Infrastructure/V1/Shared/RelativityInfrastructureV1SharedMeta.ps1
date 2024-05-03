class RelativityInfrastructureV1SharedMeta
{
    <#
        .SYNOPSIS
            A collection of information about properties on a given object.
        .PARAMETER ReadOnly
            A list of properties on the given object that cannot be updated.
        .PARAMETER Unsupported
            A list of properties on the object that are not supported on the given object instance.
    #>
    [Collections.Generic.List[String]] $ReadOnly
    [Collections.Generic.List[String]] $Unsupported

    RelativityInfrastructureV1SharedMeta()
    {
    }

    RelativityInfrastructureV1SharedMeta(
        [Collections.Generic.List[String]] $ReadOnly,
        [Collections.Generic.List[String]] $Unsupported
    )
    {
        $this.ReadOnly = $ReadOnly
        $this.Unsupported = $Unsupported
    }
}