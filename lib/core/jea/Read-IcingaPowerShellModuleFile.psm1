function Read-IcingaPowerShellModuleFile()
{
    param (
        [string]$File,
        [string]$FileContent = ''
    );

    if (([string]::IsNullOrEmpty($File) -Or (Test-Path -Path $File) -eq $FALSE) -And [string]::IsNullOrEmpty($FileContent)) {
        return '';
    }

    if ([string]::IsNullOrEmpty($FileContent)) {
        $FileContent = Read-IcingaFileSecure -File $File;
    }

    $PSParser             = [System.Management.Automation.PSParser]::Tokenize($FileContent, [ref]$null);
    [array]$Comments      = @();
    [array]$RegexFilter   = @();
    [string]$RegexPattern = '';
    [array]$CommandList   = @();
    [array]$FunctionList  = @();
    [hashtable]$CmdCache  = @{ };
    [hashtable]$FncCache  = @{ };
    [int]$Index           = 0;

    foreach ($entry in $PSParser) {
        if ($entry.Type -eq 'Comment') {
            $Comments += Select-Object -InputObject $entry -ExpandProperty 'Content';
        } elseif ($entry.Type -eq 'Command') {
            if ($CmdCache.ContainsKey($entry.Content) -eq $FALSE) {
                $CommandList += [string]$entry.Content;
                $CmdCache.Add($entry.Content, 0);
            }
        } elseif ($entry.Type -eq 'CommandArgument') {
            if ($PSParser[$index - 1].Type -eq 'Keyword' -And $PSParser[$index - 1].Content.ToLower() -eq 'function') {
                if ($FncCache.ContainsKey($entry.Content) -eq $FALSE) {
                    $FunctionList += [string]$entry.Content;
                    $FncCache.Add($entry.Content, 0);
                }
            }
        }

        $Index += 1;
    }

    foreach ($entry in $Comments) {
        $RegexFilter += [regex]::Escape($entry);
    }

    $RegexPattern = [string]::Join('|', $RegexFilter);

    return @{
        'NormalisedContent' = ($FileContent -Replace $RegexPattern -Split '\r?\n' -NotMatch '^\s*$');
        'RawContent'        = $FileContent;
        'CommandList'       = $CommandList;
        'FunctionList'      = $FunctionList;
    };
}
