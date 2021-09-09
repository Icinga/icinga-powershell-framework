<#
.SYNOPSIS
    A wrapper function for Invoke-WebRequest to allow easier proxy support and
    to catch errors more directly.
.DESCRIPTION
    A wrapper function for Invoke-WebRequest to allow easier proxy support and
    to catch errors more directly.
.FUNCTIONALITY
    Uses Invoke-WebRequest to fetch information and returns the same output, but
    with direct error handling and global proxy support by configuration
.EXAMPLE
     PS>Invoke-IcingaWebRequest -Uri 'https://icinga.com';
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://icinga.com' -UseBasicParsing;
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://{0}.com' -UseBasicParsing -Objects 'icinga';
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://{0}.com' -UseBasicParsing -Objects 'icinga' -Headers @{ 'accept' = 'application/json' };
.PARAMETER Uri
    The Uri for the web request
.PARAMETER Body
    Specifies the body of the request. The body is the content of the request that follows the headers. You can
    also pipe a body value to Invoke-WebRequest.

    The Body parameter can be used to specify a list of query parameters or specify the content of the response.

    When the input is a GET request and the body is an IDictionary (typically, a hash table), the body is added
    to the URI as query parameters. For other GET requests, the body is set as the value of the request body in
    the standard name=value format.

    When the body is a form, or it is the output of an Invoke-WebRequest call, Windows PowerShell sets the
    request content to the form fields.
.PARAMETER Headers
    Web headers send with the request as hashtable
.PARAMETER Method
    The request method to send to the destination.
    Allowed values: 'Get', 'Post', 'Put', 'Trace', 'Patch', 'Options', 'Merge', 'Head', 'Default', 'Delete'
.PARAMETER OutFile
    Specifies the output file for which this cmdlet saves the response body. Enter a path and file name. If you omit the path, the default is the current location.
.PARAMETER UseBasicParsing
    Indicates that the cmdlet uses the response object for HTML content without Document Object Model (DOM)
    parsing.

    This parameter is required when Internet Explorer is not installed on the computers, such as on a Server
    Core installation of a Windows Server operating system.
.PARAMETER Objects
    Use placeholders within the `-Uri` argument, like {0} and replace them with array elements of this argument.
    The index entry of {0} has to match the order of this argument.
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Invoke-IcingaWebRequest()
{
    param (
        [string]$Uri             = '',
        $Body,
        [hashtable]$Headers,
        [ValidateSet('Get', 'Post', 'Put', 'Trace', 'Patch', 'Options', 'Merge', 'Head', 'Default', 'Delete')]
        [string]$Method          = 'Get',
        [string]$OutFile,
        [switch]$UseBasicParsing,
        [array]$Objects          = @()
    );

    [int]$Index = 0;
    foreach ($entry in $Objects) {

        $Uri = $Uri.Replace(
            [string]::Format('{0}{1}{2}', '{', $Index, '}'),
            $entry
        );
        $Index++;
    }

    # If our URI is a local path or a file share path, always ensure to use the correct Windows directory
    # handling with '\' instead of '/'
    if ([string]::IsNullOrEmpty($Uri) -eq $FALSE -And (Test-Path $Uri)) {
        $Uri = $Uri.Replace('/', '\');
    }

    $WebArguments = @{
        'Uri'    = $Uri;
        'Method' = $Method;
    }

    if ($Method -ne 'Get' -And $null -ne $Body -and [string]::IsNullOrEmpty($Body) -eq $FALSE) {
        $WebArguments.Add('Body', $Body);
    }

    if ($Headers.Count -ne 0) {
        $WebArguments.Add('Headers', $Headers);
    }

    if ([string]::IsNullOrEmpty($OutFile) -eq $FALSE) {
        $WebArguments.Add('OutFile', $OutFile);
    }

    $ProxyServer = Get-IcingaFrameworkProxyServer;

    if ([string]::IsNullOrEmpty($ProxyServer) -eq $FALSE) {
        $WebArguments.Add('Proxy', $ProxyServer);
    }

    Set-IcingaTLSVersion;
    Disable-IcingaProgressPreference;

    try {
        $Response = Invoke-WebRequest -UseBasicParsing:$UseBasicParsing @WebArguments -ErrorAction Stop;
    } catch {
        [string]$ErrorId = ([string]$_.FullyQualifiedErrorId).Split(',')[0];
        [string]$Message = $_.Exception.Message;

        switch ($ErrorId) {
            'System.UriFormatException' {
                Write-IcingaConsoleError 'The provided Url "{0}" is not a valid format' -Objects $Uri;
                break;
            };
            'WebCmdletWebResponseException' {
                Write-IcingaConsoleError 'The remote host for address "{0}" could not be resolved' -Objects $Uri;
                break;
            };
            'System.InvalidOperationException' {
                Write-IcingaConsoleError 'Failed to query host "{0}". Possible this is caused by an invalid Proxy Server configuration: "{1}".' -Objects $Uri, $ProxyServer;
                break;
            };
            Default {
                Write-IcingaConsoleError 'Unhandled exception for Url "{0}" with error id "{1}":{2}{2}{3}' -Objects $Uri, $ErrorId, (New-IcingaNewLine), $Message;
                break;
            };
        }

        # Return some sort of objects which are often used to ensure we at least have some out-of-the-box compatibility
        return @{
            'HasErrors'    = $TRUE;
            'BaseResponse' = @{
                'ResponseUri' = @{
                    'AbsoluteUri' = $Uri;
                };
            };
            'StatusCode'   = 900;
        };
    }

    return $Response;
}
