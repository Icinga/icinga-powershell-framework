function Read-IcingaRepositoryFile()
{
    param (
        [string]$Name          = $null,
        [switch]$TryAlternate  = $FALSE,
        [switch]$PrintRetryMsg = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return $null;
    }

    if ((Test-IcingaRepositoryErrorState -Repository $Name) -And $TryAlternate -eq $FALSE) {
        return $null;
    }

    $Name = $Name.Replace('.', '-');

    $Repository = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $Repository) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does not exist. Use "New-IcingaRepository" or "Sync-IcingaForWindowsRepository" to create a new one.' -Objects $Name;
        return $null;
    }

    $RepoPath = $null;
    $Content  = $null;

    if ($PrintRetryMsg) {
        Write-IcingaConsoleNotice 'Unable to fetch Icinga for Windows repository information for repository "{0}" from provided location. Trying different lookup by adding "ifw.repo.json" to the end of the remote path.' -Objects $Name;
    }

    if ([string]::IsNullOrEmpty($Repository.LocalPath) -eq $FALSE -And (Test-Path -Path $Repository.LocalPath)) {
        $RepoPath = $Repository.LocalPath;
    } elseif ([string]::IsNullOrEmpty($Repository.RemotePath) -eq $FALSE -And (Test-Path -Path $Repository.RemotePath)) {
        $RepoPath = $Repository.RemotePath;
    }

    if ([string]::IsNullOrEmpty($RepoPath) -eq $FALSE -And (Test-Path -Path $RepoPath)) {

        if ($TryAlternate) {
            $RepoPath = Join-Path $RepoPath -ChildPath 'ifw.repo.json';
        }

        if ([IO.Path]::GetExtension($RepoPath).ToLower() -ne '.json' -And $TryAlternate -eq $FALSE) {
            return (Read-IcingaRepositoryFile -Name $Name -TryAlternate);
        } elseif ([IO.Path]::GetExtension($RepoPath).ToLower() -ne '.json' -And $TryAlternate) {
            Write-IcingaConsoleError 'Unable to read repository file from "{0}" for repository "{1}". No "ifw.repo.json" was found at defined location' -Objects $RepoPath, $Name;
            Add-IcingaRepositoryErrorState -Repository $Name;
            return $null;
        }

        $Content  = Get-Content -Path $RepoPath -Raw;
    } else {
        try {
            $RepoPath = $Repository.RemotePath;

            if ($TryAlternate) {
                $RepoPath = (Join-WebPath -Path $Repository.RemotePath -ChildPath 'ifw.repo.json');
            }

            $WebContent = Invoke-IcingaWebRequest -UseBasicParsing -Uri $RepoPath;

            if ($null -ne $WebContent) {
                if ((Test-PSCustomObjectMember -PSObject $WebContent -Name 'RawContent') -Or (Test-PSCustomObjectMember -PSObject $WebContent -Name 'Content')) {
                    if ((Test-PSCustomObjectMember -PSObject $WebContent -Name 'RawContent') -And $WebContent.RawContent.Contains('application/octet-stream')) {
                        $Content = [System.Text.Encoding]::UTF8.GetString($WebContent.Content)
                    } else {
                        $Content = $WebContent.Content;
                    }
                } else {
                    if ($TryAlternate -eq $FALSE) {
                        return (Read-IcingaRepositoryFile -Name $Name -TryAlternate -PrintRetryMsg);
                    }
                    $Content = $null;
                }
            } else {
                if ($TryAlternate -eq $FALSE) {
                    return (Read-IcingaRepositoryFile -Name $Name -TryAlternate -PrintRetryMsg);
                }
            }
        } catch {
            if ($TryAlternate -eq $FALSE) {
                return (Read-IcingaRepositoryFile -Name $Name -TryAlternate -PrintRetryMsg);
            } else {
                Write-IcingaConsoleError 'Unable to resolve repository URL "{0}" for repository "{1}": {2}' -Objects $Repository.RemotePath, $Name, $_.Exception.Message;
                return $null;
            }
        }
    }

    if ($null -eq $Content) {
        Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
        Add-IcingaRepositoryErrorState -Repository $Name;
        return $null;
    }

    $RepositoryObject = $null;

    if (Test-IcingaJSONObject -InputObject $Content) {
        $RepositoryObject = ConvertFrom-Json -InputObject $Content -ErrorAction Stop;
    } else {
        Write-IcingaConsoleError 'Failed to convert retreived content from repository "{0}" with location "{1}" to JSON' -Objects $Name, $Repository.RemotePath
        if ($TryAlternate -eq $FALSE) {
            return (Read-IcingaRepositoryFile -Name $Name -TryAlternate -PrintRetryMsg);
        }

        Add-IcingaRepositoryErrorState -Repository $Name;
    }

    return $RepositoryObject;
}
