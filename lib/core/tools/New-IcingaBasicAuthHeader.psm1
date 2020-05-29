<#
.SYNOPSIS
   Creates a basic auth header for web requests in case the Get-Credential
   method is not supported or working properly
.DESCRIPTION
   Creates a basic auth header for web requests in case the Get-Credential
   method is not supported or working properly
.FUNCTIONALITY
   Creates a hashtable with a basic authorization header as Base64 encoded
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password $SecurePasswordString;
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password (Read-Host -Prompt 'Please enter your password' -AsSecureString);
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password (ConvertTo-IcingaSecureString 'my_secret_password');
.PARAMETER Username
   The user we will use to authenticate for
.PARAMETER Password
   The password for the user provided as SecureString
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaBasicAuthHeader()
{
    param(
        [string]$Username       = $null,
        [SecureString]$Password = $null
    );

    if ($null -eq $Password -or [string]::IsNullOrEmpty($Username)) {
        Write-IcingaConsoleWarning 'Please specify your username and password to continue';
        return @{};
    }

    $Credentials = [System.Convert]::ToBase64String(
        [System.Text.Encoding]::ASCII.GetBytes(
            [string]::Format(
                '{0}:{1}',
                $Username,
                (ConvertFrom-IcingaSecureString $Password)
            )
        )
    );

    return @{
        'Authorization' = [string]::Format('Basic {0}', $Credentials)
    };
}
