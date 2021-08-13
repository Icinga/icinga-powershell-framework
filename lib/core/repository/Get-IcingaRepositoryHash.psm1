function Get-IcingaRepositoryHash()
{
    param (
        [string]$Path
    );

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return;
    }

    $RepositoryFolder  = Get-ChildItem -Path $Path -Recurse;
    [array]$FileHashes = @();

    foreach ($entry in $RepositoryFolder) {
        $FileHashes += (Get-FileHash -Path $entry.FullName -Algorithm SHA256).Hash;
    }

    $HashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256');
    $BinaryHash    = $HashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($FileHashes.ToString()))

    return [System.BitConverter]::ToString($BinaryHash).Replace('-', '');
}
