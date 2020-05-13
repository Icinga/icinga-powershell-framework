function Remove-ItemSecure()
{
    param(
        [string]$Path,
        [switch]$Recurse,
        [switch]$Force
    )

    if ((Test-Path $Path) -eq $FALSE) {
        return $FALSE;
    }

    try {
        if ($Recurse -And $Force) {
            Remove-Item -Path $Path -Recurse -Force;
        } elseif ($Recurse -And -Not $Force) {
            Remove-Item -Path $Path -Recurse;
        } elseif (-Not $Recurse -And $Force) {
            Remove-Item -Path $Path -Force;
        } else {
            Remove-Item -Path $Path;
        }
        return $TRUE;
    } catch {
        Write-IcingaConsoleError ([string]::Format('Failed to remove items from path "{0}": {1}', $Path, $_.Exception));
    }
    return $FALSE;
}
