function Write-IcingaTestOutput()
{
    param(
        [ValidateSet('Passed', 'Warning', 'Failed')]
        $Severity,
        $Message,
        [switch]$DropMessage = $FALSE
    );

    if ($DropMessage) {
        return;
    }

    $Color = 'Green';

    Switch ($Severity) {
        'Passed' {
            $Color = 'Green';
            break;
        };
        'Warning' {
            $Color = 'Yellow';
            break;
        };
        'Failed' {
            $Color = 'Red';
            break;
        };
    }

    Write-Host '[' -NoNewline;
    Write-Host $Severity -ForegroundColor $Color -NoNewline;
    Write-Host ']:' $Message;
}
