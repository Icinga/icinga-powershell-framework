function Start-IcingaProcess()
{
    param(
        [string]$Executable,
        [string]$Arguments,
        [switch]$FlushNewLines
    );

    $processData = New-Object System.Diagnostics.ProcessStartInfo;
    $processData.FileName = $Executable;
    $processData.RedirectStandardError = $true;
    $processData.RedirectStandardOutput = $true;
    $processData.UseShellExecute = $false;
    $processData.Arguments = $Arguments;

    $process = New-Object System.Diagnostics.Process;
    $process.StartInfo = $processData;
    $process.Start() | Out-Null;

    $stdout = $process.StandardOutput.ReadToEnd();
    $stderr = $process.StandardError.ReadToEnd();
    $process.WaitForExit();

    if ($flushNewLines) {
        $stdout = $stdout.Replace("`n", '').Replace("`r", '');
        $stderr = $stderr.Replace("`n", '').Replace("`r", '');
    } else {
        if ($stdout.Contains("`n")) {
            $stdout = $stdout.Substring(0, $stdout.LastIndexOf("`n"));
        }
    }
    return @{
        'Message'  = $stdout;
        'Error'    = $stderr;
        'ExitCode' = $process.ExitCode;
    };
}
