function Get-IcingaAgentConfigDirectory()
{
    return (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\')
}
