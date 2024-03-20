function Install-IcingaAgent()
{
    param(
        [string]$Version,
        [string]$Source     = 'https://packages.icinga.com/windows/',
        [string]$InstallDir = '',
        [bool]$AllowUpdates = $FALSE
    );

    if ([string]::IsNullOrEmpty($Version)) {
        Write-IcingaConsoleError 'No Icinga Agent version specified. Skipping installation.';
        return $FALSE;
    }

    if ($IcingaData.Installed -eq $TRUE -and $AllowUpdates -eq $FALSE) {
        Write-IcingaConsoleWarning 'The Icinga Agent is already installed on this system. To perform updates or downgrades, please add the "-AllowUpdates" argument';
        return $FALSE;
    }

    $IcingaData       = Get-IcingaAgentInstallation;
    $InstalledVersion = Get-IcingaAgentVersion;
    $IcingaInstaller  = Get-IcingaAgentMSIPackage -Source $Source -Version $Version -SkipDownload;
    $InstallTarget    = $IcingaData.RootDir;

    if ($Version -eq 'snapshot') {
        if ($IcingaData.InstallDate -ge $IcingaInstaller.LastUpdate -And [string]::IsNullOrEmpty($InstalledVersion.Snapshot) -eq $FALSE) {
            Write-IcingaConsoleNotice 'There is no new snapshot package available which requires to be installed.'
            return $FALSE;
        }
        $IcingaInstaller.Version = 'snapshot';
    } elseif ($IcingaInstaller.Version -eq $InstalledVersion.Full) {
        Write-IcingaConsoleNotice (
            [string]::Format(
                'No installation required. Your installed version [{0}] is matching the online version [{1}]',
                $InstalledVersion.Full,
                $IcingaInstaller.Version
            )
        );
        return $FALSE;
    }

    $IcingaInstaller = Get-IcingaAgentMSIPackage -Source $Source -Version $IcingaInstaller.Version;

    if ((Test-Path $IcingaInstaller.InstallerPath) -eq $FALSE) {
        throw 'Failed to locate Icinga Agent installer file';
    }

    if ([string]::IsNullOrEmpty($InstallDir) -eq $FALSE) {
        if ((Test-Path $InstallDir) -eq $FALSE) {
            New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null;
        }
        $InstallTarget = $InstallDir;
    }

    [string]$InstallFolderMsg = $InstallTarget;

    if ([string]::IsNullOrEmpty($InstallTarget) -eq $FALSE) {
        $InstallTarget = [string]::Format(' INSTALL_ROOT="{0}"', $InstallTarget);
    } else {
        $InstallTarget = '';
        if ($IcingaData.Architecture -eq 'x86') {
            $InstallFolderMsg = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'ICINGA2';
        } else {
            $InstallFolderMsg = Join-Path -Path $env:ProgramFiles -ChildPath 'ICINGA2';
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Installing new Icinga Agent version into "{0}"', $InstallFolderMsg));

    if ($IcingaData.Installed) {
        if ((Uninstall-IcingaAgent) -eq $FALSE) {
            return $FALSE;
        }
    }

    $InstallProcess = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('/quiet /i "{0}" {1}', $IcingaInstaller.InstallerPath, $InstallTarget)) -FlushNewLines;

    if ($InstallProcess.ExitCode -ne 0) {
        Write-IcingaConsoleError -Message 'Failed to install Icinga 2 Agent: {0}{1}' -Objects $InstallProcess.Message, $InstallProcess.Error;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Icinga Agent was successfully installed';
    return $TRUE;
}
