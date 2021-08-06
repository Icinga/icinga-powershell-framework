function New-IcingaThreadHash()
{
    param(
        [string]$ShellScript,
        [array]$Arguments
    );

    [string]$ScriptString = '';
    [string]$ArgString = ($Arguments | Out-String);
    if ($null -ne $ShellScript) {
        $ScriptString = $ShellScript.ToString();
    }
    return (Get-StringSha1 -Content ($ScriptString + $ArgString + (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff")));
}
