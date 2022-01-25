function Start-IcingaForWindowsRESTThread()
{
    param (
        [int]$ThreadId       = 0,
        [switch]$RequireAuth = $FALSE
    );

    # Now create a new thread, assign a name and parse all required arguments to it.
    # Last but not least start it directly
    New-IcingaThreadInstance `
        -Name 'CheckThread' `
        -ThreadPool (New-IcingaThreadPool -MaxInstances 1) `
        -Command 'New-IcingaForWindowsRESTThread' `
        -CmdParameters @{
            'RequireAuth' = $RequireAuth;
            'ThreadId'    = $ThreadId;
        } `
        -Start;
}
