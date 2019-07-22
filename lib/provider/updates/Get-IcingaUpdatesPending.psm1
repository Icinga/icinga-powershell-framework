function Get-IcingaUpdatesPending ()
{

    [hashtable]$PendingUpdates         = @{};
    [hashtable]$PendingUpdateNameCache = @{};
    # Fetch all informations about installed updates and add them
    $WindowsUpdates            = New-Object -ComObject "Microsoft.Update.Session";
    $SearchIndex               = $WindowsUpdates.CreateUpdateSearcher();

    try {
        # Get a list of current pending updates which are not yet installed on the system
        $Pending = $SearchIndex.Search("IsInstalled=0");
        $PendingUpdates.Add('count', $Pending.Updates.Count);

        foreach ($update in $Pending.Updates) {
            [hashtable]$PendingUpdateDetails = @{};
            $PendingUpdateDetails.Add('Title', $update.Title);
            $PendingUpdateDetails.Add('Deadline', $update.Deadline);
            $PendingUpdateDetails.Add('Description', $update.Description);
            $PendingUpdateDetails.Add('IsBeta', $update.IsBeta);
            $PendingUpdateDetails.Add('IsDownloaded', $update.IsDownloaded);
            $PendingUpdateDetails.Add('IsHidden', $update.IsHidden);
            $PendingUpdateDetails.Add('IsInstalled', $update.IsInstalled);
            $PendingUpdateDetails.Add('IsMandatory', $update.IsMandatory);
            $PendingUpdateDetails.Add('IsUninstallable', $update.IsUninstallable);
            $PendingUpdateDetails.Add('Languages', $update.Languages);
            $PendingUpdateDetails.Add('LastDeploymentChangeTime', $update.LastDeploymentChangeTime);
            $PendingUpdateDetails.Add('MaxDownloadSize', $update.MaxDownloadSize);
            $PendingUpdateDetails.Add('MinDownloadSize', $update.MinDownloadSize);
            $PendingUpdateDetails.Add('MoreInfoUrls', $update.MoreInfoUrls);
            $PendingUpdateDetails.Add('MsrcSeverity', $update.MsrcSeverity);
            $PendingUpdateDetails.Add('RecommendedCpuSpeed', $update.RecommendedCpuSpeed);
            $PendingUpdateDetails.Add('RecommendedHardDiskSpace', $update.RecommendedHardDiskSpace);
            $PendingUpdateDetails.Add('RecommendedMemory', $update.RecommendedMemory);
            $PendingUpdateDetails.Add('ReleaseNotes', $update.ReleaseNotes);
            $PendingUpdateDetails.Add('SecurityBulletinIDs', $update.SecurityBulletinIDs);
            $PendingUpdateDetails.Add('SupersededUpdateIDs', $update.SupersededUpdateIDs);
            $PendingUpdateDetails.Add('SupportUrl', $update.SupportUrl);
            $PendingUpdateDetails.Add('Type', $update.Type);
            $PendingUpdateDetails.Add('UninstallationNotes', $update.UninstallationNotes);
            $PendingUpdateDetails.Add('UninstallationBehavior', $update.UninstallationBehavior);
            $PendingUpdateDetails.Add('UninstallationSteps', $update.UninstallationSteps);
            $PendingUpdateDetails.Add('KBArticleIDs', $update.KBArticleIDs);
            $PendingUpdateDetails.Add('DeploymentAction', $update.DeploymentAction);
            $PendingUpdateDetails.Add('DownloadPriority', $update.DownloadPriority);
            $PendingUpdateDetails.Add('RebootRequired', $update.RebootRequired);
            $PendingUpdateDetails.Add('IsPresent', $update.IsPresent);
            $PendingUpdateDetails.Add('CveIDs', $update.CveIDs);
            $PendingUpdateDetails.Add('BrowseOnly', $update.BrowseOnly);
            $PendingUpdateDetails.Add('PerUser', $update.PerUser);
            $PendingUpdateDetails.Add('AutoSelection', $update.AutoSelection);
            $PendingUpdateDetails.Add('AutoDownload', $update.AutoDownload);

            [string]$name = [string]::Format('{0} [{1}]', $update.Title, $update.LastDeploymentChangeTime);

            if ($PendingUpdateNameCache.ContainsKey($name) -eq $FALSE) {
                $PendingUpdateNameCache.Add($name, 1);
            } else {
                $PendingUpdateNameCache[$name] += 1;
                $name = [string]::Format('{0} ({1})', $name, $PendingUpdateNameCache[$name]);
            }

            $PendingUpdates.Add($name, $PendingUpdateDetails);
        }
    } catch {
        if ($PendingUpdates.ContainsKey('Count') -eq $FALSE) {
            $PendingUpdates.Add('count', 0);
        } else {
            $PendingUpdates['count'] =  0;
        }
        $PendingUpdates.Add('error', [string]::Format(
            'Failed to query Windows Update server: {0}',
            $_.Exception.Message
        ));
    }

    return $PendingUpdates;
}