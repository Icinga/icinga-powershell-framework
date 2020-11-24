<#
.SYNOPSIS
   Disables the progress bar during file downloads or while loading certain modules.
   This will increase the speed of certain tasks, for example file downloads
.DESCRIPTION
   Disables the progress bar during file downloads or while loading certain modules.
   This will increase the speed of certain tasks, for example file downloads
.FUNCTIONALITY
   Sets the $ProgressPreference to 'SilentlyContinue'
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaProgressPreference()
{
    $global:ProgressPreference = "SilentlyContinue";
}
