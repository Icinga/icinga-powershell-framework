Use-Icinga;

$UpdateDir     = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'provider\windows_updates';
$UpdateFile    = Join-Path -Path $UpdateDir -ChildPath 'pending.xml';
$UpdateTmpFile = Join-Path -Path $UpdateDir -ChildPath 'pending.xml.tmp';

# In case the file does not yet exist, create it once and ensure we update the permissions that
# noone besides the SYSTEM and Icinga for Windows user can access them
if (-not (Test-Path -Path $UpdateDir)) {
    New-Item -Path $UpdateDir -ItemType Directory | Out-Null;
    Set-IcingaUserPermissions;
}

while ($TRUE) {
    try {
        #$WindowsUpdates = Get-IcingaWindowsUpdatePendingList -AsTask;
        # Fetch all informations about installed updates and add them
        $WindowsUpdates = New-Object -ComObject 'Microsoft.Update.Session' -ErrorAction Stop;
        $SearchIndex    = $WindowsUpdates.CreateUpdateSearcher();
        # Get a list of current pending updates which are not yet installed on the system
        $Pending        = $SearchIndex.Search('IsInstalled=0');
        $XMLObj         = [System.Management.Automation.PSSerializer]::Serialize($Pending.Updates, 3);

        # First write the new update data to a tmp file to avoid race conditions
        Write-IcingaFileSecure -File $UpdateTmpFile -Value $XMLObj;

        # Now simply move the new tmp file to the target file - keep doing this until the file does not exist anymore
        # This atomic operation ensures that we do not have a corrupt file on disk
        while ((Test-Path -Path $UpdateTmpFile)) {
            Move-Item -Path $UpdateTmpFile -Destination $UpdateFile -Force -ErrorAction SilentlyContinue;
            Start-Sleep -Seconds 1;
        }
    } catch {
        Write-IcingaEventMessage -EventId 1200 -Namespace 'Framework' -Objects $UpdateFile, $XMLObj, $_.Exception.Message;
    } finally {
        $WindowsUpdates = $null;
        $SearchIndex    = $null;
        $Pending        = $null;
        $XMLObj         = $null;
        # Fetch Windows Updates every 10 minutes (600 seconds)
        Start-Sleep -Seconds 600;
    }
}
