<#
.SYNOPSIS
    Wrapper for Remove-Item to securely remove items allowing better handling for errors
.DESCRIPTION
    Removes files and folders from disk and catches possible exceptions with proper return
    values to handle errors better
.FUNCTIONALITY
    Wrapper for Remove-Item to securely remove items allowing better handling for errors
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga;
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga -Recurse;
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga -Recurse -Force;
.PARAMETER Path
    The path to a file or folder you wish you delete
.PARAMETER Recurse
    Removes sub-folders and sub-files for a given location
.PARAMETER Force
    Tries to forcefully removes a files and folders if they are either being used or a folder is
    still containing items
.PARAMETER Retries
    In case the object/folder is not removed without errors, the function will re-try the attempt
    as often as specified with a sleep of 2 seconds between attempts to avoid possible file locks
    for other operations
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Remove-ItemSecure()
{
    param (
        [string]$Path,
        [switch]$Recurse = $FALSE,
        [switch]$Force   = $FALSE,
        [int]$Retries    = 1
    );

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return $FALSE;
    }

    if ($Retries -le 0) {
        $Retries = 1;
    }

    $ExMsg = $null;

    while ($Retries -gt 0) {
        try {
            Remove-Item -Path $Path -Recurse:$Recurse -Force:$Force -ErrorAction Stop;
            return $TRUE;
        } catch {
            $ExMsg = $_.Exception;
        }

        Start-Sleep -Seconds 2;
        Write-IcingaConsoleNotice -Message 'Waiting for lock on path "{0}" to be released before trying to remove it' -Objects $Path;
        $Retries -= 1;
    }

    Write-IcingaConsoleError 'Failed to remove items from path "{0}". Recurse is "{1}", Force is "{2}": "{3}"' -Objects $Path, $Recurse, $Force, $ExMsg;

    return $FALSE;
}
