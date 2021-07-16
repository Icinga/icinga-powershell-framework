function Read-IcingaPackageManifest()
{
    param (
        [string]$File = $null
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided file "{0}" does not exist' -Objects $File;
        return $null;
    }

    if ((Test-IcingaAddTypeExist 'System.IO.Compression.FileSystem') -eq $FALSE) {
        Add-Type -Assembly 'System.IO.Compression.FileSystem';
    }

    if ([IO.Path]::GetExtension($File) -ne '.zip' -And [IO.Path]::GetExtension($File) -ne '.psd1') {
        Write-IcingaConsoleError 'Your Icinga for Windows manifest must be inside a .zip file or directly given on the "-File" argument. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    try {
        $ZipPackage = $null;

        if ([IO.Path]::GetExtension($File) -eq '.zip') {
            $ZipPackage      = [System.IO.Compression.ZipFile]::OpenRead($File);
            $PackageManifest = $null;
            $FileName        = $null;

            foreach ($entry in $ZipPackage.Entries) {
                if ([IO.Path]::GetExtension($entry.FullName) -ne '.psd1') {
                    continue;
                }

                $FileName                   = $entry.Name.Replace('.psd1', '');
                $FilePath                   = $entry.FullName.Replace($entry.Name, '');
                $FileStream                 = $entry.Open();
                $FileReader                 = [System.IO.StreamReader]::new($FileStream);
                $PackageManifestContent     = $FileReader.ReadToEnd();
                $FileReader.Dispose();

                [ScriptBlock]$PackageScript = [ScriptBlock]::Create('return ' + $PackageManifestContent);
                $PackageManifest            = (& $PackageScript);

                if ($null -eq $PackageManifest -Or $PackageManifest.Count -eq 0) {
                    continue;
                }

                if ($PackageManifest.ContainsKey('PrivateData') -eq $FALSE -Or $PackageManifest.ContainsKey('ModuleVersion') -eq $FALSE) {
                    continue;
                }

                break;
            }

            $ZipPackage.Dispose();
        } elseif ([IO.Path]::GetExtension($File) -eq '.psd1') {
            $FileName                   = (Get-Item -Path $File).Name.Replace('.psd1', '');
            $PackageManifestContent     = Get-Content -Path $File -Raw;
            [ScriptBlock]$PackageScript = [ScriptBlock]::Create('return ' + $PackageManifestContent);
            $PackageManifest            = (& $PackageScript);
        } else {
            return $null;
        }

        if ($null -eq $PackageManifest) {
            return $null;
        }

        $PackageManifest.Add('ComponentName', '');

        if ([string]::IsNullOrEmpty($FileName) -eq $FALSE) {
            if ($FileName.Contains('icinga-powershell-*')) {
                $PackageManifest.ComponentName = $FileName.Replace('icinga-powershell-', '');
            } else {
                if ($PackageManifest.ContainsKey('PrivateData') -And $PackageManifest.PrivateData.ContainsKey('Name') -And $PackageManifest.PrivateData.ContainsKey('Type')) {
                    if ($PackageManifest.PrivateData.Name -eq 'Icinga for Windows' -And $PackageManifest.PrivateData.Type -eq 'framework') {
                        $PackageManifest.ComponentName = 'framework';
                    } else {
                        $PackageManifest.ComponentName = ($PackageManifest.PrivateData.Name -Replace 'Windows' -Replace '\W').ToLower();
                    }
                }
            }
        }

        return $PackageManifest;
    } catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsoleError 'Failed to read package content and/or manifest file: {0}' -Objects $ExMsg;
    } finally {
        if ($null -ne $ZipPackage) {
            $ZipPackage.Dispose();
        }
    }

    return $null;
}
