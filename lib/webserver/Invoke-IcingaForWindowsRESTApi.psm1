function Invoke-IcingaForWindowsRESTApi()
{
    param (
        [string]$Uri     = 'v1',
        [ValidateSet('GET', 'POST')]
        [string]$Method  = 'GET',
        [hashtable]$Body = @{ }
    );

    <# Disable this for now, as there is no way to properly handle this with Windows tool and localhost listener
    if ((Test-IcingaCAInstalledToAuthRoot) -eq $FALSE) {
        Write-IcingaConsoleError 'The Icinga CA certificate is not installed to the local machine certificate store. Please run the "Start-IcingaWindowsScheduledTaskRenewCertificate" command to fix this issue.';
        return $null;
    }
    #>

    Set-IcingaTLSVersion;
    Enable-IcingaUntrustedCertificateValidation -SuppressMessages;

    $IcingaForWindowsCertificate = Get-IcingaForWindowsCertificate;
    $RestApiPort                 = 5668;
    [int]$Timeout                = 20;
    $BackgroundDaemons           = Get-IcingaBackgroundDaemons;

    if ($null -ne $BackgroundDaemons -And $BackgroundDaemons.ContainsKey('Start-IcingaWindowsRESTApi')) {
        $Daemon = $BackgroundDaemons['Start-IcingaWindowsRESTApi'];

        # Fetch our deamon configuration
        if ($Daemon.ContainsKey('-Port')) {
            $RestApiPort = $Daemon['-Port'];
        } elseif ($Daemon.ContainsKey('Port')) {
            $RestApiPort = $Daemon['Port'];
        }
    }

    [string]$WebBaseURL = [string]::Format('https://localhost:{0}', $RestApiPort);

    $WebBaseURL = Join-WebPath -Path $WebBaseURL -ChildPath $Uri;

    [hashtable]$Arguments = @{
        '-Method'          = $Method;
        '-UseBasicParsing' = $TRUE;
        '-Uri'             = $WebBaseURL;
        '-ContentType'     = 'application/json';
        '-TimeoutSec'      = $Timeout;
        '-Certificate'     = $IcingaForWindowsCertificate;
        '-ErrorAction'     = 'Stop';
    };

    if ($null -ne $Body -And $Body.Count -ne 0 -And $Method -eq 'POST') {
        $Arguments.Add('-Body', (ConvertTo-JsonUTF8Bytes -InputObject $Body -Depth 100 -Compress));
    }

    return (
        Invoke-WebRequest @Arguments
    );
}
