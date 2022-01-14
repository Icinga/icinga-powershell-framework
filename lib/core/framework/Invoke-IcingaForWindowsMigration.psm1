function Invoke-IcingaForWindowsMigration()
{
    # Upgrade to v1.8.0
    if ((Get-Module -ListAvailable -Name icinga-powershell-framework).Version -ge (New-IcingaVersionObject -Version '1.8.0')) {
        Write-IcingaConsoleNotice 'Applying pending migrations required for Icinga for Windows v1.8.0';

        $ApiChecks = Get-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks';

        if ($null -ne $ApiChecks) {
            Remove-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' | Out-Null;
            Set-IcingaPowerShellConfig -Path 'Framework.ApiChecks' -Value $ApiChecks;
        }
    }
}
