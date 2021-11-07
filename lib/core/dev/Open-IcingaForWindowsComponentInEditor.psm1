<#
.SYNOPSIS
    Opens any Icinga for Windows component in the defined editor
.DESCRIPTION
    Opens any Icinga for Windows component in the defined editor
.PARAMETER Name
    The name of the Icinga for Windows component
.PARAMETER Editor
    Defines which editor should be used
.EXAMPLE
    Open-IcingaForWindowsComponentInEditor -Name 'framework' -Editor 'code';
#>
function Open-IcingaForWindowsComponentInEditor()
{
    param (
        [string]$Name,
        [ValidateSet('code')]
        [string]$Editor = 'code'
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'Please specify the name of the component you want to open';
        return;
    }

    [string]$ModuleName     = [string]::Format('icinga-powershell-{0}', $Name.ToLower());
    [string]$ModuleRoot     = Get-IcingaForWindowsRootPath;
    [string]$ModuleDir      = Join-Path -Path $ModuleRoot -ChildPath $ModuleName;
    [string]$ModuleManifest = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)))

    if ((Test-Path $ModuleDir) -eq $FALSE) {
        Write-IcingaConsoleError 'A component with the name "{0}" does not exist. Use "New-IcingaForWindowsComponent" to create a new one or verify that the provided name is correct.' -Objects $Name;
        return;
    }

    [bool]$EditorInstalled = $FALSE;
    [string]$EditorName    = 'Unspecified';

    switch ($Editor) {
        'code' {
            if ($null -ne (Get-Command 'code.cmd' -ErrorAction SilentlyContinue)) {
                $EditorInstalled = $TRUE;
            }
            $EditorName = 'Visual Studio Code';
            break;
        };
        # TODO: Add more editors
    }

    if ($EditorInstalled -eq $FALSE) {
        Write-IcingaConsoleError 'Unable to open module "{0}" with {1}. Either the binary was not found or {1} is not installed' -Objects $ModuleName, $EditorName;
        return;
    }

    switch ($Editor) {
        'code' {
            & code --new-window "$ModuleDir";

            break;
        }
        # TODO: Add more editors
    }
}
