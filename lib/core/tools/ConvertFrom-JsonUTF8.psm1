function ConvertFrom-JsonUTF8()
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $TRUE, ValueFromPipeline = $TRUE)]
        $InputObject = $null
    );

    # We need to properly encode our String to UTF8
    $ContentBytes = [System.Text.Encoding]::Default.GetBytes($InputObject);
    $UTF8String   = [System.Text.Encoding]::UTF8.GetString($ContentBytes);

    # Return the correct encoded JSON
    return (ConvertFrom-Json -InputObject $UTF8String);
}
