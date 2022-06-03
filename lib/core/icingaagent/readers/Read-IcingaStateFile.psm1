function Read-IcingaStateFile()
{
    param (
        [switch]$WriteOutput = $FALSE
    );

    [string]$StateFilePath = Join-Path -Path $ENV:ProgramData -ChildPath 'icinga2\var\lib\icinga2\icinga2.state';

    if ((Test-Path $StateFilePath) -eq $FALSE) {
        return $TRUE;
    }

    $StateFileContent = Get-Content -Path $StateFilePath -Encoding 'UTF8' -Raw;
    $FileInformation  = Get-Item -Path $StateFilePath;

    if ([string]::IsNullOrEmpty($StateFileContent)) {
        return $FALSE;
    }

    while ($TRUE) {
        try {
            if ([string]::IsNullOrEmpty($StateFileContent)) {
                break;
            }

            if ($StateFileContent.Contains(':') -eq $FALSE) {
                Write-IcingaTestOutput -Severity 'Failed' -Message 'The start index of the Icinga Agent state file could not be found. The file seems to be corrupt.' -DropMessage:(-Not $WriteOutput);
                return $FALSE;
            }

            [int]$IndexOfJSON   = $StateFileContent.IndexOf(':');
            [int]$StatementSize = $StateFileContent.SubString(0, $IndexOfJSON);
            [string]$JSONString = $StateFileContent.Substring($IndexOfJSON + 1, $StatementSize);
            [int]$TotalMsgLen   = $IndexOfJSON + $StatementSize + 2;
            $StateFileContent   = $StateFileContent.Substring($TotalMsgLen, $StateFileContent.Length - $TotalMsgLen);
            $JsonValid          = ConvertFrom-Json -InputObject $JSONString -ErrorAction Stop;
        } catch {
            [string]$ErrMessage = [string]::Format('The Icinga Agent state file validation failed with an exception: "{0}"', $_.Exception.Message);
            Write-IcingaTestOutput -Severity 'Failed' -Message $ErrMessage -DropMessage:(-Not $WriteOutput);

            return $FALSE;
        }
    }

    return $TRUE;
}
