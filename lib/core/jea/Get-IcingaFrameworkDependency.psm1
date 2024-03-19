function Get-IcingaFrameworkDependency()
{
    param (
        [string]$Command = $null,
        $DependencyList  = (New-Object PSCustomObject)
    );

    if (Test-PSCustomObjectMember -PSObject $DependencyList -Name $Command) {
        return $DependencyList;
    }

    $DependencyList | Add-Member -MemberType NoteProperty -Name ($Command) -Value (New-Object PSCustomObject);

    $CommandConfig    = (Get-Command $Command);
    $ModuleContent    = $CommandConfig.ScriptBlock.ToString();
    $DeserializedFile = Read-IcingaPowerShellModuleFile -FileContent $ModuleContent;
    [array]$CheckCmd  = $DeserializedFile.CommandList + $DeserializedFile.FunctionList;

    if (Deny-IcingaJEACommand -Command $Command -FileComment $DeserializedFile.Comment) {
        return $DependencyList;
    }

    foreach ($cmd in $CheckCmd) {
        if ($cmd -eq $Command) {
            continue;
        }

        $CommandConfig = Get-Command $cmd -ErrorAction SilentlyContinue;

        if ($null -eq $CommandConfig) {
            continue;
        }

        [string]$CommandType = ([string]$CommandConfig.CommandType).Replace(' ', '');

        if ((Test-PSCustomObjectMember -PSObject ($DependencyList.$Command) -Name $CommandType) -eq $FALSE) {
            $DependencyList.$Command | Add-Member -MemberType NoteProperty -Name ($CommandType) -Value (New-Object PSCustomObject);
        }

        if ((Test-PSCustomObjectMember -PSObject ($DependencyList.$Command.$CommandType) -Name $cmd) -eq $FALSE) {
            $DependencyList.$Command.$CommandType | Add-Member -MemberType NoteProperty -Name ($cmd) -Value 0;
        }

        $DependencyList.$Command.$CommandType.($cmd) += 1;
    }

    return $DependencyList;
}
