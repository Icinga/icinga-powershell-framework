function ConvertTo-JsonUTF8Bytes()
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $TRUE, ValueFromPipeline = $TRUE)]
        $InputObject      = $null,
        [int]$Depth       = 10,
        [switch]$Compress = $FALSE
    );

    $JsonBody  = ConvertTo-Json -InputObject $InputObject -Depth 100 -Compress;
    $UTF8Bytes = ([System.Text.Encoding]::UTF8.GetBytes($JsonBody));

    # Do not remove the "," as we require to force our PowerShell to handle our return value
    # as proper collection
    return , $UTF8Bytes;
}
