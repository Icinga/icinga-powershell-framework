function Read-IcingaServicePackage()
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

    if ([IO.Path]::GetExtension($File) -ne '.zip' -And [IO.Path]::GetExtension($File) -ne '.exe') {
        Write-IcingaConsoleError 'Your service binary must be inside a .zip file or directly given on the "-File" argument. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    [hashtable]$BinaryData = @{
        'CompanyName'    = '';
        'FileVersion'    = '';
        'ProductVersion' = '';
        'ComponentName'  = 'service';
    }

    try {
        $ZipPackage = $null;

        if ([IO.Path]::GetExtension($File) -eq '.zip') {
            $ZipPackage      = [System.IO.Compression.ZipFile]::OpenRead($File);

            foreach ($entry in $ZipPackage.Entries) {
                if ([IO.Path]::GetExtension($entry.FullName) -ne '.exe') {
                    continue;
                }

                $ServiceTempDir = New-IcingaTemporaryDirectory;
                $BinaryFile     = (Join-Path -Path $ServiceTempDir -ChildPath $entry.Name);
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
                    $entry,
                    (Join-Path -Path $ServiceTempDir -ChildPath $entry.Name),
                    $TRUE
                );

                $ServiceBin = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($BinaryFile);

                if ($ServiceBin.CompanyName -ne 'Icinga GmbH') {
                    Remove-Item -Path $ServiceTempDir -Recurse -Force;
                    continue;
                }

                $BinaryData.CompanyName    = $ServiceBin.CompanyName;
                $BinaryData.ProductVersion = ([version]($ServiceBin.ProductVersion)).ToString(3);
                $BinaryData.FileVersion    = ([version]($ServiceBin.FileVersion)).ToString(3);
                break;
            }

            $ZipPackage.Dispose();
        } elseif ([IO.Path]::GetExtension($File) -eq '.exe') {
            $ServiceBin = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($File);

            if ($ServiceBin.CompanyName -ne 'Icinga GmbH') {
                return $null;
            }

            $BinaryData.CompanyName    = $ServiceBin.CompanyName;
            $BinaryData.ProductVersion = ([version]($ServiceBin.ProductVersion)).ToString(3);
            $BinaryData.FileVersion    = ([version]($ServiceBin.FileVersion)).ToString(3);
        } else {
            return $null;
        }

        if ([string]::IsNullOrEmpty($BinaryData.ProductVersion)) {
            return $null;
        }

        return $BinaryData;
    } catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsoleError 'Failed to read package content and/or binary file: {0}' -Objects $ExMsg;
    } finally {
        if ($null -ne $ZipPackage) {
            $ZipPackage.Dispose();
        }
    }

    return $null;
}
