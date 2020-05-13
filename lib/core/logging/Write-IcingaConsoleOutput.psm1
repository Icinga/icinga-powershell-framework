<#
.SYNOPSIS
   Standardise console output and make handling of object conversion easier into messages
   by using this standard function for displaying severity and log entries
.DESCRIPTION
   Standardised function to output console messages controlled by the arguments provided
   for coloring, displaying severity and add objects into output messages
.FUNCTIONALITY
   Standardise console output and make handling of object conversion easier into messages
   by using this standard function for displaying severity and log entries
.EXAMPLE
   PS>Write-IcingaConsoleOutput -Message 'Test message: {0}' -Objects 'Hello World' -ForeColor 'Green' -Severity 'Test';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.PARAMETER ForeColor
   The color the severity name will be displayed in
.PARAMETER Severity
   The severity being displayed before the actual message. Leave empty to skip.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleOutput()
{
    param (
        [string]$Message,
        [array]$Objects,
        [ValidateSet('Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor = 'White',
        [string]$Severity  = 'Notice'
    );

    $OutputMessage = $Message;
    [int]$Index    = 0;

    foreach ($entry in $Objects) {

        $OutputMessage = $OutputMessage.Replace(
            [string]::Format('{0}{1}{2}', '{', $Index, '}'),
            $entry
        );
        $Index++;
    }

    if ([string]::IsNullOrEmpty($Severity) -eq $FALSE) {
        Write-Host '[' -NoNewline;
        Write-Host $Severity -NoNewline -ForegroundColor $ForeColor;
        Write-Host ']: ' -NoNewline;
    }

    Write-Host $OutputMessage;
}
