function Remove-IcingaFrameworkDependencyFile()
{
    $DependencyFile = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'framework_dependencies.json';

    if (-Not (Test-Path $DependencyFile)) {
        return;
    }

    Remove-ItemSecure -Path $DependencyFile -Force | Out-Null;
}
