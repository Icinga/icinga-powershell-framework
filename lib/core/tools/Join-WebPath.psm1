function Join-WebPath()
{
    param(
        [string]$Path,
        [string]$ChildPath
    );

    if ([string]::IsNullOrEmpty($Path) -Or [string]::IsNullOrEmpty($ChildPath)) {
        return $Path;
    }

    [int]$Length = $Path.Length;
    [int]$Slash  = $Path.LastIndexOf('/') + 1;

    if ($Length -eq $Slash) {
        $Path = $Path.Substring(0, $Path.Length - 1);
    }

    if ($ChildPath[0] -eq '/') {
        return ([string]::Format('{0}{1}', $Path, $ChildPath));
    }

    return ([string]::Format('{0}/{1}', $Path, $ChildPath));
}
