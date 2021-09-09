function Read-IcingaRepositoryFile()
{
    param (
        [string]$Name         = $null,
        [switch]$TryAlternate = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return $null;
    }

    $Repository = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $Repository) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does not exist. Use "New-IcingaRepository" or "Sync-IcingaForWindowsRepository" to create a new one.' -Objects $Name;
        return $null;
    }

    $RepoPath = $null;
    $Content  = $null;

    if ([string]::IsNullOrEmpty($Repository.LocalPath) -eq $FALSE -And (Test-Path -Path $Repository.LocalPath)) {
        $RepoPath = $Repository.LocalPath;
        $Content  = Get-Content -Path (Join-Path -Path $RepoPath -ChildPath 'ifw.repo.json') -Raw;
    } elseif ([string]::IsNullOrEmpty($Repository.RemotePath) -eq $FALSE -And (Test-Path -Path $Repository.RemotePath)) {
        $RepoPath = $Repository.RemotePath;
        $Content  = Get-Content -Path (Join-Path -Path $RepoPath -ChildPath 'ifw.repo.json') -Raw;
    } else {
        try {
            $RepoPath = $Repository.RemotePath;

            if ($TryAlternate) {
                $RepoPath = (Join-WebPath -Path $Repository.RemotePath -ChildPath 'ifw.repo.json');
            }

            $WebContent = Invoke-WebRequest -UseBasicParsing -Uri $RepoPath;

            if ($null -ne $WebContent) {
                if ($WebContent.RawContent.Contains('application/octet-stream')) {
                    $Content = [System.Text.Encoding]::UTF8.GetString($WebContent.Content)
                } else {
                    $Content = $WebContent.Content;
                }
            } else {
                if ($TryAlternate -eq $FALSE) {
                    return (Read-IcingaRepositoryFile -Name $Name -TryAlternate);
                }
            }
        } catch {
            if ($TryAlternate -eq $FALSE) {
                return (Read-IcingaRepositoryFile -Name $Name -TryAlternate);
            } else {
                Write-IcingaConsoleError 'Unable to resolve repository URL "{0}" for repository "{1}": {2}' -Objects $Repository.RemotePath, $Name, $_.Exception.Message;
                return $null;
            }
        }
    }

    if ($null -eq $Content) {
        Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
        return $null;
    }

    try {
        $RepositoryObject = ConvertFrom-Json -InputObject $Content -ErrorAction Stop;
    } catch {
        if ($TryAlternate -eq $FALSE) {
            return (Read-IcingaRepositoryFile -Name $Name -TryAlternate);
        }
    }

    return $RepositoryObject;
}
