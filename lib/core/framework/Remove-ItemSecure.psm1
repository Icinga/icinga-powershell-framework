<#
.SYNOPSIS
    Wrapper for Remove-Item to secuerly remove items allowing better handling for errors
.DESCRIPTION
    Removes files and folders from disk and catches possible exceptions with proper return
    values to handle errors better
.FUNCTIONALITY
    Wrapper for Remove-Item to secuerly remove items allowing better handling for errors
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
    Tries to forefully removes a files and folders if they are either being used or a folder is
    still containing items
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

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
