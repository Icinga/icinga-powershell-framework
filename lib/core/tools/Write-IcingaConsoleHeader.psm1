function Write-IcingaConsoleHeader()
{
    param (
        [array]$HeaderLines = @()
    );

    [array]$ParsedHeaders  = @();
    [int]$MaxHeaderLength  = 0;
    [int]$TableHeaderCount = 0;
    [array]$TableHeader    = @();
    [array]$SeverityData   = @();

    Import-LocalizedData `
        -BaseDirectory (Get-IcingaFrameworkRootPath) `
        -FileName 'icinga-powershell-framework.psd1' `
        -BindingVariable IcingaFrameworkData;

    foreach ($line in $HeaderLines) {
        $line = $line.Replace('$FrameworkVersion', $IcingaFrameworkData.PrivateData.Version);
        $line = $line.Replace('$Copyright', $IcingaFrameworkData.Copyright);
        $line = $line.Replace('$UserDomain', $env:USERDOMAIN);
        $line = $line.Replace('$Username', $env:USERNAME);

        $ParsedHeaders += $line;
    }

    foreach ($line in $ParsedHeaders) {
        if ($line.Contains('[Notice]') -Or $line.Contains('[Warning]') -Or $line.Contains('Error')) {
            continue
        }

        if ($MaxHeaderLength -lt $line.Length) {
            $MaxHeaderLength = $line.Length
        }
    }

    $TableHeaderCount = $MaxHeaderLength + 6;

    while ($TableHeaderCount -ne 0) {
        $TableHeader += '*';
        $TableHeaderCount -= 1;
    }

    $TableHeaderCount = $MaxHeaderLength + 6;

    Write-IcingaConsolePlain ([string]::Join('', $TableHeader));

    foreach ($line in $ParsedHeaders) {
        [array]$LeftSpacing = @();
        [array]$RightSpacing = @();

        if ($line.Length -lt $MaxHeaderLength) {
            $Spacing = [math]::floor(($MaxHeaderLength - $line.Length) / 2);

            while ($Spacing -gt 0) {
                $LeftSpacing  += ' ';
                $RightSpacing += ' ';
                $Spacing      -= 1;
            }

            if ($TableHeaderCount -gt ($line.Length + $LeftSpacing.Count + $RightSpacing.Count + 6)) {
                [int]$RightOffset = $TableHeaderCount - ($line.Length + $LeftSpacing.Count + $RightSpacing.Count + 6)
                while ($RightOffset -gt 0) {
                    $RightSpacing += ' ';
                    $RightOffset  -= 1;
                }
            }
        }

        if ($line.Contains('[Notice]') -Or $line.Contains('[Warning]') -Or $line.Contains('Error')) {
            $SeverityData += $line;
            continue;
        }

        $HeaderMessage = [string]::Format('**{1} {0} {2}**', $line, ([string]::Join('', $LeftSpacing)), ([string]::Join('', $RightSpacing)));

        Write-IcingaConsolePlain -Message $HeaderMessage;
    }

    Write-IcingaConsolePlain ([string]::Join('', $TableHeader));

    if ($SeverityData.Count -ne 0) {
        Write-IcingaConsolePlain -Message '';

        foreach ($entry in $SeverityData) {
            if (Write-IcingaConsoleTextColorSplit -Pattern '[Warning]' -Message $entry -ForeColor 'DarkYellow') {
                continue;
            }

            if (Write-IcingaConsoleTextColorSplit -Pattern '[Error]' -Message $entry -ForeColor 'Red') {
                continue;
            }

            if (Write-IcingaConsoleTextColorSplit -Pattern '[Notice]' -Message $entry -ForeColor 'Green') {
                continue;
            }
        }
    }
}
