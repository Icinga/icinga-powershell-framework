[hashtable]$TestIcingaWindowsInfo = @{
    'Ok'                 = 1;
    'EmptyClass'         = 2;
    'PermissionError'    = 4;
    'ObjectNotFound'     = 8;
    'InvalidNameSpace'   = 16;
    'UnhandledException' = 32;
    'NotSpecified'       = 64;
    'CimNotInstalled'    = 128;
}

[hashtable]$TestIcingaWindowsInfoText = @{
    1   = 'Everything is fine.';
    2   = 'No class specified to check';
    4   = 'Unable to query data using the given WMI-Class. You are either missing permissions or the service is not running properly';
    8   = 'The specified WMI Class could not be found in the specified NameSpace.';
    16  = 'No namespace with the specified name could be found on this system.';
    32  = 'Windows unhandled exception is thrown. Please enable frame DebugMode for information.';
    64  = 'Either the service has been stopped or you are not authorized to access the service.';
    128 = 'The Cmdlet Get-CimClass is not available on your system.';
}

[hashtable]$TestIcingaWindowsInfoExceptionType = @{
    1   = 'OK';
    2   = 'EmptyClass';
    4   = 'PermissionError';
    8   = 'ObjectNotFound';
    16  = 'InvalidNameSpace';
    32  = 'UnhandledException';
    64  = 'NotSpecified';
    128 = 'CimNotInstalled';
}

[hashtable]$TestIcingaWindowsInfoEnums = @{
    TestIcingaWindowsInfo              = $TestIcingaWindowsInfo;
    TestIcingaWindowsInfoText          = $TestIcingaWindowsInfoText;
    TestIcingaWindowsInfoExceptionType = $TestIcingaWindowsInfoExceptionType;
}

Export-ModuleMember -Variable @( 'TestIcingaWindowsInfoEnums' );
