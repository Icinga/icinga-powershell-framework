function Add-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$RemotePath = $null,
        [switch]$Force      = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleError 'You have to provide a remote path for the repository';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    $RepoExists = Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name;

    if ($RepoExists -And $Force -eq $FALSE) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist. Use "-Force" to overwrite the current repository' -Objects $Name;
        return;
    } elseif ($RepoExists -And $Force) {
        Write-IcingaConsoleNotice 'Repository "{0}" is already registered. Forcing removal and re-adding it.' -Objects $Name;
        Remove-IcingaRepository -Name $Name;

        $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';
    }

    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value $FALSE;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $True;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
    Push-IcingaRepository -Name $Name -Silent;

    Write-IcingaConsoleNotice 'Remote repository "{0}" was successfully added' -Objects $Name;
}
