<#
.SYNOPSIS
    Compares a binary within a .zip file to a included .sha256 to ensure
    the checksum is matching
.DESCRIPTION
    Compares a possible included .sha256 checksum file with the provided binary
    to ensure they are identical
.FUNCTIONALITY
    Compares a binary within a .zip file to a included .sha256 to ensure
    the checksum is matching.
.EXAMPLE
    PS>Test-IcingaZipBinaryChecksum -Path 'C:\Program Files\icinga-service\icinga-service.exe';
.PARAMETER Path
    Path to the binary to be checked for. A Corresponding .sha256 file with the
    extension added on the file is required, like icinga-service.exe.sha256
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaZipBinaryChecksum()
{
    param(
        $Path
    );

    $SHA256Path = [string]::Format('{0}.sha256', $Path);

    if ((Test-Path $SHA256Path) -eq $FALSE) {
        return $FALSE;
    }

    [string]$SHA256Checksum = Get-Content $SHA256Path;
    $SHA256Checksum         = ($SHA256Checksum.Split(' ')[0]).ToLower();

    $FileHash = ((Get-IcingaFileHash $Path -Algorithm SHA256).Hash).ToLower();

    if ($SHA256Checksum -ne $FileHash) {
        return $FALSE;
    }

    return $TRUE;
}
