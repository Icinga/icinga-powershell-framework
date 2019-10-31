function Expand-IcingaZipArchive()
{
    param(
        $Path,
        $Destination
    );

    if ((Test-Path $Path) -eq $FALSE -Or (Test-Path $Destination) -eq $FALSE) {
        Write-Host 'The path to the zip archive or the destination path do not exist';
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
