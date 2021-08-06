<#
.SYNOPSIS
    Compares a binary within a .zip file to a included .md5 to ensure
    the checksum is matching
.DESCRIPTION
    Compares a possible included .md5 checksum file with the provided binary
    to ensure they are identical
.FUNCTIONALITY
    Compares a binary within a .zip file to a included .md5 to ensure
    the checksum is matching.
.EXAMPLE
    PS>Test-IcingaZipBinaryChecksum -Path 'C:\Program Files\icinga-service\icinga-service.exe';
.PARAMETER Path
    Path to the binary to be checked for. A Corresponding .md5 file with the
    extension added on the file is required, like icinga-service.exe.md5
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

    $MD5Path = [string]::Format('{0}.md5', $Path);

    if ((Test-Path $MD5Path) -eq $FALSE) {
        return $TRUE;
    }

    [string]$MD5Checksum = Get-Content $MD5Path;
    $MD5Checksum         = ($MD5Checksum.Split(' ')[0]).ToLower();

    $FileHash = ((Get-IcingaFileHash $Path -Algorithm MD5).Hash).ToLower();

    if ($MD5Checksum -ne $FileHash) {
        return $FALSE;
    }

    return $TRUE;
}
