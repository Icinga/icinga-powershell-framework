function Test-IcingaPowerShellCommandInCode()
{
    param (
        [string]$Code    = '',
        [string]$Command = ''
    );

    if ([string]::IsNullOrEmpty($Code) -Or [string]::IsNullOrEmpty($Command)) {
        return $FALSE;
    }

    [string]$SearchCmdSpace   = [string]::Format('{0} ', $Command);
    [string]$SearchCmdColon   = [string]::Format('{0};', $Command);
    [string]$SearchCmdCBClose = [string]::Format('{0})', $Command);
    [string]$SearchCmdCBOpen  = [string]::Format('{0}(', $Command);
    [string]$SearchCmdSB      = [string]::Format('{0}]', $Command);
    [string]$SearchCmdBrace   = [string]::Format('{0}}}', $Command);
    [string]$SearchCmdSQ      = [string]::Format("{0}'", $Command);
    [string]$SearchCmdRN      = [string]::Format('{0}{1}', $Command, "`r`n");
    [string]$SearchCmdNL      = [string]::Format('{0}{1}', $Command, "`n");

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdSpace -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdColon -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdCBOpen -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdCBClose -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdSB -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdBrace -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdSQ -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdRN -SimpleMatch)) {
        return $TRUE;
    }

    if ($null -ne (Select-String -InputObject $ModuleContent -Pattern $SearchCmdNL -SimpleMatch)) {
        return $TRUE;
    }

    return $FALSE;
}
