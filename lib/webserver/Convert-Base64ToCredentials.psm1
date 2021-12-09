<#
.SYNOPSIS
   Converts a provided Authorization header to credentials
.DESCRIPTION
   Converts a provided Authorization header to credentials
.FUNCTIONALITY
   Converts a provided Authorization header to credentials
.EXAMPLE
   PS>Convert-Base64ToCredentials -AuthString "Basic =Bwebb474567b56756b...";
.PARAMETER AuthString
   The value of the Authorization header of the web request
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Convert-Base64ToCredentials()
{
    param (
        [String]$AuthString
    );

    [hashtable]$Credentials = @{ };

    $AuthArray = $AuthString.Split(' ');

    switch ($AuthArray[0]) {
        'Basic' {
            $AuthString = $AuthArray[1];
        };
        default {
            Write-IcingaEventMessage -EventId 1550 -Namespace 'Framework' -Objects $AuthArray[0];
            return @{ };
        }
    }

    # Convert the Base64 Secure String back to a normal string
    [string]$AuthString     = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String(
            $AuthString
        )
    );

    # If no ':' is within the string, the credential data is not properly formatted
    if ($AuthString.Contains(':') -eq $FALSE) {
        Write-IcingaEventMessage -EventId 1551 -Namespace 'Framework';
        $AuthString = $null;
        return $Credentials;
    }

    try {
        # Build our User Data and Password from the string
        [string]$UserData = $AuthString.Substring(
            0,
            $AuthString.IndexOf(':')
        );
        $Credentials.Add(
            'password',
            (
                ConvertTo-IcingaSecureString `
                    $AuthString.Substring($AuthString.IndexOf(':') + 1, $AuthString.Length - $UserData.Length - 1)
            )
        );

        $AuthString = $null;

        # Extract a possible domain
        if ($UserData.Contains('\')) {
            # Split the auth string on the '\'
            [array]$AuthData = $UserData.Split('\');
            # First value of the array is the Domain, second is the Username
            $Credentials.Add('domain', $AuthData[0]);
            $Credentials.Add(
                'user',
                (
                    ConvertTo-IcingaSecureString $AuthData[1]
                )
            );
            $AuthData = $null;
        } else {
            $Credentials.Add('domain', $null);
            $Credentials.Add(
                'user',
                (
                    ConvertTo-IcingaSecureString $UserData
                )
            );
        }

        $UserData = $null;
    } catch {
        Write-IcingaEventMessage -EventId 1552 -Namespace 'Framework' -ExceptionObject $_;
        return @{};
    }

    return $Credentials;
}
