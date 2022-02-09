<#
.SYNOPSIS
    Removes the dll folder from the cache and deletes
    all pre-compiled libraries by Icinga for Windows
.DESCRIPTION
    Removes the dll folder from the cache and deletes
    all pre-compiled libraries by Icinga for Windows
.EXAMPLE
    PS> Clear-IcingaAddTypeLib
#>
function Clear-IcingaAddTypeLib()
{
    [string]$DLLFolder = (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'dll');

    if ((Test-Path $DLLFolder) -eq $FALSE) {
        Write-IcingaConsoleNotice 'The dll folder does not exist';
        return;
    }

    if (Remove-ItemSecure -Path $DLLFolder -Recurse -Force) {
        Write-IcingaConsoleNotice 'The dll cache folder was successfully removed';
    } else {
        Write-IcingaConsoleError 'Failed to remove dll cache folder. Make sure it is not used at the moment and try again'
    }
}
