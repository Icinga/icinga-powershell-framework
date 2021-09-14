function Enable-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    $Name = $Name.Replace('.', '-');

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $CurrentRepositories) {
        Write-IcingaConsoleError 'A repository with the name "{0}" is not configured' -Objects $Name;
        return;
    }

    if ($CurrentRepositories.Enabled -eq $TRUE) {
        Write-IcingaConsoleNotice 'The repository "{0}" is already enabled' -Objects $Name;
        return;
    }

    Set-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}.Enabled', $Name)) -Value $TRUE;

    Write-IcingaConsoleNotice 'The repository "{0}" was successfully enabled' -Objects $Name;
}
