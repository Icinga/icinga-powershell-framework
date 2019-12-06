function New-IcingaTemporaryDirectory()
{
    [string]$TmpDirectory  = '';
    [string]$DirectoryPath = '';

    while ($TRUE) {
        $TmpDirectory  = [string]::Format('tmp_icinga{0}.d', (Get-Random));
        $DirectoryPath = Join-Path $Env:TMP -ChildPath $TmpDirectory;

        if ((Test-Path $DirectoryPath) -eq $FALSE) {
            break;
        }
    }

    return (New-Item -Path $DirectoryPath -ItemType Directory);
}
