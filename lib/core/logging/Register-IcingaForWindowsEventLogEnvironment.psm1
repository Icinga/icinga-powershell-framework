<#
    This code is broken and does not work. The idea is, that we create
    a log entry within the Windows EventLog with a folder structure
    Icinga
    |_ Icinga for Windows
        |_ Admin
        |_ Debug
    |_ Icinga Agent
        |_ Admin
        |_ Debug

    But it doesn't work. Ideas welcome. The entries are created, but the structure
    is not represented
#>

<#
function Register-IcingaForWindowsEventLogFolder()
{
    param (
        [string]$RootFolder  = 'Icinga',
        [string]$Application = 'Icinga for Windows',
        [string]$Folder      = ''
    );

    if ([string]::IsNullOrEmpty($Folder)) {
        Write-IcingaConsoleError -Message 'You have to specify a folder name';
        return;
    }

    # Base config
    [string]$IcingaGUID       = '{d59d4eba-fc0e-413e-b245-c53d259428c7}'
    [string]$LogRoot          = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT';
    [string]$ApplicationLog   = 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application';
    [string]$LogChannel       = [string]::Format('{0}\Channels', $LogRoot);
    [string]$LogPublisher     = [string]::Format('{0}\Publishers\{1}', $LogRoot, $IcingaGUID);
    [string]$FolderPath       = [string]::Format('{0}-{1}', $RootFolder, $Application);
    [string]$LogFolderName    = [string]::Format('{0}/{1}', $FolderPath, $Folder);
    [string]$ChannelReference = [string]::Format('{0}\ChannelReference', $LogPublisher);
    [string]$ChannelEntry     = [string]::Format('{0}\{1}', $LogChannel, $LogFolderName);
    [string]$ApplicationEntry = [string]::Format('{0}\{1}', $ApplicationLog, $FolderPath);
    [string]$LogFile          = [string]::Format('{0}\System32\Winevt\Logs\{1}%4{2}.evtx', $Env:SystemRoot, $FolderPath, $Folder);
    [int]$FolderCount         = 1;

    if (Test-Path $ChannelEntry) {
        Write-Host 'This log does already exist';
        return;
    }

    # Create the file to log into and the registry key for pointing to our GUID
    if ((Test-Path $ApplicationEntry) -eq $FALSE) {
        New-Item -Path $ApplicationEntry | Out-Null;
        New-ItemProperty -Path $ApplicationEntry -Name 'ProviderGuid' -PropertyType 'String' -Value $IcingaGUID | Out-Null;
        New-ItemProperty -Path $ApplicationEntry -Name 'File' -PropertyType 'ExpandString' -Value $LogFile | Out-Null;
    }

    # Create the channel data
    # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels
    $HKLMRoot = Get-Item -Path 'HKLM:\';
    $HKLMRoot = $HKLMRoot.OpenSubKey('SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels', $TRUE);
    $HKLMRoot.CreateSubKey($LogFolderName) | Out-Null;
    $HKLMRoot.Close();

    New-ItemProperty -Path $ChannelEntry -Name 'OwningPublisher' -PropertyType 'String' -Value $IcingaGUID | Out-Null;
    New-ItemProperty -Path $ChannelEntry -Name 'Enabled' -PropertyType 'DWord' -Value 1 | Out-Null;
    New-ItemProperty -Path $ChannelEntry -Name 'Type' -PropertyType 'DWord' -Value 0 | Out-Null;
    New-ItemProperty -Path $ChannelEntry -Name 'Isolation' -PropertyType 'DWord' -Value 0 | Out-Null;

    # Create the publisher data
    if ((Test-Path $LogPublisher) -eq $FALSE) {
        # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{d59d4eba-fc0e-413e-b245-c53d259428c7}
        New-Item -Path $LogPublisher -Value $FolderPath | Out-Null;
        New-ItemProperty -Path $LogPublisher -Name 'Enabled' -PropertyType 'DWord' -Value 1 | Out-Null;
        # HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Publishers\{d59d4eba-fc0e-413e-b245-c53d259428c7}\ChannelReference
        New-Item -Path $ChannelReference | Out-Null;

        # Add Count
        New-ItemProperty -Path $ChannelReference -Name 'Count' -PropertyType 'DWord' -Value $FolderCount | Out-Null;
    } else {
        [int]$FolderCount = (Get-ItemProperty -Path $ChannelReference -Name 'Count').Count + 1;
    }

    # At first, get all elements from the folder
    $RegisteredFolders = Get-ChildItem $ChannelReference;

    foreach ($knownFolder in $RegisteredFolders) {
        # Full path to our registry sub folder
        $FolderProperty = Get-ItemProperty -Path $knownFolder.PSPath;

        if ($FolderProperty.'(default)' -eq $LogFolderName) {
            Write-IcingaConsoleWarning -Message 'The EventLog folder "{0}" does already exist' -Objects $LogFolderName;
            return;
        }
    }

    [string]$NewFolderLocation = [string]::Format('{0}\{1}', $ChannelReference, ($FolderCount - 1));

    New-Item -Path $NewFolderLocation -Value $LogFolderName | Out-Null;
    New-ItemProperty -Path $NewFolderLocation -Name 'Flags' -PropertyType 'DWord' -Value 0 | Out-Null;
    New-ItemProperty -Path $NewFolderLocation -Name 'Id' -PropertyType 'DWord' -Value 16 | Out-Null;

    # Update Count
    Set-ItemProperty -Path $ChannelReference -Name 'Count' -Value $FolderCount | Out-Null;
}
#>
