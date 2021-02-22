<#
.SYNOPSIS
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.DESCRIPTION
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.FUNCTIONALITY
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.EXAMPLE
   PS>Read-IcingaFileContent -File 'config.json';
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Read-IcingaFileContent()
{
    param (
        [string]$File
    );

    if ((Test-Path $File) -eq $FALSE) {
        return $null;
    }

    [System.IO.FileStream]$FileStream = [System.IO.File]::Open(
        $File,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    );

    $ReadArray    = New-Object Byte[] $FileStream.Length;
    $UTF8Encoding = New-Object System.Text.UTF8Encoding $TRUE;
    $FileContent  = '';

    while ($FileStream.Read($ReadArray, 0 , $ReadArray.Length)) {
        $FileContent = [System.String]::Concat($FileContent, $UTF8Encoding.GetString($ReadArray));
    }

    $FileStream.Dispose();

    return $FileContent;
}
