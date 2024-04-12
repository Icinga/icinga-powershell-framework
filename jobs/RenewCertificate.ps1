Use-Icinga -Minimal;

# This script will simply install the Icinga for Windows certificate everyime the
# scheduled task is running. This does not impact our system at all, because we
# can update the certificate at any time without having to worry about the state

# To make the configuration of the task as easy as possible, we should fetch
# the current configuration of our REST-Api and check if we provide a custom
# certificate file. In case we do, ensure we use this certificate
# for the icingaforwindows.pfx creation instead of the auto lookup
# We do only require to check for cert files on the disk, as the cert store
# is fetched automatically
[hashtable]$RegisteredBackgroundDaemons = Get-IcingaBackgroundDaemons;
[string]$CertificatePath                = '';

if ($RegisteredBackgroundDaemons.ContainsKey('Start-IcingaWindowsRESTApi')) {
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('CertFile')) {
        $CertificatePath = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['CertFile'];
    }
    if ($RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi'].ContainsKey('-CertFile')) {
        $CertificatePath = $RegisteredBackgroundDaemons['Start-IcingaWindowsRESTApi']['-CertFile'];
    }
}

Install-IcingaForWindowsCertificate -CertFile $CertificatePath;

# Tell the Task-Scheduler that the script was executed fine
exit 0;
