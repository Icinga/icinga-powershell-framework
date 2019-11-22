function New-IcingaTemporaryFile()
{
    [string]$TmpFile  = '';
    [string]$FilePath = '';

    while ($TRUE) {
        $TmpFile  = [string]::Format('tmp_icinga{0}.tmp', (Get-Random));
        $FilePath = Join-Path $Env:TMP -ChildPath $TmpFile;

        if ((Test-Path $FilePath) -eq $FALSE) {
            break;
        }
    }

    return (New-Item -Path $FilePath -ItemType File);
}
