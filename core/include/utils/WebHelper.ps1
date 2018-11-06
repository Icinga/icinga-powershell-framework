$WebHelper = New-Object -TypeName PSObject;

$WebHelper | Add-Member -membertype ScriptMethod -name 'ParseApiMessage' -value {
    param([SecureString]$message);

    try {
        [hashtable]$HeaderContent = @{};

        if ($message -eq $null) {
            return $HeaderContent;
        }

        [string]$HTMLMessage = $Icinga2.Utils.SecureString.ConvertFrom($message);

        [string]$HTMLContent = '';
        if ($HTMLMessage.Contains("`r`n`r`n")) {
            [int]$EOFIndex = $HTMLMessage.IndexOf("`r`n`r`n") + 4;
            $HTMLContent = $HTMLMessage.Substring(
                $EOFIndex,
                $HTMLMessage.Length - $EOFIndex
            );
            # Remove the content from our message
            if ([string]::IsNullOrEmpty($HTMLContent) -eq $FALSE) {
                $HTMLMessage = $HTMLMessage.Replace($HTMLContent, '');
            }
        }

        [array]$SingleHeaders = $HTMLMessage.Split("`r`n");
        $HTMLMessage          = $null;

        # At first read the method, the http call and the protocol
        $HeaderContent.Add(
            'base',
            $this.ParseMethodAndUrl($SingleHeaders[0])
        );
        # Now add possible content to our hashtable
        $HeaderContent.Add(
            'content',
            $HTMLContent
        );
        # Drop the first entry of the array, as we no longer require it
        $SingleHeaders = $SingleHeaders | Select-Object -Skip 1;

        # Read the headers from the array
        $HeaderContent.Add(
            'headers',
            $this.ParseHeaders($SingleHeaders)
        );
        # Flush the array from the memory
        $SingleHeaders = $null;

        if ($HeaderContent.headers.ContainsKey('Authorization')) {
            $HeaderContent.Add(
                'credentials',
                $this.ParseUserCredentials(
                    $HeaderContent.headers.Authorization
                )
            );
            $HeaderContent.headers.Remove('Authorization');
        }

        return $HeaderContent;
    }
    catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Exception,
            [string]::Format(
                'Failed to parse HTTP content and headers. Error {0}',
                $_.Exception.Message
            )
        );
    }

    return $null;
}

$WebHelper | Add-Member -membertype ScriptMethod -name 'ParseMethodAndUrl' -value {
    param([string]$message);

    [array]$Content = $message.Split(' ');
    [uri]$UriData   = [uri][string]::Format(
        'https://localhost{0}',
        $Content[1]
    );

    return @{
        method   = $Content[0];
        call     = [System.Web.HttpUtility]::UrlDecode(
            $Content[1]
        );
        protocol = $Content[2];
        segments = $UriData.Segments;
        query    = [System.Web.HttpUtility]::UrlDecode(
            $UriData.Query
        );
    }
}

$WebHelper | Add-Member -membertype ScriptMethod -name 'ParseHeaders' -value {
    param([array]$message);

    [hashtable]$Headers = @{};

    foreach ($header in $message) {
        [string]$HeaderName  = '';
        [string]$HeaderValue = '';
        # Skip empty array values
        if ([string]::IsNullOrEmpty($header) -eq $FALSE) {
            if ($header.Contains(':')) {
                [array]$Element = $header.Split(':');
                $HeaderName = $Element[0];

                if ($Element.Count -gt 1) {
                    for ($i = 1; $i -le ($Element.Count - 1); $i++) {
                        $HeaderValue = -Join(
                            $HeaderValue,
                            $Element[$i],
                            ':'
                        );
                    }
                }

                # Remove the last added ':' at the end of the string
                if ($HeaderValue.Length -gt 1) {
                    $HeaderValue = $HeaderValue.Substring(
                        0,
                        $HeaderValue.Length - 1
                    );
                }

                # In case the first letter of our value is a space, remove it
                while ($HeaderValue[0] -eq ' ') {
                    $HeaderValue = $HeaderValue.Substring(
                        1,
                        $HeaderValue.Length - 1
                    );
                }

                if ($Headers.ContainsKey($HeaderName) -eq $FALSE) {
                    # We have to modify the Authorization header value a little more and also
                    # ensure we store it as secure string within our module
                    if ($HeaderName -eq 'Authorization') {
                        [array]$AuthArray = $HeaderValue.Split(' ');
                        # TODO: Shall we handle each auth type differently?
                        $Headers.Add(
                            $HeaderName,
                            $Icinga2.Utils.SecureString.ConvertTo($AuthArray[1])
                        );
                        $AuthArray = $null;
                    } else {
                        $Headers.Add($HeaderName, $HeaderValue);
                    }
                }
            } else {
                $Headers.Add($header, $null);
            }
        }
    }

    return $Headers;
}

$WebHelper | Add-Member -membertype ScriptMethod -name 'ParseUserCredentials' -value {
    param([SecureString]$Base64String);

    [hashtable]$Credentials = @{};

    if ($Base64String -eq $null) {
        return $Credentials;
    }

    # Convert the Base64 Secure String back to a normal string
    [string]$PlainAuth = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String(
            $Icinga2.Utils.SecureString.ConvertFrom($Base64String)
        )
    );
    $Base64String = $null;

    # If no ':' is within the string, the credential data is not properly formated
    if ($PlainAuth.Contains(':') -eq $FALSE) {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Warning,
            'Received invalid formated credentials as Base64 encoded.'
        );
        $PlainAuth = $null;
        return $Credentials;
    }

    try {
        # Build our User Data and Password from the string
        [string]$UserData = $PlainAuth.Substring(
            0,
            $PlainAuth.IndexOf(':')
        );
        $Credentials.Add(
            'password',
            $Icinga2.Utils.SecureString.ConvertTo(
                $PlainAuth.Substring(
                    $PlainAuth.IndexOf(':') + 1,
                    $PlainAuth.Length - $UserData.Length - 1
                )
            )
        );

        $PlainAuth = $null;

        # Extract a possible domain
        if ($UserData.Contains('\')) {
            # Split the auth string on the '\'
            [array]$AuthData = $UserData.Split('\');
            # First value of the array is the Domain, second is the Username
            $Credentials.Add('domain', $AuthData[0]);
            $Credentials.Add(
                'user',
                $Icinga2.Utils.SecureString.ConvertTo(
                    $AuthData[1]
                )
            );
            $AuthData = $null;
        } else {
            $Credentials.Add('domain', $null);
            $Credentials.Add(
                'user',
                $Icinga2.Utils.SecureString.ConvertTo(
                    $UserData
                )
            );
        }

        $UserData = $null;
    } catch {
        $Icinga2.Log.Write(
            $Icinga2.Enums.LogState.Error,
            'Failed to handle authentication request. An exception occured while processing the request.'
        );
    }

    return $Credentials;
}

$WebHelper | Add-Member -membertype ScriptMethod -name 'ParseUrlCommand' -value {
    param([string]$Argument);

    [hashtable]$StructuredCommand = @{};
    # If no = is included, we don't need to handle anything special
    if ($Argument.Contains('=') -eq $FALSE) {
        $StructuredCommand.Add($Argument, $null);
        return $StructuredCommand;
    }

    [int]$SeperatorIndex = $Argument.IndexOf('=');
    [string]$Command = $Argument.Substring(
        0,
        $SeperatorIndex
    );
    $Command = $Command.Replace(' ', '').ToLower();

    [array]$Values = @();
    [string]$Value = $Argument.Substring(
        $SeperatorIndex + 1,
        $Argument.Length - $SeperatorIndex - 1
    );

    if ($Value.Contains(',') -eq $TRUE) {
        [array]$Entries = $Value.Split(',');
        foreach ($entry in $Entries) {
            [string]$ParsedValue = $entry;
            # Cut spaces before names of inputs
            while ($ParsedValue[0] -eq ' ') {
                $ParsedValue = $ParsedValue.Substring(
                    1,
                    $ParsedValue.Length - 1
                );
            }

            # Cut spaces after names of inputs
            while ($ParsedValue[$ParsedValue.Length - 1] -eq ' ') {
                $ParsedValue = $ParsedValue.Substring(
                    0,
                    $ParsedValue.Length - 1
                );
            }
            $Values += $ParsedValue.ToLower();
        }
    } else {
        $Values += $Value.Replace(' ', '').ToLower();
    }

    # Filter out duplicate entries
    $Values = $Values | Select-Object -Unique;
    $StructuredCommand.Add($Command, $Values);
    return $StructuredCommand;
}

return $WebHelper;