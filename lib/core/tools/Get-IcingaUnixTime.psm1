function Get-IcingaUnixTime()
{
    return [int][double]::Parse((Get-Date -UFormat %s))
}
