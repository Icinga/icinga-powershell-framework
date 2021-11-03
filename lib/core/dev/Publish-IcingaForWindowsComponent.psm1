<#
.SYNOPSIS
    Updates an Icinga for Windows component by updating the NestedModules entry
    of the manifest including documentation and provides an optional .zip file
    for usage within the Icinga for Windows repositories
.DESCRIPTION
    Updates an Icinga for Windows component by updating the NestedModules entry
    of the manifest including documentation and provides an optional .zip file
    for usage within the Icinga for Windows repositories
.PARAMETER Name
    The name of the Icinga for Windows component and module
.PARAMETER ReleasePackagePath
    The path on where the .zip file for release will be created at.
    Defaults to the current users home folder
.PARAMETER NoOutput
    Use this flag to disable console outputs for the progress, required by other
    functions using this function
.PARAMETER CreateReleasePackage
    If set, the function will create a .zip file for this specific module which
    can be used within the Icinga for Windows repository manager.
    Use -ReleasePackagePath to override the default location on where the
    package will be created in. Default location is the current users
    home folder
#>
function Publish-IcingaForWindowsComponent()
{
    param (
        [string]$Name,
        [string]$ReleasePackagePath   = '',
        [switch]$NoOutput             = $FALSE,
        [switch]$CreateReleasePackage = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'Please specify the name of the component you want to publish';
        return;
    }

    [string]$ModuleName     = [string]::Format('icinga-powershell-{0}', $Name.ToLower());
    [string]$ModuleRoot     = Get-IcingaForWindowsRootPath;
    [string]$ModuleDir      = Join-Path -Path $ModuleRoot -ChildPath $ModuleName;
    [string]$ModuleManifest = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)))

    if ((Test-Path $ModuleDir) -eq $FALSE) {
        Write-IcingaConsoleError 'A component with the name "{0}" does not exist. Use "New-IcingaForWindowsComponent" to create a new one or verify that the provided name is correct.' -Objects $Name;
        return;
    }

    $ComponentType   = '';
    $ManifestScript  = '';
    $ManifestContent = Get-Content -Path $ModuleManifest;

    foreach ($entry in $ManifestContent) {
        [string]$LineContent = [string]$entry;
        if ($LineContent.Contains('#')) {
            $LineContent = $LineContent.Substring(0, $LineContent.IndexOf('#'));
        }

        if ([string]::IsNullOrEmpty($LineContent) -Or $LineContent -eq "`r`n" -Or $LineContent -eq "`n" -Or [string]::IsNullOrEmpty($LineContent.Replace(' ', ''))) {
            continue;
        }

        $ManifestScript += $LineContent;
        $ManifestScript += "`r`n";
    }

    [ScriptBlock]$ManifestScriptBlock = [ScriptBlock]::Create('return ' + $ManifestScript);
    $ModuleManifestData               = (& $ManifestScriptBlock);
    $ModuleList                       = @();
    $ModuleFiles                      = Get-ChildItem -Path $ModuleDir -Recurse -Filter '*.psm1';

    foreach ($entry in $ModuleFiles) {
        if ($entry.Name -eq ([string]::Format('{0}.psm1', $ModuleName))) {
            continue;
        }

        $ModuleList += $entry.FullName.Replace($ModuleDir, '.');
    }

    if ($NoOutput) {
        Disable-IcingaFrameworkConsoleOutput;
    }

    Write-IcingaForWindowsComponentManifest -Name $Name -ModuleList $ModuleList;

    if ($ModuleManifestData.PrivateData.Type -eq 'plugins') {
        Publish-IcingaPluginConfiguration -ComponentName $Name;
        Publish-IcingaPluginDocumentation -ModulePath $ModuleDir;
    }

    if ($CreateReleasePackage) {
        if ([string]::IsNullOrEmpty($ReleasePackagePath)) {
            $ReleasePackagePath = Join-Path -Path $ENV:HOMEDRIVE -ChildPath $ENV:HOMEPATH;
            $ReleasePackagePath = Join-Path -Path $ReleasePackagePath -ChildPath ([string]::Format('ifw_releases\{0}', $ModuleName))
        }

        if ((Test-Path $ReleasePackagePath) -eq $FALSE) {
            New-Item -ItemType Directory -Path $ReleasePackagePath | Out-Null;
        }

        if ((Test-Path $ReleasePackagePath) -eq $FALSE) {
            Write-IcingaConsoleError 'Failed to create path "{0}" for providing .zip archive for module "{1}"' -Objects $ReleasePackagePath, $ModuleName;
            return;
        }

        if ((Test-IcingaAddTypeExist 'System.IO.Compression.FileSystem') -eq $FALSE) {
            Add-Type -Assembly 'System.IO.Compression.FileSystem';
        }

        [string]$ZipName = [string]::Format(
            '{0}-{1}.zip', $ModuleName, $ModuleManifestData.PrivateData.Version
        );

        $ZipFile = Join-Path -Path $ReleasePackagePath -ChildPath $ZipName;

        if (Test-Path $ZipFile) {
            Remove-ItemSecure -Path $ZipFile -Force | Out-Null;
        }

        $ReleaseTmpDir = New-IcingaTemporaryDirectory;
        Copy-ItemSecure -Path $ModuleDir -Destination $ReleaseTmpDir -Recurse -Force | Out-Null;

        $ReleaseTmpContent = Get-ChildItem -Path (Join-Path -Path $ReleaseTmpDir -ChildPath $ModuleName) -Recurse;

        foreach ($entry in $ReleaseTmpContent) {
            if ((Test-Path $entry.FullName) -eq $FALSE) {
                continue;
            }

            if ($entry.Name[0] -eq '.') {
                Remove-ItemSecure -Path $entry.FullName -Recurse -Force | Out-Null;
            }
        }

        [System.IO.Compression.ZipFile]::CreateFromDirectory(
            $ReleaseTmpDir,
            $ZipFile,
            [System.IO.Compression.CompressionLevel]::Optimal,
            $FALSE
        );

        Remove-ItemSecure -Path $ReleaseTmpDir -Force -Recurse | Out-Null;

        if (Test-Path $ZipFile) {
            Write-IcingaConsoleNotice 'Published module with version "{0}" at "{1}"' -Objects $ModuleManifestData.PrivateData.Version, $ZipFile;
        } else {
            Write-IcingaConsoleError 'Failed to publish module "{0}" at "{1}". Please verify you have enough permissions to access this location and try again' -Objects $ModuleName, $ZipFile;
        }

    }

    Write-IcingaConsoleNotice 'Component "{0}" has been updated as module "icinga-powershell-{1}" at location "{2}" successfully' -Objects $Name, $Name.ToLower(), $ModuleDir;

    Enable-IcingaFrameworkConsoleOutput;
}
