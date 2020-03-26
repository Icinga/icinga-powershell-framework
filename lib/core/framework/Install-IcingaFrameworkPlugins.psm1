function Install-IcingaFrameworkPlugins()
{
    param(
        [string]$PluginsUrl
    );

    [Hashtable]$Result = Install-IcingaFrameworkComponent `
                            -Name 'plugins' `
                            -GitHubUser 'Icinga' `
                            -Url $PluginsUrl;

    return @{
        'PluginUrl' = $Result.RepoUrl;
    };
}
