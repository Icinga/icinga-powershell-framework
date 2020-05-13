<#
.SYNOPSIS
   A more secure way to copy items from one location to another including error handling
.DESCRIPTION
   Wrapper for the Copy-Item Cmdlet to more securely copy items with error
   handling to prevent interuptions during actions
.FUNCTIONALITY
   Copies items from a source to a destination location
.EXAMPLE
   PS>Copy-ItemSecure -Path 'C:\users\public\test.txt' -Destination 'C:\users\public\text2.txt';
.EXAMPLE
   PS>Copy-ItemSecure -Path 'C:\users\public\testfolder\' -Destination 'C:\users\public\testfolder2\' -Recurse;
.PARAMETER Path
   The location you wish to copy from. Can either be a file or a directory
.PARAMETER Destination
   The target destination to copy to. Can either be a file or a directory
.PARAMETER Recurse
   Include possible sub-folders
.PARAMETER Force
   Overwrite already existing files/folders
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
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
        Write-IcingaConsoleError -Message 'Failed to copy items from path "{0}" to "{1}": {2}' -Objects $Path, $Destination, $_.Exception;
    }
    return $FALSE;
}
