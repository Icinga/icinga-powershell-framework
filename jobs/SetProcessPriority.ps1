# Load the basic framework data
Use-Icinga -Minimal;

# Wait 10 seconds before procedding
Start-Sleep -Seconds 10;

# Fetch the process information for JEA and the Icinga for Windows PID
$JeaProcess = Get-Process -Id (Get-IcingaJEAServicePid) -ErrorAction SilentlyContinue;
$IfWProcess = Get-Process -Id (Get-IcingaForWindowsServicePid) -ErrorAction SilentlyContinue;

# Set the JEA pid to below normal
if ($null -ne $JeaProcess -And $JeaProcess.ProcessName -eq 'wsmprovhost') {
    $JeaProcess.PriorityClass = 'BelowNormal';
}

# Set the Icinga for Windows pid to below normal
if ($null -ne $IfWProcess -And $IfWProcess.ProcessName -eq 'powershell') {
    $IfWProcess.PriorityClass = 'BelowNormal';
}

# Exit with okay
exit 0;
