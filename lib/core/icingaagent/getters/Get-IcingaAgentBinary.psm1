function Get-IcingaAgentBinary()
{
    $IcingaRootDir = Get-IcingaAgentRootDirectory;
    $IcingaBinary = (Join-Path -Path $IcingaRootDir -ChildPath '\sbin\icinga2.exe');

    if ((Test-Path $IcingaBinary) -eq $FALSE) {
        throw 'Icinga Agent binary could not be found';
    }

    return $IcingaBinary;
}
