param($Config = $null);

return $Icinga2.Utils.Modules.LoadIncludes(
    $MyInvocation.MyCommand.Name,
    $Config
);