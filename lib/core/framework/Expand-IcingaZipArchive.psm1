<#
.SYNOPSIS
   Extracts a ZIP-Archive to a certain location
.DESCRIPTION
   Unzips a ZIP-Archive on to a certain location
.FUNCTIONALITY
   Unzips a ZIP-Archive on to a certain location
.EXAMPLE
   PS>Expand-IcingaZipArchive -Path 'C:\users\public\test.zip' -Destination 'C:\users\public\';
.PARAMETER Path
   The location of your ZIP-Archive
.PARAMETER Destination
   The target destination to extract the ZIP-Archive to
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Expand-IcingaZipArchive()
{
    param(
        $Path,
        $Destination
    );

    if ((Test-Path $Path) -eq $FALSE -Or (Test-Path $Destination) -eq $FALSE) {
        Write-IcingaConsoleError 'The path to the zip archive or the destination path do not exist';
        return $FALSE;
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem;

    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $Destination);
        return $TRUE;
    } catch {
        throw $_.Exception;
    }

    return $FALSE;
}
