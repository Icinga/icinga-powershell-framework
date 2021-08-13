function Lock-IcingaComponent()
{
    param (
        [string]$Name    = $null,
        [string]$Version = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to lock';
        return;
    }

    $Name = $Name.ToLower();
    if ([string]::IsNullOrEmpty($Version)) {
        if ($Name -eq 'agent') {
            $Version = (Get-IcingaAgentVersion).Full;
        } else {
            $ModuleData = Get-Module -ListAvailable -Name ([string]::Format('icinga-powershell-{0}', $Name)) -ErrorAction SilentlyContinue;

            if ($null -eq $ModuleData) {
                $ModuleData = Get-Module -ListAvailable -Name "*$Name*" -ErrorAction SilentlyContinue;
            }

            if ($null -ne $ModuleData) {
                $Version = $ModuleData.Version.ToString();
                $Name    = (Read-IcingaPackageManifest -File $ModuleData.Path).ComponentName;
            }
        }
    }

    if ([string]::IsNullOrEmpty($Version)) {
        Write-IcingaConsoleError 'Pinning the current version of component "{0}" is not possible, as it seems to be not installed. Please install the component first or manually specify version with "-Version"';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        $LockedComponents = New-Object -TypeName PSObject;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        $LockedComponents.$Name = $Version;
    } else {
        $LockedComponents | Add-Member -MemberType NoteProperty -Name $Name -Value $Version;
    }

    Write-IcingaConsoleNotice 'Locking of component "{0}" to version "{1}" successful. You can release the lock with "Unlock-IcingaComponent -Name {2}{0}{2}"' -Objects $Name, $Version, "'";

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock' -Value $LockedComponents;
}
