<#
.SYNOPSIS
    Resolves a relative RemoteSource of a repository file against the location
    the repository file was loaded from
.DESCRIPTION
    Allows repository files to define their RemoteSource relative to themselves,
    like ".", "./" or "../stable". In case the repository file was loaded from
    "https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json", a
    RemoteSource of "." is resolved to "https://packages.icinga.com/IcingaForWindows/stable/".
    Absolute RemoteSource values are returned unmodified.
.PARAMETER RemoteSource
    The RemoteSource as defined inside the repository file
.PARAMETER RepositoryFile
    The full URL or path of the repository file itself
.OUTPUTS
    System.String
#>
function Resolve-IcingaRepositoryRemoteSource()
{
    param (
        [string]$RemoteSource   = $null,
        [string]$RepositoryFile = $null
    );

    if ([string]::IsNullOrEmpty($RemoteSource) -Or [string]::IsNullOrEmpty($RepositoryFile)) {
        return $RemoteSource;
    }

    [System.Uri]$AbsoluteSource = $null;

    if ([System.Uri]::TryCreate($RemoteSource, [System.UriKind]::Absolute, [ref]$AbsoluteSource)) {
        return $RemoteSource;
    }

    [System.Uri]$BaseUri = $null;

    if ([System.Uri]::TryCreate($RepositoryFile, [System.UriKind]::Absolute, [ref]$BaseUri) -eq $FALSE) {
        return $RemoteSource;
    }

    [System.Uri]$ResolvedUri = $null;

    if ([System.Uri]::TryCreate($BaseUri, $RemoteSource, [ref]$ResolvedUri) -eq $FALSE) {
        return $RemoteSource;
    }

    if ($ResolvedUri.IsFile) {
        return $ResolvedUri.LocalPath;
    }

    return $ResolvedUri.AbsoluteUri;
}
