function Write-IcingaAgentObjectList()
{
    param(
        [string]$Path
    );

    if ([string]::IsNullOrEmpty($Path)) {
        throw 'Please specify a path to write the Icinga objects to';
    }

    $ObjectList = Get-IcingaAgentObjectList;

    Write-IcingaFileSecure -File $Path -Value $ObjectList;
}
