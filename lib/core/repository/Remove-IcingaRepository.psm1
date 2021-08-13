function Remove-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository to remove';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -eq $FALSE) {
        Write-IcingaConsoleError 'A repository with the name "{0}" is not configured' -Objects $Name;
        return;
    }

    Push-IcingaRepository -Name $Name -Silent;

    Remove-IcingaPowerShellConfig -Path (
        [string]::Format(
            'Framework.Repository.Repositories.{0}',
            $Name
        )
    );

    Write-IcingaConsoleNotice 'The repository with the name "{0}" was successfully removed' -Objects $Name;
}
