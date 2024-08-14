<#
.SYNOPSIS
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.DESCRIPTION
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.FUNCTIONALITY
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.EXAMPLE
   PS>Read-IcingaFileSecure -File 'config.json';
.EXAMPLE
   PS>Read-IcingaFileSecure -File 'config.json' -ExitOnReadError;
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Read-IcingaFileSecure()
{
    param (
        [string]$File,
        [switch]$ExitOnReadError = $FALSE
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        return $null;
    }

    [int]$WaitTicks   = 0;
    [bool]$ConfigRead = $FALSE;

    # Lets wait 5 seconds before cancelling reading
    while ($WaitTicks -lt (($WaitTicks + 1) * 50)) {
        try {
            [System.IO.FileStream]$FileStream = [System.IO.File]::Open(
                $File,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [System.IO.FileShare]::Read
            );

            $ReadArray     = New-Object Byte[] $FileStream.Length;
            [bool]$UTF8BOM = $FALSE;

            if ((Get-FileEncoding -Path $File) -eq 'UTF8-BOM') {
                $UTF8BOM = $TRUE;
            }

            $UTF8Encoding  = New-Object System.Text.UTF8Encoding $UTF8BOM;
            $FileContent   = '';

            while ($FileStream.Read($ReadArray, 0 , $ReadArray.Length)) {
                $FileContent = [System.String]::Concat($FileContent, $UTF8Encoding.GetString($ReadArray));
            }

            $FileStream.Dispose();
            $ConfigRead = $TRUE;
            break;
        } catch {
            # File is still locked, wait for lock to vanish
        }

        $WaitTicks += 1;
        Start-Sleep -Milliseconds 100;
    }

    if ($ConfigRead -eq $FALSE -And $ExitOnReadError) {
        Write-IcingaEventMessage -EventId 1102 -Namespace 'Framework' -Objects $ConfigFile, $Content;
        Write-IcingaConsoleWarning -Message 'Your file "{0}" could not be read, as another process is locking it. Icinga for Windows will terminate itself after 5 seconds to prevent damage to this file.' -Objects $File;
        Start-Sleep -Seconds 5;
        exit 3;
    }

    return $FileContent;
}

Set-Alias -Name 'Read-IcingaFileContent' -Value 'Read-IcingaFileSecure';
