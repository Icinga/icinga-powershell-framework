# App configuration
$App = @{
    LogSeverity = [PSCustomObject]@{
        PSTypeName = "LogSeverity"
        Info      = 0
        Warning   = 1
        Error     = 2
        Exception = 3
        Debug     = 4
    };
    RootPath   = $_InternalTempVariables.RootPath;
    ModuleName = $_InternalTempVariables.ModuleName;
}

return $App;