<#
.SYNOPSIS
   Default Cmdlet for printing warning messages to console
.DESCRIPTION
   Default Cmdlet for printing warning messages to console
.FUNCTIONALITY
   Default Cmdlet for printing warning messages to console
.EXAMPLE
   PS>Write-IcingaConsoleWarning -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleWarning()
{
    param (
        [string]$Message,
        [array]$Objects,
        [switch]$DropMessage = $FALSE
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor 'DarkYellow' `
        -Severity 'Warning' `
        -DropMessage:$DropMessage;
}
