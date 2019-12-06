function Copy-ItemSecure()
{
    param(
        [string]$Path,
        [string]$Destination,
        [switch]$Recurse,
        [switch]$Force
    );

    if ((Test-Path $Path) -eq $FALSE) {
        return $FALSE;
    }

    try {
        if ($Recurse -And $Force) {
            Copy-Item -Path $Path -Destination $Destination -Recurse -Force;
        } elseif ($Recurse -And -Not $Force) {
            Copy-Item -Path $Path -Destination $Destination -Recurse;
        } elseif (-Not $Recurse -And $Force) {
            Copy-Item -Path $Path -Destination $Destination -Force;
        } else {
            Copy-Item -Path $Path -Destination $Destination;
        }
        return $TRUE;
    } catch {
        Write-Host ([string]::Format('Failed to copy items from path "{0}" to "{1}": {2}', $Path, $Destination, $_.Exception)) -ForegroundColor Red;
    }
    return $FALSE;
}
