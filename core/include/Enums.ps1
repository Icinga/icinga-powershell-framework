<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$LogState = @{
    Info      = 0;
    Warning   = 1;
    Error     = 2;
    Exception = 3;
    Debug     = 4;
};

[hashtable]$LogSeverity = @{
    0 = 'Info';
    1 = 'Warning';
    2 = 'Error';
    3 = 'Exception';
    4 = 'Debug';
};

[hashtable]$EventLogType = @{
    0 = 'Information';
    1 = 'Warning';
    2 = 'Error';
    3 = 'Error';
    4 = 'Information';
};

[hashtable]$LogColor = @{
    0 = 'DarkGreen';
    1 = 'Yellow';
    2 = 'Red';
    3 = 'DarkRed';
    4 = 'Magenta';
};

[hashtable]$ServiceStatus = @{
    'NotInstalled' = 'The Icinga service for this module is not installed. Please run Install-Icinga to install the service.';
    'Running'      = 'The Icinga service is running.';
    'Stopped'      = 'The Icinga service is not running.';
    'Starting'     = 'The Icinga service is about to start.';
    'Stopping'     = 'The Icinga service is shutting down.';
}

[hashtable]$SCErrorCodes = @{
    5    = 'Failed to execute Icinga 2 Service operation: Permission denied.';
    1053 = 'Failed to start the Icinga 2 Service: The Service did not respond in time to the start or operation request.';
    1056 = 'Failed to start the Icinga 2 Service: The Service is already running.';
    1060 = 'Failed to apply action for Icinga 2 Service: The Service is not installed.';
    1062 = 'Failed to stop the Icinga 2 Service: The Service is not running.';
    1072 = 'Failed to uninstall the Icinga 2 Service: The Service is already marked for deletion.';
    1073 = 'Failed to install the Icinga 2 Service: The Service is already installed.';
};

[hashtable]$HttpStatusCodes = @{
    200 = 'Ok';
    400 = 'Bad Request';
    401 = 'Unauthorized';
    403 = 'Forbidden';
    404 = 'Not Found'
    500 = 'Internal Server Error';
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $Icinga2.Enums.LogState.Info
 #>
[hashtable]$Enums = @{
    LogSeverity     = $LogSeverity;
    EventLogType    = $EventLogType;
    LogColor        = $LogColor;
    LogState        = $LogState;
    ServiceStatus   = $ServiceStatus;
    SCErrorCodes    = $SCErrorCodes;
    HttpStatusCodes = $HttpStatusCodes;
}

return $Enums;