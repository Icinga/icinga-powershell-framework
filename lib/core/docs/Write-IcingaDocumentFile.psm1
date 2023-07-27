function Write-IcingaDocumentFile()
{
    param (
        [string]$Name       = $null,
        [switch]$ClearCache = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify an internal name for the documentation object';
        return;
    }

    Write-IcingaFileSecure -File $Global:Icinga.Private.Documentation[$Name]['Path'] -Value $Global:Icinga.Private.Documentation[$Name]['Content'].ToString();

    if ($ClearCache) {
        $Global:Icinga.Private.Documentation.Remove($Name);
    }
}
