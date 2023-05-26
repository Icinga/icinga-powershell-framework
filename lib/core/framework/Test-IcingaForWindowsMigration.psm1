function Test-IcingaForWindowsMigration()
{
    param (
        [Version]$MigrationVersion = $null
    );

    if ($null -eq $MigrationVersion) {
        return $FALSE;
    }

    [string]$CurrentFrameworkRoot     = Get-IcingaFrameworkRootPath;
    [array]$ListOfFrameworks          = (Get-Module -ListAvailable -Name icinga-powershell-framework);
    [Version]$CurrentFrameworkVersion = $ListOfFrameworks[0].Version;
    [string]$MigrationConfigPath      = [string]::Format('Framework.Migrations.{0}', $MigrationVersion.ToString().Replace('.', ''));
    $VersionMigrationApplied          = Get-IcingaPowerShellConfig -Path $MigrationConfigPath;

    if ($ListOfFrameworks.Count -gt 1) {
        Write-IcingaConsoleWarning -Message 'Found multiple installations of the module "icinga-powershell-framework". Please check the list below and cleanup your installation to ensure system integrity'
        foreach ($entry in $ListOfFrameworks) {
            Write-Host ([string]::Format(' => Path "{0}" with version "{1}"', $entry.ModuleBase, $entry.Version));

            # Ensure we use the correct version of the framework loaded within this session
            if ($CurrentFrameworkRoot -eq $entry.ModuleBase) {
                $CurrentFrameworkVersion = $entry.Version;
            }
        }

        Write-IcingaConsoleWarning -Message 'This instance of Icinga for Windows will run with Framework version "{0}"' -Objects $CurrentFrameworkVersion.ToString();
    }

    # Migration for this version is already applied
    if ($VersionMigrationApplied) {
        return $FALSE;
    }

    if ($CurrentFrameworkVersion -ge $MigrationVersion) {
        return $TRUE;
    }

    return $FALSE;
}
