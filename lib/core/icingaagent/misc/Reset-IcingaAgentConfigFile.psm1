<#
.SYNOPSIS
   Checks for old configurations provided by the old PowerShell module
   and restores the original configuration file
.DESCRIPTION
   Restores the original Icinga 2 configuration by replacing the existing
   configuration created by the old PowerShell module with the plain one
   from the Icinga 2 backup file
.FUNCTIONALITY
   Restores original Icinga 2 configuration icinga2.conf
.EXAMPLE
   PS>Reset-IcingaAgentConfigFile;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Reset-IcingaAgentConfigFile()
{
    $ConfigDir       = Get-IcingaAgentConfigDirectory;
    $OldConfig       = Join-Path -Path $ConfigDir -ChildPath 'icinga2.conf';
    $OldConfigBackup = Join-Path -Path $ConfigDir -ChildPath 'icinga2.conf.old.module';
    $OriginalConfig  = Join-Path -Path $ConfigDir -ChildPath 'icinga2.confdirector.bak';

    if ((Test-Path $OriginalConfig)) {
        Write-IcingaConsoleWarning 'Found icinga2.conf backup file created by old PowerShell module. Restoring original configuration';

        Move-Item -Path $OldConfig      -Destination $OldConfigBackup;
        Move-Item -Path $OriginalConfig -Destination $OldConfig;
    }
}
