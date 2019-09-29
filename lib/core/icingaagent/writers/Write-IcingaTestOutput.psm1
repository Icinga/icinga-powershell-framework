function Write-IcingaTestOutput()
{
    param(
        [ValidateSet('PASSED', 'WARNING', 'FAILED')]
        $Severity,
        $Message
    );

    $Color = 'Green';

    Switch ($Severity) {
        'PASSED' {
            $Color = 'Green';
            break;
        };
        'WARNING' {
            $Color = 'Yellow';
            break;
        };
        'FAILED' {
            $Color = 'Red';
            break;
        };
    }

    Write-Host '[' -NoNewline;
    Write-Host $Severity -ForegroundColor $Color -NoNewline;
    Write-Host ']:' $Message;
}
