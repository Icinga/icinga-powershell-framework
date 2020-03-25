<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>
[hashtable]$HTTPResponseCode = @{
    200 = 'Ok';
    400 = 'Bad Request';
    401 = 'Unauthorized';
    403 = 'Forbidden';
    404 = 'Not Found'
    500 = 'Internal Server Error';
};

[hashtable]$HTTPResponseType = @{
    'Ok'                    = 200;
    'Bad Request'           = 400;
    'Unauthorized'          = 401;
    'Forbidden'             = 403;
    'Not Found'             = 404;
    'Internal Server Error' = 500;
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaHTTPEnums.HTTPResponseType.Ok
 #>
[hashtable]$IcingaHTTPEnums = @{
    HTTPResponseCode = $HTTPResponseCode;
    HTTPResponseType = $HTTPResponseType;
}

Export-ModuleMember -Variable @( 'IcingaHTTPEnums' );
