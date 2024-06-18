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

# Wait during the initial run as long as the certificate is not available
while ($TRUE) {
    Install-IcingaForWindowsCertificate -CertFile $CertificatePath;

    if ((Test-IcingaForWindowsCertificate) -eq $FALSE) {
        Write-IcingaEventMessage -EventId 1508 -Namespace 'Framework';
        Start-Sleep -Seconds 60;

        continue;
    }

    break;
}

# Ensure we import the Icinga ca.crt to the root store, which allows us to use the certificate
# of the agent to connect the the Icinga for Windows API without having to break the certificate trust
[bool]$CAImportSuccess = Import-IcingaCAToAuthRoot;

if ($CAImportSuccess -eq $FALSE) {
    Write-IcingaEventMessage -EventId 1509 -Namespace 'Framework';
    exit 1;
}

# Tell the Task-Scheduler that the script was executed fine
exit 0;
