function Add-IcingaDocumentContent()
{
    param (
        [string]$Name      = $null,
        [string]$Content   = '',
        [switch]$NoNewLine = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify an internal name for the documentation object';
        return;
    }

    if ($Global:Icinga.Private.Documentation.ContainsKey($Name) -eq $false) {
        Write-IcingaConsoleError 'A documentation object with the name "{0}" does not exist' -Objects $Name;
        return;
    }

    if ($NoNewLine) {
        $Global:Icinga.Private.Documentation[$Name]['Content'].Append($Content) | Out-Null;
    } else {
        $Global:Icinga.Private.Documentation[$Name]['Content'].AppendLine($Content) | Out-Null;
    }
}
