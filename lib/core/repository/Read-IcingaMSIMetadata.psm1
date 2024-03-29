function Read-IcingaMSIMetadata()
{
    param (
        [string]$File = $null
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided file "{0}" does not exist' -Objects $File;
        return $null;
    }

    if ([IO.Path]::GetExtension($File) -ne '.msi') {
        Write-IcingaConsoleError 'This Cmdlet is only supporting files with .msi extension. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    $AgentFile      = Get-Item $File;
    $MSIPackageData = @{
        'ProductCode'    = '';
        'ProductVersion' = '';
        'ProductName'    = '';
    }

    [array]$MSIObjects = $MSIPackageData.Keys;

    try {
        $InstallerInstance = New-Object -ComObject 'WindowsInstaller.Installer';
        #$MSIPackage       = $InstallerInstance.OpenDatabase($File, 0); # Not Working on Windows 2012 R2
        $MSIPackage        = $InstallerInstance.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $Null, $InstallerInstance, @($File, 0));

        foreach ($PackageInfo in $MSIObjects) {
            $MSIQuery = [string]::Format(
                "SELECT `Value` FROM `Property` WHERE `Property` = '{0}'",
                $PackageInfo
            );
            #$MSIDb     = $MSIPackage.OpenView($MSIQuery); # Not Working on Windows 2012 R2
            $MSIDb      = $MSIPackage.GetType().InvokeMember('OpenView', 'InvokeMethod', $Null, $MSIPackage, $MSIQuery);

            if ($null -eq $MSIDb) {
                continue;
            }

            #$MSIDb.Execute(); # Not Working on Windows 2012 R2
            $MSIDb.GetType().InvokeMember('Execute', 'InvokeMethod', $Null, $MSIDb, $Null);
            #$MSITable = $MSIDb.Fetch(); # Not Working on Windows 2012 R2
            $MSITable  = $MSIDb.GetType().InvokeMember('Fetch' , 'InvokeMethod', $Null, $MSIDb, $Null);

            if ($null -eq $MSITable) {
                continue;
            }

            $MSIPackageData[$PackageInfo] = $MSITable.GetType().InvokeMember('StringData', 'GetProperty', $null, $MSITable, 1);

            #$MSIDb.Close(); # Not Working on Windows 2012 R2
            $MSIDb.GetType().InvokeMember('Close', 'InvokeMethod', $null, $MSIDb, $null);
            [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSIDb));
            $MSIDb = $null;
        }

        [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSIPackage));
        [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($InstallerInstance));
        $MSIPackage        = $null;
        $InstallerInstance = $null;

        if ($AgentFile.Name.Contains('x86_64')) {
            $MSIPackageData.Add('Architecture', 'x64')
        } else {
            $MSIPackageData.Add('Architecture', 'x86')
        }

        [Version]$PackageVersion = $MSIPackageData.ProductVersion;
        if ($PackageVersion.Revision -eq -1) {
            $MSIPackageData.Add('Snapshot', $False);
        } else {
            $MSIPackageData.Add('Snapshot', $True);
        }

        return $MSIPackageData;
    } catch {
        Write-IcingaConsoleError 'Failed to query MSI package information for package "{0}". Exception: {1}' -Objects $File, $_.Exception.Message;
    }

    return $null;
}
