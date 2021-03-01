function ConvertFrom-IcingaArrayToString()
{
    param (
        [array]$Array          = @(),
        [switch]$AddQuotes     = $FALSE,
        [switch]$SecureContent = $FALSE
    );

    if ($null -eq $Array -Or $Array.Count -eq 0) {
        if ($AddQuotes) {
            return '""';
        }

        return '';
    }

    [array]$NewArray = @();

    if ($AddQuotes) {
        foreach ($entry in $Array) {
            if ($SecureContent) {
                $entry = '***';
            }
            $NewArray += ([string]::Format('"{0}"', $entry));
        }
    } else {
        if ($SecureContent) {
            foreach ($entry in $Array) {
                $NewArray += '***';
            }
        } else {
            $NewArray = $Array;
        }
    }

    return ([string]::Join(', ', $NewArray));
}
