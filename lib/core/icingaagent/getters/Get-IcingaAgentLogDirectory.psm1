function Get-IcingaAgentLogDirectory()
{
    return (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\log\icinga2\')
}
