function Get-IcingaAgentObjectList()
{
    $Binary     = Get-IcingaAgentBinary;
    $ObjectList = Start-IcingaProcess -Executable $Binary -Arguments 'object list';

    return $ObjectList.Message;
}
