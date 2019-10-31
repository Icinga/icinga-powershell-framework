function Get-IcingaAgentInstallerAnswerInput()
{
    param(
        $Prompt,
        [ValidateSet("y","n","v")]
        $Default,
        $DefaultInput   = '',
        [switch]$Secure
    );

    $DefaultAnswer = '';

    if ($Default -eq 'y') {
        $DefaultAnswer = ' (Y/n)';
    } elseif ($Default -eq 'n') {
        $DefaultAnswer = ' (y/N)';
    } elseif ($Default -eq 'v') {
        if ([string]::IsNullOrEmpty($DefaultInput) -eq $FALSE) {
            $DefaultAnswer = [string]::Format(' (Default: "{0}")', $DefaultInput);
        }
    }

    if (-Not $Secure) {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer));
    } else {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer)) -AsSecureString;
    }

    if ($Default -ne 'v') {
        $answer = $answer.ToLower();

        $returnValue = 0;
        if ([string]::IsNullOrEmpty($answer) -Or $answer -eq $Default) {
            $returnValue = 1;
        } else {
            $returnValue = 0;
        }

        return @{
            'result' = $returnValue;
            'answer' = '';
        }
    }

    if ([string]::IsNullOrEmpty($answer)) {
        $answer = $DefaultInput;
    }

    return @{
        'result' = 2;
        'answer' = $answer;
    }
}
