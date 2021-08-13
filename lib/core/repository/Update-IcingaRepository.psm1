function Update-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$Path       = $null,
        [string]$RemotePath = $null,
        [switch]$CreateNew  = $FALSE,
        [switch]$ForceTrust = $FALSE
    );

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    [array]$ConfigCount = $CurrentRepositories.PSObject.Properties.Count;

    if (($null -eq $CurrentRepositories -Or $ConfigCount.Count -eq 0) -And $CreateNew -eq $FALSE) {
        Write-IcingaConsoleNotice 'There are no repositories configured yet. You can create a custom repository with "New-IcingaRepository" or clone an existing one with "Sync-IcingaForWindowsRepository"';
        return;
    }

    if ([string]::IsNullOrEmpty($Name) -eq $FALSE) {
        if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -eq $FALSE -And $CreateNew -eq $FALSE) {
            Write-IcingaConsoleError 'A repository with the given name "{0}" does not exist. Use "New-IcingaRepository" or "Sync-IcingaForWindowsRepository" to create a new one.' -Objects $Name;
            return;
        }
    }

    foreach ($definedRepo in $CurrentRepositories.PSObject.Properties) {

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $definedRepo.Name.ToLower() -ne $Name.ToLower()) {
            continue;
        }

        if ($definedRepo.Value.Enabled -eq $FALSE) {
            Write-IcingaConsoleNotice 'Skipping disabled repository "{0}"' -Objects $definedRepo.Name;
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.CloneSource) -eq $FALSE) {
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.LocalPath)) {
            continue;
        }

        if ((Test-Path $definedRepo.Value.LocalPath) -eq $FALSE) {
            if ($CreateNew) {
                return $null;
            }
            continue;
        }

        $Path = Join-Path -Path $definedRepo.Value.LocalPath -ChildPath '\';

        if ($CreateNew -eq $FALSE) {
            Write-IcingaConsoleNotice 'Updating Icinga for Windows repository "{0}"' -Objects $definedRepo.Name;
        }

        $IcingaRepository = New-IcingaRepositoryFile -Path $Path -RemotePath $RemotePath;

        if ($CreateNew) {
            return $IcingaRepository;
        }
    }

    # Always sync repositories at the end, in case we updated a local repository and cloned it to somewhere else
    foreach ($definedRepo in $CurrentRepositories.PSObject.Properties) {

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $definedRepo.Name.ToLower() -ne $Name.ToLower()) {
            continue;
        }

        if ($definedRepo.Value.Enabled -eq $FALSE) {
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.LocalPath)) {
            continue;
        }

        Write-IcingaConsoleNotice 'Syncing repository "{0}"' -Objects $definedRepo.Name;

        if ([string]::IsNullOrEmpty($definedRepo.Value.CloneSource) -eq $FALSE) {
            Sync-IcingaRepository `
                -Name $definedRepo.Name `
                -Path $definedRepo.Value.LocalPath `
                -RemotePath $definedRepo.Value.RemotePath `
                -Source $definedRepo.Value.CloneSource `
                -UseSCP:$definedRepo.Value.UseSCP `
                -Force `
                -ForceTrust:$ForceTrust;

            return;
        }
    }

    Write-IcingaConsoleNotice 'All Icinga for Windows repositories were successfully updated';
}
