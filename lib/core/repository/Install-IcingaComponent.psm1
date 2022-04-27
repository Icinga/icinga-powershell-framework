function Install-IcingaComponent()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE,
        [switch]$Confirm  = $FALSE,
        [switch]$Force    = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';
        return;
    }

    # Branch snapshot versions will have '/' inside their name
    if ($Name.Contains('/') -And $Snapshot) {
        $Name = $Name.Split('/')[0];
    }

    Set-IcingaTLSVersion;

    if ($Version -eq 'release') {
        $Version = $null;
    }

    if ($Release -eq $TRUE -And $Snapshot -eq $TRUE) {
        Write-IcingaConsoleError 'You can only select either "Release" or "Snapshot" channel for package installation';
        return;
    }

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $LockedVersion = Get-IcingaComponentLock -Name $Name;

    if ($null -ne $LockedVersion) {
        $Version = $LockedVersion;
        Write-IcingaConsoleNotice 'Component "{0}" is locked to version "{1}"' -Objects $Name, $LockedVersion;
    }

    $PackageContent = Get-IcingaRepositoryPackage -Name $Name -Version $Version -Release:$Release -Snapshot:$Snapshot;
    $InstallPackage = $PackageContent.Package;
    $SourceRepo     = $PackageContent.Source;
    $RepoName       = $PackageContent.Repository;

    if ($PackageContent.HasPackage -eq $FALSE) {
        $SearchVersion = 'release';
        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            $SearchVersion = $Version;
        }
        if ($Release) {
            Write-IcingaConsoleError 'The component "{0}" was not found on stable channel with version "{1}"' -Objects $Name, $SearchVersion;
            return;
        }
        if ($Snapshot) {
            Write-IcingaConsoleError 'The component "{0}" was not found on snapshot channel with version "{1}"' -Objects $Name, $SearchVersion;
            return;
        }
        return;
    }

    $FileSource = $InstallPackage.Location;

    if ($InstallPackage.RelativePath -eq $TRUE) {
        $FileSource = Join-WebPath -Path ($SourceRepo.Info.RemoteSource.Replace('\', '/')) -ChildPath ($InstallPackage.Location.Replace('\', '/'));
    }

    if ($Confirm -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to install component "{0}" from source "{1}" ({2})?', $Name.ToLower(), $RepoName, $FileSource)) -Default 'y').result -ne 1) {
            return;
        }
    }

    $FileName            = $FileSource.SubString($FileSource.LastIndexOf('/') + 1, $FileSource.Length - $FileSource.LastIndexOf('/') - 1);
    $DownloadDirectory   = New-IcingaTemporaryDirectory;
    $DownloadDestination = (Join-Path -Path $DownloadDirectory -ChildPath $FileName);

    Write-IcingaConsoleNotice ([string]::Format('Downloading "{0}" from "{1}"', $Name.ToLower(), $FileSource));

    if ((Invoke-IcingaWebRequest -UseBasicParsing -Uri $FileSource -OutFile $DownloadDestination).HasErrors) {
        Write-IcingaConsoleError ([string]::Format('Failed to download "{0}" from "{1}" into "{2}". Starting cleanup process', $Name.ToLower(), $FileSource, $DownloadDestination));
        Start-Sleep -Seconds 2;
        Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;

        return;
    }

    $FileHash = (Get-FileHash -Path $DownloadDestination -Algorithm SHA256).Hash;

    if ([string]::IsNullOrEmpty($InstallPackage.Hash) -eq $FALSE -And (Get-FileHash -Path $DownloadDestination -Algorithm SHA256).Hash -ne $InstallPackage.Hash) {
        Write-IcingaConsoleError ([string]::Format('File validation failed. The stored hash inside the repository "{0}" is not matching the file hash "{1}"', $InstallPackage.Hash, $FileHash));
        return;
    }

    if ([IO.Path]::GetExtension($FileName) -eq '.zip') {
        <#
            Handles installation of Icinga for Windows packages and Icinga for Windows service
        #>

        Expand-IcingaZipArchive -Path $DownloadDestination -Destination $DownloadDirectory | Out-Null;
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDestination -Force;

        $FolderContent = Get-ChildItem -Path $DownloadDirectory -Recurse -Include '*.psd1';

        <#
            Handles installation of Icinga for Windows packages
        #>
        if ($null -ne $FolderContent -And $FolderContent.Count -ne 0) {
            $ManifestFile  = $null;
            $PackageName   = $null;
            $PackageRoot   = $null;

            foreach ($manifest in $FolderContent) {
                $ManifestFile = Read-IcingaPackageManifest -File $manifest.FullName;

                if ($null -ne $ManifestFile) {
                    $PackageName = $manifest.Name.Replace('.psd1', '');
                    $PackageRoot = $manifest.FullName.SubString(0, $manifest.FullName.LastIndexOf('\'));
                    $PackageRoot = Join-Path -Path $PackageRoot -ChildPath '\*'
                    break;
                }
            }

            if ($null -eq $ManifestFile) {
                Write-IcingaConsoleError ([string]::Format('Unable to read manifest for package "{0}". Aborting installation', $Name.ToLower()));
                Start-Sleep -Seconds 2;
                Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;
                return;
            }

            $ComponentFolder        = Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath $PackageName;
            $ModuleData             = (Get-Module -ListAvailable -Name $PackageName -ErrorAction SilentlyContinue) | Sort-Object Version -Descending | Select-Object Version -First 1;
            [string]$InstallVersion = $null;
            $ServiceStatus          = $null;
            $AgentStatus            = $null;

            if ($null -ne $ModuleData) {
                [string]$InstallVersion = $ModuleData.Version;
            }

            if ($ManifestFile.ModuleVersion -eq $InstallVersion -And $Force -eq $FALSE) {
                Write-IcingaConsoleWarning ([string]::Format('The package "{0}" with version "{1}" is already installed. Use "-Force" to re-install the component', $Name.ToLower(), $ManifestFile.ModuleVersion));
                Start-Sleep -Seconds 2;
                Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;
                return;
            }

            # These update steps only apply for the framework
            if ($Name.ToLower() -eq 'framework') {
                Remove-IcingaFrameworkDependencyFile;
                $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;
                $AgentStatus   = (Get-Service 'icinga2' -ErrorAction SilentlyContinue).Status;

                if ($ServiceStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Stopping Icinga for Windows service';
                    Stop-IcingaWindowsService;
                    Start-Sleep -Seconds 1;
                }
                if ($AgentStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Stopping Icinga Agent service';
                    Stop-IcingaService 'icinga2';
                    Start-Sleep -Seconds 1;
                }
            }

            if ((Test-Path $ComponentFolder) -eq $FALSE) {
                [void](New-Item -ItemType Directory -Path $ComponentFolder -Force);
            }

            $ComponentFileContent = Get-ChildItem -Path $ComponentFolder;

            foreach ($entry in $ComponentFileContent) {
                if (($entry.Name -eq 'cache' -Or $entry.Name -eq 'config' -Or $entry.Name -eq 'certificate') -And $Name.ToLower() -eq 'framework') {
                    continue;
                }

                [void](Remove-ItemSecure -Path $entry.FullName -Recurse -Force);
            }

            Copy-ItemSecure -Path $PackageRoot -Destination $ComponentFolder -Recurse -Force | Out-Null;

            Write-IcingaConsoleNotice 'Installing version "{0}" of component "{1}"' -Objects $ManifestFile.ModuleVersion, $Name.ToLower();

            Unblock-IcingaPowerShellFiles -Path $ComponentFolder;

            if ($Name.ToLower() -eq 'framework') {
                if (Test-IcingaFunction 'Write-IcingaFrameworkCodeCache') {
                    Write-IcingaFrameworkCodeCache;
                }

                Import-Module -Name $ComponentFolder -Force;
                Import-Module -Name $ComponentFolder -Force -Global;

                # Apply migration tasks
                Use-Icinga;

                if ($ServiceStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Starting Icinga for Windows service';
                    Start-IcingaService 'icingapowershell';
                }
                if ($AgentStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Starting Icinga Agent service';
                    Start-IcingaService 'icinga2';
                }
            } else {
                try {
                    Import-Module -Name $ComponentFolder -Force -ErrorAction Stop;
                    Import-Module -Name $ComponentFolder -Force -Global -ErrorAction Stop;

                    Write-IcingaConsoleNotice 'Installation of component "{0}" with version "{1}" was successful. Open a new PowerShell to apply the changes' -Objects $Name.ToLower(), $ManifestFile.ModuleVersion;
                } catch {
                    Write-IcingaConsoleError 'Component "{0}" has been installed with version "{1}", but while importing the component an exception was thrown: {2}' -Objects $Name.ToLower(), $ManifestFile.ModuleVersion, $_.Exception.Message;
                }
            }

            # This will ensure that Framework functions will always win over third party functions, overwriting functionality
            # of the Framework, which might cause problems during installation otherwise
            Import-Module (Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath 'icinga-powershell-framework') -Force;
            Import-Module (Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath 'icinga-powershell-framework') -Global -Force;
        } else {
            <#
                Handles installation of Icinga for Windows service
            #>

            $FolderContent = Get-ChildItem -Path $DownloadDirectory -Recurse -Include 'icinga-service.exe';

            if ($Name.ToLower() -eq 'service') {

                $ConfigDirectory  = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.IcingaForWindowsService';
                $ConfigUser       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
                $ServiceData      = Get-IcingaForWindowsServiceData;
                $ServiceDirectory = $ServiceData.Directory;
                $ServiceUser      = $ServiceData.User;
                [int]$Success     = -1;

                if ([string]::IsNullOrEmpty($ConfigDirectory) -eq $FALSE) {
                    $ServiceDirectory = $ConfigDirectory;
                }

                if ([string]::IsNullOrEmpty($ConfigUser) -eq $FALSE) {
                    $ServiceUser = $ConfigUser;
                } else {
                    Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -Value $ServiceUser;
                }

                foreach ($binary in $FolderContent) {

                    if ((Test-IcingaZipBinaryChecksum -Path $binary.FullName) -eq $FALSE) {
                        Write-IcingaConsoleError 'The checksum for the given service binary does not match';
                        continue;
                    }

                    if ((Test-Path $ServiceDirectory) -eq $FALSE) {
                        [void](New-Item -ItemType Directory -Path $ServiceDirectory -Force);
                    }

                    $UpdateBin  = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe.update';
                    $ServiceBin = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe';

                    # Service is already installed
                    if (Test-Path $ServiceBin) {
                        $InstalledService = Read-IcingaServicePackage -File $ServiceBin;
                        $NewService       = Read-IcingaServicePackage -File $binary.FullName;

                        if ($InstalledService.ProductVersion -eq $NewService.ProductVersion -And $null -ne $InstalledService -And $null -ne $NewService -And $Force -eq $FALSE) {
                            $Success = 0;
                            break;
                        }
                    }

                    Write-IcingaConsoleNotice 'Installing component "service" into "{0}"' -Objects $ServiceDirectory;

                    Copy-ItemSecure -Path $binary.FullName -Destination $UpdateBin -Force | Out-Null;

                    [void](Install-IcingaForWindowsService -Path $ServiceBin -User $ServiceUser -Password (Get-IcingaInternalPowerShellServicePassword));
                    Update-IcingaServiceUser;
                    Set-IcingaInternalPowerShellServicePassword -Password $null;
                    $Success = 1;
                    break;
                }

                if ($Success -eq 0) {
                    Write-IcingaConsoleWarning ([string]::Format('The package "service" with version "{0}" is already installed. Use "-Force" to re-install the component', $InstalledService.ProductVersion));
                    Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;

                    return;
                }

                if ($Success -eq 1) {
                    Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;
                    Write-IcingaConsoleNotice 'Installation of component "service" was successful';

                    return;
                }

                Write-IcingaConsoleError 'Failed to install component "service". Either the package did not include a service binary or the checksum of the binary did not match';
                Start-Sleep -Seconds 2;
                Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;
                return;
            } else {
                Write-IcingaConsoleError 'There was no manifest file found inside the package';
                Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force;
                return;
            }
        }
    } elseif ([IO.Path]::GetExtension($FileName) -eq '.msi') {

        <#
            Handles installation of Icinga Agent MSI Packages
        #>

        $IcingaData       = Get-IcingaAgentInstallation;
        $InstalledVersion = Get-IcingaAgentVersion;
        $InstallTarget    = $IcingaData.RootDir;
        $InstallDir       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation';
        $ConfigUser       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
        $ServiceUser      = $IcingaData.User;

        if ([string]::IsNullOrEmpty($InstallDir) -eq $FALSE) {
            if ((Test-Path $InstallDir) -eq $FALSE) {
                [void](New-Item -Path $InstallDir -ItemType Directory -Force);
            }
            $InstallTarget = $InstallDir;
        }

        if ([string]::IsNullOrEmpty($ConfigUser) -eq $FALSE) {
            $ServiceUser = $ConfigUser;
        } else {
            Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -Value $ServiceUser;
        }

        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation' -Value $InstallTarget;

        [string]$InstallFolderMsg = $InstallTarget;

        if ([string]::IsNullOrEmpty($InstallTarget) -eq $FALSE) {
            $InstallTarget = [string]::Format(' INSTALL_ROOT="{0}"', $InstallTarget);
        } else {
            $InstallTarget = '';
            if ($IcingaData.Architecture -eq 'x86') {
                $InstallFolderMsg = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'icinga2';
            } else {
                $InstallFolderMsg = Join-Path -Path $env:ProgramFiles -ChildPath 'icinga2';
            }
        }

        $MSIData = & powershell.exe -Command {
            $DownloadDestination = $args[0];
            return (Read-IcingaMSIMetadata -File $DownloadDestination);
        } -Args $DownloadDestination;

        if ($InstalledVersion.Full -eq $MSIData.ProductVersion -And $Force -eq $FALSE) {
            Write-IcingaConsoleWarning 'The package "agent" with version "{0}" is already installed. Use "-Force" to re-install the component' -Objects $InstalledVersion.Full;
            Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;

            return;
        }

        Write-IcingaConsoleNotice 'Installing component "agent" with version "{0}" into "{1}"' -Objects $MSIData.ProductVersion, $InstallFolderMsg;

        if ($IcingaData.Installed) {
            if ((Uninstall-IcingaAgent) -eq $FALSE) {
                return;
            }
        }

        $InstallProcess = & powershell.exe -Command {
            $DownloadDestination = $args[0];
            $InstallTarget       = $args[1];
            $InstallProcess      = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('/quiet /i "{0}" {1}', $DownloadDestination, $InstallTarget)) -FlushNewLines;

            Start-Sleep -Seconds 2;
            Optimize-IcingaForWindowsMemory;

            return $InstallProcess;
        } -Args $DownloadDestination, $InstallTarget;

        if ($InstallProcess.ExitCode -ne 0) {
            Write-IcingaConsoleError -Message 'Failed to install component "agent": {0}{1}' -Objects $InstallProcess.Message, $InstallProcess.Error;
            return $FALSE;
        }

        Reset-IcingaAgentConfigFile;
        Move-IcingaAgentDefaultConfig;

        Set-IcingaServiceUser -User $ServiceUser -SetPermission | Out-Null;
        Update-IcingaServiceUser;

        Write-IcingaConsoleNotice 'Installation of component "agent" with version "{0}" was successful.' -Objects $MSIData.ProductVersion;
    } else {
        Write-IcingaConsoleError ([string]::Format('Unsupported file extension "{0}" found for package "{1}". Aborting installation', ([IO.Path]::GetExtension($FileName)), $Name.ToLower()));
    }

    Remove-ItemSecure -Path $DownloadDirectory -Recurse -Force -Retries 5 | Out-Null;
}
