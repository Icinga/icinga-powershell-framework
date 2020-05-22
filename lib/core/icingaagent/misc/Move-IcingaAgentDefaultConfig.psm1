function Move-IcingaAgentDefaultConfig()
{
    $ConfigDir  = Get-IcingaAgentConfigDirectory;
    $BackupFile = Join-Path -Path $ConfigDir -ChildPath 'ps_backup\backup_executed.key';

    if ((Test-Path $BackupFile)) {
        Write-IcingaConsoleNotice 'A backup of your default configuration is not required. A backup was already made';
        return;
    }

    New-Item (Join-Path -Path $ConfigDir -ChildPath 'ps_backup') -ItemType Directory | Out-Null;

    Move-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'conf.d') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\conf.d');
    Move-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'zones.conf') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\zones.conf');
    Copy-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'constants.conf') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\constants.conf');
    Copy-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'features-available') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\features-available');

    New-Item (Join-Path -Path $ConfigDir -ChildPath 'conf.d') -ItemType Directory | Out-Null;
    New-Item (Join-Path -Path $ConfigDir -ChildPath 'zones.conf') -ItemType File | Out-Null;
    New-Item -Path $BackupFile -ItemType File | Out-Null;

    Write-IcingaConsoleNotice 'Successfully backed up Icinga 2 Agent default config';
}
