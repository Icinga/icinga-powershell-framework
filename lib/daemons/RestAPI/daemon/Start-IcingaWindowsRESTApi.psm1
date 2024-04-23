<#
.SYNOPSIS
    A background daemon for Icinga for Windows, providing a REST-Api interface over secure
    TLS (https) connections. As certificates either custom ones are used or by default the
    Icinga Agent certificates
.DESCRIPTION
    This background daemon provides a REST-Api interface by default on Port 5668 over
    TLS connections. No unencrypted http requests are allowed. As certificate it will
    either use the default Icinga Agent certificates (default config) or custom generated
    ones, specified as arguments while installing the daemon.

    In addition you can enable authentication, which allows local users or domain users.

    By default 5 concurrent threads will perform the work on API requests, can how ever be
    reduced or increased depending on configuration.

    More Information on
    https://icinga.com/docs/icinga-for-windows/latest/restapi
.PARAMETER Address
    Allows to specify on which Address a socket should be created on. Defaults to loopback if empty
.PARAMETER Port
    The Port the REST-Api will listen on. Defaults to 5668
.PARAMETER CertFile
    Use this to define a path on your local disk of you are using custom certificates.
    Supported files are: .pfx, .crt

    By default, the local Icinga Agent certificates are used
.PARAMETER CertThumbprint
    Provide a thumbprint of a certificate stored within the local Windows Cert store

    By default, the local Icinga Agent certificates are used
.PARAMETER RequireAuth
    Enable authentication which will add basic auth prompt for any request on the API.
    For authentication you can either use local Windows accounts or domain accounts
.PARAMETER ConcurrentThreads
    Defines on how many threads are started to process API requests. Defaults to 5
.PARAMETER Timeout
    Not for use on this module directly, but allows other modules and features to properly
    get an idea after which time interval connections are terminated
.LINK
    https://github.com/Icinga/icinga-powershell-restapi
.NOTES
#>

function Start-IcingaWindowsRESTApi()
{
    param (
        [string]$Address            = '',
        [int]$Port                  = 5668,
        [string]$CertFile           = $null,
        [string]$CertThumbprint     = $null,
        [PSCustomObject]$CertFilter = $null,
        [bool]$RequireAuth          = $FALSE,
        [int]$ConcurrentThreads     = 5,
        [int]$Timeout               = 120
    );

    New-IcingaForWindowsRESTEnvironment -ThreadCount $ConcurrentThreads;

    # Now create a new thread for our REST-Api, assign a name and parse all required arguments to it.
    # Last but not least start it directly
    New-IcingaThreadInstance `
        -Name 'Main' `
        -ThreadPool (Get-IcingaThreadPool -Name 'RESTApiPool') `
        -Command 'New-IcingaForWindowsRESTApi' `
        -CmdParameters @{
            'Address'        = $Address;
            'Port'           = $Port;
            'CertFile'       = $CertFile;
            'CertThumbprint' = $CertThumbprint;
            'CertFilter'     = $CertFilter;
            'RequireAuth'    = $RequireAuth;
        } `
        -Start;

    $ThreadId = 0;

    while ($ConcurrentThreads -gt 0) {
        $ConcurrentThreads                         = $ConcurrentThreads - 1;
        $RESTThreadQueue = New-Object System.Collections.Concurrent.BlockingCollection[PSObject] `
            -ArgumentList (New-Object System.Collections.Concurrent.ConcurrentQueue[PSObject]);
        $Global:Icinga.Public.Daemons.RESTApi.ApiRequests.Add($ThreadId, $RESTThreadQueue);
        Start-IcingaForWindowsRESTThread -ThreadId $ThreadId -RequireAuth:$RequireAuth;
        $ThreadId += 1;

        Start-Sleep -Seconds 1;
    }
}
