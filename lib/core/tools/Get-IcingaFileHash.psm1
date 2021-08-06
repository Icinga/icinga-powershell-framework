function Get-IcingaFileHash()
{
    param (
        [string]$Path,
        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5')]
        [string]$Algorithm = 'SHA256'
    );

    if ([string]::IsNullOrEmpty($Path) -Or ((Test-Path -Path $Path) -eq $FALSE)) {
        Write-IcingaConsoleError 'Your path is either not specified or does not exist';
        return $null;
    }

    $FileHasher = New-Object "System.Security.Cryptography.${Algorithm}CryptoServiceProvider";

    if ($null -eq $FileHasher) {
        Write-IcingaConsoleError 'Unable to create cryptography objects for algorithm "{0}"' -Objects $Algorithm;
        return $null;
    }

    # Read the file specified in $FilePath as a Byte array
    [System.IO.Stream]$FileStream = [System.IO.File]::OpenRead($Path)
    [Byte[]]$FileHash             = $FileHasher.ComputeHash($FileStream)
    [string]$HashString           = [BitConverter]::ToString($FileHash).Replace('-', '');
    $RetValue                     = New-Object -TypeName PSObject;

    $RetValue | Add-Member -MemberType NoteProperty -Name 'Algorithm' -Value $Algorithm.ToUpper();
    $RetValue | Add-Member -MemberType NoteProperty -Name 'Hash'      -Value $HashString;
    $RetValue | Add-Member -MemberType NoteProperty -Name 'Path'      -Value $Path;

    return $RetValue;
}
