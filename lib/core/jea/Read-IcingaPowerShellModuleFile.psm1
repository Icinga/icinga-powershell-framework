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

    $PSParser              = [System.Management.Automation.PSParser]::Tokenize($FileContent, [ref]$null);
    [array]$Comments       = @();
    [array]$RegexFilter    = @();
    [string]$RegexPattern  = '';
    [array]$CommandList    = @();
    [array]$FunctionList   = @();
    [hashtable]$CmdCache   = @{ };
    [hashtable]$FncCache   = @{ };
    [int]$Index            = 0;
    [bool]$ThreadCommand   = $FALSE;
    [bool]$ThreadFetchNext = $FALSE;
    [bool]$ShellCommand    = $FALSE;
    [bool]$ShellGroupStart = $FALSE;

    foreach ($entry in $PSParser) {
        if ($entry.Type -eq 'Comment') {
            $Comments += Select-Object -InputObject $entry -ExpandProperty 'Content';
        } elseif ($entry.Type -eq 'Command') {
            if ($CmdCache.ContainsKey($entry.Content) -eq $FALSE) {
                $CommandList += [string]$entry.Content;
                $CmdCache.Add($entry.Content, 0);
            }

            # We need to include commands we call with New-IcingaThreadInstance e.g.
            # => New-IcingaThreadInstance -Name "Main" -ThreadPool (Get-IcingaThreadPool -Name 'MainPool') -Command 'Add-IcingaForWindowsDaemon' -Start;
            if ($entry.Content.ToLower() -eq 'new-icingathreadinstance') {
                $ThreadCommand = $TRUE;
            }
        } elseif ($entry.Type -eq 'CommandArgument') {
            if ($PSParser[$index - 1].Type -eq 'Keyword' -And $PSParser[$index - 1].Content.ToLower() -eq 'function') {
                if ($FncCache.ContainsKey($entry.Content) -eq $FALSE) {
                    $FunctionList += [string]$entry.Content;
                    $FncCache.Add($entry.Content, 0);
                }
            }
        } elseif ($entry.Type -eq 'Member' -And $entry.Content.ToLower() -eq 'addcommand') {
            # In case we have objects that use .AddCommand() we should add these to our function list e.g.
            # => [void]$Shell.AddCommand('Set-IcingaEnvironmentGlobal');
            $ShellCommand = $TRUE;
        }

        # If we reached -Command for New-IcingaThreadInstance, check for the String element and add its value to our function list e.g.
        # => Add-IcingaForWindowsDaemon
        if ($ThreadFetchNext) {
            if ($entry.Type -eq 'String') {
                if (Test-IcingaFunction $entry.Content) {
                    if ($FncCache.ContainsKey($entry.Content) -eq $FALSE) {
                        $FunctionList += [string]$entry.Content;
                        $FncCache.Add($entry.Content, 0);
                    }
                }
            }
            $ThreadFetchNext = $FALSE;
        }

        # If we found the command New-IcingaThreadInstance inside ths script, loop until we reach -Command
        if ($ThreadCommand) {
            if ($entry.Type -eq 'CommandParameter' -And $entry.Content.ToLower() -eq '-command') {
                $ThreadFetchNext = $TRUE;
                $ThreadCommand   = $FALSE;
            }
        }

        # If we reached the string content of our .AddCommand() object. add its value to our function list e.g.
        # => Set-IcingaEnvironmentGlobal
        if ($ShellGroupStart) {
            if ($entry.Type -eq 'String') {
                if (Test-IcingaFunction $entry.Content) {
                    if ($FncCache.ContainsKey($entry.Content) -eq $FALSE) {
                        $FunctionList += [string]$entry.Content;
                        $FncCache.Add($entry.Content, 0);
                    }
                }

                $ShellGroupStart = $FALSE;
            }
        }

        # If we found an .AddArgument() member, continue until our group starts with (
        if ($ShellCommand) {
            if ($entry.Type -eq 'GroupStart' -And $entry.Content.ToLower() -eq '(') {
                $ShellCommand    = $FALSE;
                $ShellGroupStart = $TRUE;
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
