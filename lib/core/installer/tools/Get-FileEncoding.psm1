<#
.SYNOPSIS
    Determines the encoding of a file.

.DESCRIPTION
    The Get-FileEncoding function determines the encoding of a file by examining the file's byte order mark (BOM) or by checking if the file is ASCII or UTF8 without BOM.

.PARAMETER Path
    Specifies the path of the file to check.

.EXAMPLE
    Get-FileEncoding -Path "C:\path\to\file.txt"
    Returns the encoding of the specified file.

.OUTPUTS
    System.String
    The function returns a string representing the encoding of the file. Possible values are:
    - UTF8-BOM: UTF-8 encoding with a byte order mark (BOM).
    - Unicode: UTF-16 encoding (little-endian).
    - BigEndianUnicode: UTF-16 encoding (big-endian).
    - UTF7: UTF-7 encoding.
    - UTF32: UTF-32 encoding.
    - UTF8: UTF-8 encoding without a byte order mark (BOM).
    - ASCII: ASCII encoding.

.NOTES
    This function requires PowerShell version 3.0 or later.
#>

function Get-FileEncoding()
{
    param (
        [string]$Path = ''
    );

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path -Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The specified file "{0}" was not found' -Objects $Path;
        return $null;
    }

    $Bytes = Get-Content -Encoding Byte -ReadCount 4 -TotalCount 4 -Path $Path;

    if ($Bytes[0] -eq 0xef -and $Bytes[1] -eq 0xbb -and $Bytes[2] -eq 0xbf) {
        return 'UTF8-BOM';
    } elseif ($Bytes[0] -eq 0xff -and $Bytes[1] -eq 0xfe) {
        return 'Unicode';
    } elseif ($Bytes[0] -eq 0xfe -and $Bytes[1] -eq 0xff) {
        return 'BigEndianUnicode';
    } elseif ($Bytes[0] -eq 0x2b -and $Bytes[1] -eq 0x2f -and $Bytes[2] -eq 0x76) {
        return 'UTF7';
    } elseif ($Bytes[0] -eq 0xff -and $Bytes[1] -eq 0xfe -and $Bytes[2] -eq 0x00 -and $Bytes[3] -eq 0x00) {
        return 'UTF32';
    } else {
        # Check if the file is ASCII or UTF8 without BOM
        $Content = Get-Content -Encoding String -Path $Path;
        $Bytes   = [System.Text.Encoding]::UTF8.GetBytes($content);

        # Check each byte to see if it's outside the ASCII range
        foreach ($byte in $Bytes) {
            if ($byte -gt 127) {
                return 'UTF8';
            }
        }
    }

    # This is the default encoding, as UTF8 without BOM could be valid ASCII
    return 'ASCII';
}
