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
.PARAMETER NoNewLine
   Will ensure that no new line is added at the end of the message, allowing to
   write different messages with different function calls without line breaks
.PARAMETER DropMessage
   Will not write the message to the console and simply drop it
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
        [ValidateSet('Default', 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor   = 'Default',
        [string]$Severity    = 'Notice',
        [switch]$NoNewLine   = $FALSE,
        [switch]$DropMessage = $FALSE
    );

    if ($DropMessage) {
        return;
    }

    if ((Test-IcingaFrameworkConsoleOutput) -eq $FALSE) {
        return;
    }

    # Never write console output in case the Framework is running as daemon
    if ($Global:Icinga.Protected.RunAsDaemon -eq $TRUE) {
        return;
    }

    $OutputMessage = $Message;
    [int]$Index    = 0;

    foreach ($entry in $Objects) {

        $OutputMessage = $OutputMessage.Replace(
            [string]::Format('{0}{1}{2}', '{', $Index, '}'),
            $entry
        );
        $Index++;
    }

    if ($Global:Icinga.ContainsKey('InstallWizard') -And [string]::IsNullOrEmpty($OutputMessage) -eq $FALSE) {
        if ($Severity -eq 'Error') {
            if ($Global:Icinga.InstallWizard.LastError -NotContains $OutputMessage) {
                $Global:Icinga.InstallWizard.LastError += $OutputMessage;
            }
        }
        if ($Severity -eq 'Warning') {
            if ($Global:Icinga.InstallWizard.LastWarning -NotContains $OutputMessage) {
                $Global:Icinga.InstallWizard.LastWarning += $OutputMessage;
            }
        }
    }

    if ([string]::IsNullOrEmpty($Severity) -eq $FALSE) {
        Write-Host '[' -NoNewline;
        Write-Host $Severity -NoNewline -ForegroundColor $ForeColor;
        Write-Host ']: ' -NoNewline;
        Write-Host $OutputMessage;

        return;
    }

    if ($ForeColor -eq 'Default') {
        Write-Host $OutputMessage -NoNewline:$NoNewLine;
    } else {
        Write-Host $OutputMessage -ForegroundColor $ForeColor -NoNewline:$NoNewLine;
    }
}
