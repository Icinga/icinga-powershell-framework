function Unlock-IcingaComponent()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to unlock';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        Write-IcingaConsoleNotice 'You have currently no components which are locked configured';
        return;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        Remove-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.ComponentLock.{0}', $Name));
        Write-IcingaConsoleNotice 'Unlocking of component "{0}" was successful.' -Objects $Name;
    } else {
        Write-IcingaConsoleNotice 'The component "{0}" is not locked on this system' -Objects $Name;
    }
}
