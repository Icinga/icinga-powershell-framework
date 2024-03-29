<#
.SYNOPSIS
   Default Cmdlet for printing plain messages to console
.DESCRIPTION
   Default Cmdlet for printing plain messages to console
.FUNCTIONALITY
   Default Cmdlet for printing plain messages to console
.EXAMPLE
   PS>Write-IcingaConsolePlain -Message 'Test message: {0}' -Objects 'Hello World';
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

function Write-IcingaConsolePlain()
{
    param (
        [string]$Message,
        [array]$Objects,
        [ValidateSet('Default', 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor = 'Default',
        [switch]$NoNewLine = $FALSE,
        [switch]$DropMessage = $FALSE
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor $ForeColor `
        -Severity $null `
        -NoNewLine:$NoNewLine `
        -DropMessage:$DropMessage;
}
