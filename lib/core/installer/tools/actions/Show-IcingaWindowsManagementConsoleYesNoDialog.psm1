function Show-IcingaWindowsManagementConsoleYesNoDialog()
{
    param (
        [string]$Caption         = '',
        [string]$Command         = '',
        [hashtable]$CmdArguments = @{ },
        [array]$Value            = @(),
        [string]$DefaultInput    = '0',
        [switch]$JumpToSummary   = $FALSE,
        [switch]$Automated       = $FALSE,
        [switch]$Advanced        = $FALSE
    );

    $LastParent = Get-IcingaForWindowsInstallerLastParent;

    Show-IcingaForWindowsInstallerMenu `
        -Header ([string]::Format('Are you sure you want to perform this action: "{0}"?', $Caption)) `
        -Entries @(
            @{
                'Caption' = 'No';
                'Command' = $LastParent;
                'Help'    = 'Do not apply the last action and return without doing anything';
            },
            @{
                'Caption' = 'Yes';
                'Command' = $LastParent;
                'Help'    = "Apply the action and confirm it's execution";
            }
        ) `
        -DefaultIndex $DefaultInput;

    if ((Get-IcingaForWindowsManagementConsoleLastInput) -eq '1') {
        if ($null -eq $CmdArguments -Or $CmdArguments.Count -eq 0) {
            & $Command | Out-Null;
        } else {
            & $Command @CmdArguments | Out-Null;
        }
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('Action "{0}" has been executed', $Caption);
    }
}
