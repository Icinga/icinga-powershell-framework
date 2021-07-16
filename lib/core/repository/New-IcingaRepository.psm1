function New-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$Path       = $null,
        [string]$RemotePath = $null,
        [switch]$Force      = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleWarning 'No explicit remote path has been defined. Using local path "{0}" as remote path' -Objects $Path;
        $RemotePath = $Path;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist. Use "Update-IcingaRepository -Name {1}{0}{1}" to update it.' -Objects $Name, "'";
        return;
    }

    $IcingaRepository = New-IcingaRepositoryFile -Path $Path -RemotePath $RemotePath;

    [array]$ConfigCount = $IcingaRepository.Packages.PSObject.Properties.Count;

    if ($ConfigCount.Count -eq 0) {
        Write-IcingaConsoleWarning 'Created empty repository at location "{0}"' -Objects $Path;
    }
    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $Path;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value $FALSE;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $True;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}
