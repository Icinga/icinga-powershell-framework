function Write-IcingaFileSecure()
{
    param (
        [string]$File,
        $Value
    );

    if ([string]::IsNullOrEmpty($File)) {
        return;
    }

    if ((Test-Path $File) -eq $FALSE) {
        try {
            New-Item -ItemType File -Path $File -ErrorAction Stop | Out-Null;
        } catch {
            Exit-IcingaThrowException -InputString $_.Exception -CustomMessage $File -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
            Exit-IcingaThrowException -CustomMessage $_.Exception -ExceptionType 'Unhandled' -Force;
        }
    }

    [int]$WaitTicks    = 0;
    [bool]$FileUpdated = $FALSE;

    # Lets wait 5 seconds before cancelling writing
    while ($WaitTicks -lt (($WaitTicks + 1) * 50)) {
        try {
            [System.IO.FileStream]$FileStream = [System.IO.File]::Open(
                $File,
                [System.IO.FileMode]::Truncate,
                [System.IO.FileAccess]::Write,
                [System.IO.FileShare]::Read
            );

            $ContentBytes = [System.Text.Encoding]::UTF8.GetBytes($Value);
            $FileStream.Write($ContentBytes, 0, $ContentBytes.Length);
            $FileStream.Dispose();
            $FileUpdated = $TRUE;
            break;
        } catch {
            Exit-IcingaThrowException -InputString $_.Exception -CustomMessage $File -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
            # File is still locked, wait for lock to vanish
        }

        $WaitTicks += 1;
        Start-Sleep -Milliseconds 100;
    }

    if ($FileUpdated -eq $FALSE) {
        Write-IcingaEventMessage -EventId 1101 -Namespace 'Framework' -Objects $File, $Value;
        Write-IcingaConsoleWarning -Message 'Your file "{0}" could not be updated with your changes, as another process is locking it.' -Objects $File;
    }
}
