function Get-IcingaRepositoryHash()
{
    param (
        [string]$Path
    );

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return;
    }

    $RepositoryFolder = Get-ChildItem -Path $Path -Recurse;
    $FileHashes       = New-Object -TypeName 'System.Text.StringBuilder';

    foreach ($entry in $RepositoryFolder) {
        $FileHash = (Get-FileHash -Path $entry.FullName -Algorithm SHA256).Hash;

        if ([string]::IsNullOrEmpty($FileHash)) {
            continue;
        }

        if ($FileHashes.Length -ne 0) {
            $FileHashes.Append('+') | Out-Null;
        }

        $FileHashes.Append($FileHash) | Out-Null;
    }

    $HashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256');
    $BinaryHash    = $HashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($FileHashes.ToString()))

    return [System.BitConverter]::ToString($BinaryHash).Replace('-', '');
}
