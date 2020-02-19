function Get-IcingaAgentBinary()
{
    $IcingaRootDir = Get-IcingaAgentRootDirectory;
    if ([string]::IsNullOrEmpty($IcingaRootDir)) {
        throw 'The Icinga Agent seems not to be installed';
    }

    $IcingaBinary = (Join-Path -Path $IcingaRootDir -ChildPath '\sbin\icinga2.exe');

    if ((Test-Path $IcingaBinary) -eq $FALSE) {
        throw 'Icinga Agent binary could not be found';
    }

    return $IcingaBinary;
}
