function Write-IcingaConsoleHeader()
{
    param (
        [array]$HeaderLines = @()
    );

    [array]$ParsedHeaders  = @();
    [int]$MaxHeaderLength  = 0;
    [int]$TableHeaderCount = 0;
    [array]$TableHeader    = @();

    Import-LocalizedData `
        -BaseDirectory (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'icinga-powershell-framework') `
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
        Write-IcingaConsolePlain -Message '**{1} {0} {2}**' -Objects $line, ([string]::Join('', $LeftSpacing)), ([string]::Join('', $RightSpacing));
    }

    Write-IcingaConsolePlain ([string]::Join('', $TableHeader));
}
