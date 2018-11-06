# Inetrnal variable to store the root directory path
[string]$RootDirectory = '';

# In case we load the module for the first time, this variable contains the root path
# of our module
if ($_InternalTempVariables -ne $null) {
    $RootDirectory = $_InternalTempVariables.RootPath;
} else {
    # In case we want to reload the configuration, we simply can access the namespace
    # variable we already loaded
    $RootDirectory = $Icinga2.App.RootPath;
}

# Build the Config directory and file path
[string]$ConfigDirectory = (Join-Path $RootDirectory -ChildPath 'agent\config');
[string]$ConfigFile      = (Join-Path $ConfigDirectory -ChildPath 'config.conf');

# In case the config file does not exist, return an empty hashtable
if ((Test-Path ($ConfigFile)) -eq $FALSE) {
    return ('{ }' | ConvertFrom-Json);
}

# Return the content of the file as objects (config is stored as JSON)
return ([System.IO.File]::ReadAllText($ConfigFile) | ConvertFrom-Json);