function Set-IcingaForWindowsMigration()
{
    param (
        [Version]$MigrationVersion = $null
    );

    if ($null -eq $MigrationVersion) {
        return;
    }

    [string]$MigrationConfigPath = [string]::Format('Framework.Migrations.{0}', $MigrationVersion.ToString().Replace('.', ''));

    Set-IcingaPowerShellConfig -Path $MigrationConfigPath -Value $TRUE | Out-Null
}
