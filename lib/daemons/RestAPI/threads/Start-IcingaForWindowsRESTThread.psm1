function Start-IcingaForWindowsRESTThread()
{
    param (
        [int]$ThreadId       = 0,
        [switch]$RequireAuth = $FALSE
    );

    # Now create a new thread, assign a name and parse all required arguments to it.
    # Last but not least start it directly
    New-IcingaThreadInstance `
        -Name ([string]::Format("Icinga_Windows_REST_Api_Thread_{0}", $ThreadId)) `
        -ThreadPool (New-IcingaThreadPool -MaxInstances 1) `
        -Command 'New-IcingaForWindowsRESTThread' `
        -CmdParameters @{
            'IcingaDaemonData' = $global:IcingaDaemonData;
            'RequireAuth'      = $RequireAuth;
            'ThreadId'         = $ThreadId;
        } `
        -Start;
}
