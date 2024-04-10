function Test-IcingaJSONObject()
{
    param (
        [string]$InputObject = $null
    );

    if ([string]::IsNullOrEmpty($InputObject)) {
        return $FALSE;
    }

    try {
        $JSONContent = ConvertFrom-Json -InputObject $InputObject -ErrorAction Stop;
        return $TRUE;
    } catch {
        [string]$ErrMsg = $_.Exception.Message;

        if ($ErrMsg.Contains('(') -And $ErrMsg.Contains(')')) {
            try {
                [int]$ErrLocation     = $ErrMsg.Substring($ErrMsg.IndexOf('(') + 1, $ErrMsg.IndexOf(')') - $ErrMsg.IndexOf('(') - 1) - 1;
                [string]$ExceptionMsg = $ErrMsg.Substring(0, $ErrMsg.IndexOf(')') + 1);
                [string]$ErrOutput    = $InputObject.Substring(0, $ErrLocation);
                [array]$ErrArray      = $ErrOutput.Split("`n");
                [string]$Indentation  = '';
                [string]$ErrLine      = '';

                [int]$tmp = 0;
                foreach ($entry in $ErrArray) {
                    $tmp += 1;
                }

                foreach ($character in ([string]($ErrArray[$ErrArray.Count - 2])).ToCharArray()) {
                    if ([string]::IsNullOrEmpty($character) -Or $character -eq ' ') {
                        $Indentation += ' ';
                    } else {
                        $ErrLine += '^';
                    }
                }

                $ErrOutput = [string]::Format('{0}{1}{2}{3}', $ErrOutput, (New-IcingaNewLine), $Indentation, $ErrLine);

                Write-IcingaConsoleError 'Failed to parse JSON object. Exception: {0}{1}{2}' -Objects $ExceptionMsg, (New-IcingaNewLine), $ErrOutput;
                return $FALSE;
            } catch {
                Write-IcingaConsoleError 'Failed to parse JSON object: {0}' -Objects $ErrMsg;
                return $FALSE;
            }
        }
    }

    return $FALSE;
}
