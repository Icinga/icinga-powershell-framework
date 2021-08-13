function Read-IcingaRepositoryFile()
{
    param (
        [string]$Name = $null
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
        $RepoPath   = $Repository.RemotePath;
        $WebContent = Get-Content -Path (Join-Path -Path $RepoPath -ChildPath 'ifw.repo.json') -Raw;
    } else {
        try {
            $WebContent = Invoke-WebRequest -UseBasicParsing -Uri $Repository.RemotePath;
            $RepoPath   = $Repository.RemotePath;
        } catch {
            # Nothing to do
        }

        if ($null -eq $WebContent) {
            try {
                $WebContent = Invoke-WebRequest -UseBasicParsing -Uri (Join-WebPath -Path $Repository.RemotePath -ChildPath 'ifw.repo.json');
            } catch {
                Write-IcingaConsoleError 'Failed to read repository file from "{0}" or "{0}/ifw.repo.json". Exception: {1}' -Objects $Repository.RemotePath, $_.Exception.Message;
                return $null;
            }
            $RepoPath   = $Repository.RemotePath;
        }

        if ($null -eq $WebContent) {
            Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
            return $null;
        }

        if ($WebContent.RawContent.Contains('application/octet-stream')) {
            $Content = [System.Text.Encoding]::UTF8.GetString($WebContent.Content)
        } else {
            $Content = $WebContent.Content;
        }
    }

    if ($null -eq $Content) {
        Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
        return $null;
    }

    $RepositoryObject = ConvertFrom-Json -InputObject $Content;

    return $RepositoryObject;
}
