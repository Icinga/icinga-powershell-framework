function New-IcingaDocumentObject()
{
    param (
        [string]$Name  = $null,
        [string]$Path  = $null,
        [switch]$Force = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify an internal name for the documentation object';
        return;
    }

    if ([string]::IsNullOrEmpty($Path)) {
        Write-IcingaConsoleError 'You have to specify a path on where the document should be written to';
        return;
    }

    if ($Global:Icinga.Private.Documentation.ContainsKey($Name)) {
        if ($Force -eq $FALSE) {
            Write-IcingaConsoleError 'A documentation object with the name "{0}" does already exist in memory. Use -Force to overwrite it' -Objects $Name;
            return;
        }

        $Global:Icinga.Private.Documentation[$Name] = @{
            'Path'    = $Path;
            'Content' = (New-Object -TypeName 'System.Text.StringBuilder');
        }
    } else {
        $Global:Icinga.Private.Documentation.Add(
            $Name,
            @{
                'Path'    = $Path;
                'Content' = (New-Object -TypeName 'System.Text.StringBuilder');
            }
        );
    }
}
