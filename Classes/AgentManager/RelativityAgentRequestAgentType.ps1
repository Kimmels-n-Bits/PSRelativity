class RelativityAgentRequestAgentType {
    [ValidateNotNull()]
    [Boolean] $Secured
    [ValidateNotNull()]
    [Int32] $Value

    RelativityAgentRequestAgentType([Boolean] $secured, [Int32] $value)
    {
        $this.Secured = $secured
        $this.Value = $value
    }

    [Hashtable] ToHashTable()
    {
        return @{
            Secured = $this.Secured
            Value = @{ ArtifactID = $this.Value.ToString() }
        }
    }
}
