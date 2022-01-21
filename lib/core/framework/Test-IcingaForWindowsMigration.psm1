function Test-IcingaForWindowsMigration()
{
    param (
        [Version]$MigrationVersion = $null
    );

    if ($null -eq $MigrationVersion) {
        return $FALSE;
    }

    [Version]$CurrentFrameworkVersion = (Get-Module -ListAvailable -Name icinga-powershell-framework).Version;
    [string]$MigrationConfigPath      = [string]::Format('Framework.Migrations.{0}', $MigrationVersion.ToString().Replace('.', ''));
    $VersionMigrationApplied          = Get-IcingaPowerShellConfig -Path $MigrationConfigPath;

    # Migration for this version is already applied
    if ($VersionMigrationApplied) {
        return $FALSE;
    }

    if ($CurrentFrameworkVersion -ge $MigrationVersion) {
        return $TRUE;
    }

    return $FALSE;
}
