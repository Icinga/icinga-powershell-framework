function Get-IcingaComponentLock()
{
    param (
        [string]$Name    = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to get the lock version';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        return $null;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        return $LockedComponents.$Name;
    }

    return $null;
}
