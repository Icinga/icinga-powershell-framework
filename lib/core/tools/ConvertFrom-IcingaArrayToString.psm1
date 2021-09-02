function ConvertFrom-IcingaArrayToString()
{
    param (
        [array]$Array            = @(),
        [switch]$AddQuotes       = $FALSE,
        [switch]$UseSingleQuotes = $FALSE,
        [switch]$SecureContent   = $FALSE
    );

    if ($null -eq $Array -Or $Array.Count -eq 0) {
        if ($AddQuotes) {
            if ($UseSingleQuotes) {
                return "''";
            }

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
            if ($UseSingleQuotes) {
                $NewArray += ([string]::Format("'{0}'", $entry));
            } else {
                $NewArray += ([string]::Format('"{0}"', $entry));
            }
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
