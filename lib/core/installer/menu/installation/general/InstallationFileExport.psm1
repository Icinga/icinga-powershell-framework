function Show-IcingaForWindowsManagementConsoleInstallationFileExport()
{
    $FilePath = $ENV:USERPROFILE;

    if ($null -ne $global:Icinga.InstallWizard.LastValues -And $global:Icinga.InstallWizard.LastValues.Count -ne 0) {
        $FilePath = $global:Icinga.InstallWizard.LastValues[0];
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Where do you want to export the answer file to? The filename "IfW_answer.json" is added automatically.' `
        -Entries @(
            @{
                'Caption' = '';
                'Command' = 'Export-IcingaForWindowsManagementConsoleInstallationAnswerFile';
                'Help'    = 'This will all you to export the answer file with the given configuration. You can install Icinga for Windows with this file by using the command "Install-Icinga -InstallFile <path to the file>".';
            }
        ) `
        -AddConfig `
        -DefaultValues @( $FilePath ) `
        -ConfigLimit 1 `
        -DefaultIndex 'c' `
        -MandatoryValue `
        -Hidden;
}
