function Sync-IcingaRepository()
{
    param (
        [string]$Name         = $null,
        [string]$Path         = $null,
        [string]$RemotePath   = $null,
        [string]$Source       = $null,
        [switch]$UseSCP       = $FALSE,
        [switch]$Force        = $FALSE,
        [switch]$ForceTrust   = $FALSE,
        [switch]$SkipSCPMkdir = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ($UseSCP -And $null -eq (Get-Command 'scp' -ErrorAction SilentlyContinue) -And $null -eq (Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
        Write-IcingaConsoleWarning 'You cannot use SCP on this system, as SCP and/or SSH seem not to be installed';
        return;
    }

    if ($UseSCP -And $Path.Contains(':') -eq $FALSE -And $Path.Contains('@') -eq $FALSE) {
        Write-IcingaConsoleWarning 'You have to add host and username to your "-Path" argument. Example: "icinga@icinga.example.com:/var/www/icingarepo/" ';
        return;
    }

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE -And $UseSCP -eq $FALSE) {
        Write-IcingaConsoleWarning 'The provided path "{0}" does not exist and will be created' -Objects $Path;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleWarning 'No explicit remote path has been defined. Using local path "{0}" as remote path' -Objects $Path;
        $RemotePath = $Path;
    }

    if ([string]::IsNullOrEmpty($Source)) {
        Write-IcingaConsoleError 'You have to specify a source to sync from';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -And $Force -eq $FALSE) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist. Use "Update-IcingaRepository -Name {1}{0}{1}" to update it.' -Objects $Name, "'";
        return;
    }

    if ((Test-Path $Path) -eq $FALSE -And $UseSCP -eq $FALSE) {
        $FolderCreated = New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue;

        if ($null -eq $FolderCreated) {
            Write-IcingaConsoleError 'Unable to create repository folder at location "{0}". Please verify that you have permissions to write into the location and try again or create the folder manually' -Objects $Path;
            return;
        }
    }

    $RepoFile   = $null;
    $SSHAuth    = $null;
    $RemovePath = $null;

    if (Test-Path $Source) {
        $CopySource = Join-Path -Path $Source -ChildPath '\*';
    } else {
        $CopySource = $Source;
    }

    if ($UseSCP -eq $FALSE) {
        $Path       = Join-Path -Path $Path -ChildPath '\';
        $RemovePath = Join-Path -Path $Path -ChildPath '\*';
    } else {
        $SSHIndex = $Path.IndexOf(':');
        $SSHAuth  = $Path.Substring(0, $SSHIndex);
        $Path     = $Path.Substring($SSHIndex + 1, $Path.Length - $SSHIndex - 1);

        if ($Path[-1] -eq '/') {
            $RemovePath = [string]::Format('{0}*', $Path);
        } else {
            $RemovePath = [string]::Format('{0}/*', $Path);
        }
    }

    # All cloning will be done into a local file first
    $TmpDir               = New-IcingaTemporaryDirectory;
    $RepoFile             = (Join-Path -Path $TmpDir -ChildPath 'ifw.repo.json');
    [bool]$HasNonRelative = $FALSE;

    if (Test-Path $CopySource) { # Sync source is local path
        $Success = Copy-ItemSecure -Path $CopySource -Destination $TmpDir -Recurse -Force;
    } else { # Sync Source is web path
        $ProgressPreference = "SilentlyContinue";
        try {
            Invoke-WebRequest -USeBasicParsing -Uri $Source -OutFile $RepoFile;
        } catch {
            try {
                Invoke-WebRequest -USeBasicParsing -Uri (Join-WebPath -Path $Source -ChildPath 'ifw.repo.json') -OutFile $RepoFile;
            } catch {
                Write-IcingaConsoleError 'Unable to download repository file from "{0}". Exception: "{1}"' -Objects $Source, $_.Exception.Message;
                $Success = Remove-Item -Path $TmpDir -Recurse -Force;
                return;
            }
        }

        $RepoContent = Get-Content -Path $RepoFile -Raw;
        $JsonRepo    = ConvertFrom-Json -InputObject $RepoContent;

        foreach ($component in $JsonRepo.Packages.PSObject.Properties.Name) {
            $IfWPackage = $JsonRepo.Packages.$component

            foreach ($package in $IfWPackage) {
                $DownloadLink   = $package.Location;
                $TargetLocation = $TmpDir;

                if ($package.RelativePath -eq $TRUE) {
                    $DownloadLink   = Join-WebPath -Path $JsonRepo.Info.RemoteSource -ChildPath $package.Location;
                    $TargetLocation = Join-Path -Path $TmpDir -ChildPath $package.Location;

                    [void](
                        New-Item `
                            -ItemType Directory `
                            -Path (
                                $TargetLocation.SubString(
                                    0,
                                    $TargetLocation.LastIndexOf('\')
                                )
                            ) `
                            -Force
                        );
                } else {
                    $HasNonRelative = $TRUE;
                    $FileName       = $package.Location.Replace('/', '\');
                    $Index          = $FileName.LastIndexOf('\');
                    $FileName       = $FileName.SubString($Index, $FileName.Length - $Index);
                    $TargetLocation = Join-Path -Path $TmpDir -ChildPath $component;
                    [void](New-Item -ItemType Directory -Path $TargetLocation -Force);
                    $TargetLocation = Join-Path -Path $TargetLocation -ChildPath $FileName;
                }

                try {
                    Write-IcingaConsoleNotice 'Syncing repository component "{0}" as file "{1}" into temp directory' -Objects $component, $package.Location;
                    Invoke-WebRequest -USeBasicParsing -Uri $DownloadLink -OutFile $TargetLocation;
                } catch {
                    Write-IcingaConsoleError 'Failed to download repository component "{0}". Exception: "{1}"' -Objects $DownloadLink, $_.Exception.Message;
                    continue;
                }
            }
        }
    }

    [string]$CopySource = [string]::Format('{0}\*', $TmpDir);

    if ((Test-Path $RepoFile) -eq $FALSE) {
        Write-IcingaConsoleError 'The files from this repository were cloned but no repository file was found. Deleting temporary files';
        $Success = Remove-Item -Path $TmpDir -Recurse -Force;
        return;
    }

    $RepoContent = Get-Content -Path $RepoFile -Raw;
    $JsonRepo = ConvertFrom-Json -InputObject $RepoContent;

    if ($null -eq $JsonRepo) {
        Write-IcingaConsoleError 'The repository file was found but it is either damaged or empty. Deleting temporary files';
        $Success = Remove-Item -Path $TmpDir -Recurse -Force;
        return;
    }

    $EnableRepo = $TRUE;

    if ($ForceTrust -eq $FALSE -And $UseSCP -eq $FALSE) {
        if ($null -eq $JsonRepo.Info.RepoHash -Or [string]::IsNullOrEmpty($JsonRepo.Info.RepoHash)) {
            Write-IcingaConsoleWarning 'The cloned repository file hash cannot be verified, as it is not present inside the repository file. The repository will be added, but disabled for security reasons. Review the content first and ensure you trust the source before enabling it.';
            $EnableRepo = $FALSE;
        } elseif ($JsonRepo.Info.RepoHash -ne (Get-IcingaRepositoryHash -Path $TmpDir)) {
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            Write-IcingaConsoleError 'The repository hash for the cloned repository is not matching the file hash of the files inside. Removing repository data';
            return;
        }
    }

    if ($HasNonRelative) {
        [void](New-IcingaRepositoryFile -Path $TmpDir -RemotePath $RemotePath);
        $RepoContent = Get-Content -Path $RepoFile -Raw;
        $JsonRepo    = ConvertFrom-Json -InputObject $RepoContent;
        Start-Sleep -Seconds 2;
    }

    $JsonRepo.Info.RepoHash     = Get-IcingaRepositoryHash -Path $TmpDir;
    $JsonRepo.Info.LocalSource  = $Path;
    $JsonRepo.Info.RemoteSource = $RemotePath;
    $JsonRepo.Info.Updated      = ((Get-Date).ToUniversalTime().ToString('yyyy\/MM\/dd HH:mm:ss'));

    Write-IcingaFileSecure -File $RepoFile -Value (ConvertTo-Json -InputObject $JsonRepo -Depth 100);

    if ($UseSCP -eq $FALSE) { # Windows target
        $Success = Remove-Item -Path $RemovePath -Recurse -Force;
        $Success = Copy-ItemSecure -Path $CopySource -Destination $Path -Recurse -Force;

        if ($Success -eq $FALSE) {
            Write-IcingaConsoleError 'Unable to sync repository from location "{0}" to destination "{1}". Please verify that you have permissions to write into the location and try again or create the folder manually' -Objects $TmpDir, $Path;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }
    } else { # Linux target

        if ($SkipSCPMkdir -eq $FALSE) {
            Write-IcingaConsoleNotice 'Creating directory over SSH for host and user "{0}" and path "{1}"' -Objects $SSHAuth, $Path;

            $Result = Start-IcingaProcess -Executable 'ssh' -Arguments ([string]::Format('{0} mkdir -p "{1}"', $SSHAuth, $Path));
            if ($Result.ExitCode -ne 0) {
                # TODO: Add link to setup docs
                Write-IcingaConsoleError 'SSH Error on directory creation: {0}' -Objects $Result.Error;
                $Success = Remove-Item -Path $TmpDir -Recurse -Force;
                return;
            }
        }

        Write-IcingaConsoleNotice 'Removing old repository files from "{0}"' -Objects $Path;

        $Result = Start-IcingaProcess -Executable 'ssh' -Arguments ([string]::Format('{0} rm -Rf "{1}"', $SSHAuth, $RemovePath));

        if ($Result.ExitCode -ne 0) {
            Write-IcingaConsoleError 'SSH Error on removing old repository data: {0}' -Objects $Result.Error;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }

        Write-IcingaConsoleNotice 'Syncing new repository files to "{0}"' -Objects $Path;

        $Result = Start-IcingaProcess -Executable 'scp' -Arguments ([string]::Format('-r "{0}" "{1}:{2}"', $CopySource, $SSHAuth, $Path));

        if ($Result.ExitCode -ne 0) {
            Write-IcingaConsoleError 'SCP Error while copying repository files: {0}' -Objects $Result.Error;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }
    }

    $Success = Remove-Item -Path $TmpDir -Recurse -Force;

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -And $Force -eq $TRUE) {
        $CurrentRepositories.$Name.Enabled = $EnableRepo;
        Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
        Write-IcingaConsoleNotice 'Re-syncing of repository "{0}" was successful' -Objects $Name;
        return;
    }

    Write-IcingaConsoleNotice 'The repository was synced successfully. Use "Update-IcingaRepository" to sync possible changes from the source repository.';

    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $Path;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $Source;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value ([bool]$UseSCP);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $EnableRepo;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;

    return;
}
