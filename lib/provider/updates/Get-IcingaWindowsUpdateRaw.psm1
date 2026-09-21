<#
.SYNOPSIS
    Queries the Windows Update COM object for raw update objects.
.DESCRIPTION
    Directly queries the Windows Update Agent COM object ('Microsoft.Update.Session')
    using the specified search criteria and converts the unmanaged COM results into
    serializable PowerShell custom objects.

    This ensures that COM collections such as categories and KB article IDs are
    properly converted into native arrays and can be safely serialized or used
    directly by monitoring checks.
.FUNCTIONALITY
    Fetches raw Windows Update objects via the Windows Update COM API.
.PARAMETER Criteria
    The search criteria query string for the Windows Update searcher.
    Defaults to 'IsInstalled=0'.
.OUTPUTS
    [array] An array of [PSCustomObject] instances representing the found updates.
.EXAMPLE
    PS>Get-IcingaWindowsUpdateRaw;
.EXAMPLE
    PS>Get-IcingaWindowsUpdateRaw -Criteria 'IsInstalled=0 and Type="Software"';
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaWindowsUpdateRaw()
{
    param (
        [string]$Criteria = 'IsInstalled=0'
    );

    [array]$UpdateList = @();

    try {
        $WindowsUpdates = New-Object -ComObject 'Microsoft.Update.Session' -ErrorAction Stop;
        $SearchIndex    = $WindowsUpdates.CreateUpdateSearcher();
        # Get a list of current pending updates which are not yet installed on the system
        $Pending        = $SearchIndex.Search($Criteria);

        foreach ($update in $Pending.Updates) {
            [array]$categories = @();
            if ($null -ne $update.Categories) {
                foreach ($category in $update.Categories) {
                    $categories += [PSCustomObject]@{
                        'Name'        = $category.Name;
                        'CategoryID'  = $category.CategoryID;
                        'Type'        = $category.Type;
                        'Description' = $category.Description;
                    };
                }
            }

            [array]$kbArticleIDs        = @();
            if ($null -ne $update.KBArticleIDs) {
                $kbArticleIDs = @($update.KBArticleIDs);
            }
            [array]$securityBulletinIDs = @();
            if ($null -ne $update.SecurityBulletinIDs) {
                $securityBulletinIDs = @($update.SecurityBulletinIDs);
            }
            [array]$supersededUpdateIDs = @();
            if ($null -ne $update.SupersededUpdateIDs) {
                $supersededUpdateIDs = @($update.SupersededUpdateIDs);
            }
            [array]$cveIDs              = @();
            if ($null -ne $update.CveIDs) {
                $cveIDs = @($update.CveIDs);
            }
            [array]$languages           = @();
            if ($null -ne $update.Languages) {
                $languages = @($update.Languages);
            }
            [array]$moreInfoUrls        = @();
            if ($null -ne $update.MoreInfoUrls) {
                $moreInfoUrls = @($update.MoreInfoUrls);
            }
            [array]$uninstallationSteps = @();
            if ($null -ne $update.UninstallationSteps) {
                $uninstallationSteps = @($update.UninstallationSteps);
            }

            $UpdateList += [PSCustomObject]@{
                'Title'                    = $update.Title;
                'Description'              = $update.Description;
                'Categories'               = $categories;
                'KBArticleIDs'             = $kbArticleIDs;
                'SecurityBulletinIDs'      = $securityBulletinIDs;
                'SupersededUpdateIDs'      = $supersededUpdateIDs;
                'CveIDs'                   = $cveIDs;
                'Languages'                = $languages;
                'MoreInfoUrls'             = $moreInfoUrls;
                'Deadline'                 = $update.Deadline;
                'IsBeta'                   = $update.IsBeta;
                'IsDownloaded'             = $update.IsDownloaded;
                'IsHidden'                 = $update.IsHidden;
                'IsInstalled'              = $update.IsInstalled;
                'IsMandatory'              = $update.IsMandatory;
                'IsUninstallable'          = $update.IsUninstallable;
                'LastDeploymentChangeTime' = $update.LastDeploymentChangeTime;
                'MaxDownloadSize'          = $update.MaxDownloadSize;
                'MinDownloadSize'          = $update.MinDownloadSize;
                'MsrcSeverity'             = $update.MsrcSeverity;
                'RecommendedCpuSpeed'      = $update.RecommendedCpuSpeed;
                'RecommendedHardDiskSpace' = $update.RecommendedHardDiskSpace;
                'RecommendedMemory'        = $update.RecommendedMemory;
                'ReleaseNotes'             = $update.ReleaseNotes;
                'SupportUrl'               = $update.SupportUrl;
                'Type'                     = $update.Type;
                'UninstallationNotes'      = $update.UninstallationNotes;
                'UninstallationBehavior'   = $update.UninstallationBehavior;
                'UninstallationSteps'      = $uninstallationSteps;
                'DeploymentAction'         = $update.DeploymentAction;
                'DownloadPriority'         = $update.DownloadPriority;
                'RebootRequired'           = $update.RebootRequired;
                'IsPresent'                = $update.IsPresent;
                'BrowseOnly'               = $update.BrowseOnly;
                'PerUser'                  = $update.PerUser;
                'AutoSelection'            = $update.AutoSelection;
                'AutoDownload'             = $update.AutoDownload;
            };
        }
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.WindowsUpdate -Force;
    } finally {
        $Pending        = $null;
        $SearchIndex    = $null;
        $WindowsUpdates = $null;
    }

    return $UpdateList;
}
