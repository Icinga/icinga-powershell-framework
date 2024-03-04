Use-Icinga -Minimal;

# This script will simply install the Icinga for Windows certificate everyime the
# scheduled task is running. This does not impact our system at all, because we
# can update the certificate at any time without having to worry about the state

# To make the configuration of the task as easy as possible, we should fetch
# the current configuration of our REST-Api and check if we provide a custom
# certificate file or thumbprint. In case we do, ensure we use this certificate
# for the icingaforwindows.pfx creation instead of the auto lookup
[hashtable]$RegisteredBackgroundDaemons = Get-IcingaBackgroundDaemons;
[string]$CertificatePath                = '';
[string]$CertificateThumbprint          = '';

if ($RegisteredBackgroundDaemons.ContainsKey('Start-IcingaWindowsRESTApi')) {
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('CertFile')) {
        $CertificatePath = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['CertFile'];
    }
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('-CertFile')) {
        $CertificatePath = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['-CertFile'];
    }
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('CertThumbprint')) {
        $CertificateThumbprint = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['CertThumbprint'];
    }
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('-CertThumbprint')) {
        $CertificateThumbprint = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['-CertThumbprint'];
    }
}

Install-IcingaForWindowsCertificate -CertFile $CertificatePath -CertThumbprint $CertificateThumbprint;

# Tell the Task-Scheduler that the script was executed fine
exit 0;
