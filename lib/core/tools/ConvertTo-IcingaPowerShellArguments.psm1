<#
.SYNOPSIS
    Fixes the current encoding hell for arguments by taking every argument
    parsed from Icinga and converting it from PowerShell native encoding
    to UTF8
.DESCRIPTION
    Fixes the current encoding hell for arguments by taking every argument
    parsed from Icinga and converting it from PowerShell native encoding
    to UTF8
.PARAMETER Arguments
    The array of arguments for re-encoding. By default, this could be $args
    for calls from Exit-IcingaExecutePlugin
.EXAMPLE
    PS> [hashtable]$ConvertedArgs = ConvertTo-IcingaPowerShellArguments -Command $CheckCommand -Arguments $args;
#>

function ConvertTo-IcingaPowerShellArguments()
{
    param (
        [string]$Command  = '',
        [array]$Arguments = @()
    );

    if ([string]::IsNullOrEmpty($Command)) {
        return @{ };
    }

    $CommandHelp = Get-Help -Name $Command -Full;

    [hashtable]$IcingaArguments = @{ };
    [int]$ArgumentIndex         = 0;

    while ($ArgumentIndex -lt $Arguments.Count) {
        # Check if the current position is a string
        if ($Arguments[$ArgumentIndex] -IsNot [string]) {
            # Continue if we are not a string (argument)
            $ArgumentIndex += 1;
            continue;
        }

        # check_by_icingaforwindows arguments -> not required for any plugin execution
        if ($Arguments[$ArgumentIndex] -eq '-IcingaForWindowsRemoteExecution' -Or $Arguments[$ArgumentIndex] -eq '-IcingaForWindowsJEARemoteExecution') {
            $ArgumentIndex += 1;
            continue;
        }

        # Check if our string value is a argument contained inside the command being executed
        if ($CommandHelp.parameters.parameter.name -Contains ($Arguments[$ArgumentIndex].SubString(1, $Arguments[$ArgumentIndex].Length - 1)) -eq $FALSE) {
             # Continue if we are not an argument
             $ArgumentIndex += 1;
             continue;
        }

        # First convert our argument
        [string]$Argument = ConvertTo-IcingaUTF8Value -InputObject $Arguments[$ArgumentIndex];
        # Cut the first '-'
        $Argument         = $Argument.Substring(1, $Argument.Length - 1);

        # Check if there is anything beyond this argument, if not
        # -> We are a switch argument, adding TRUE;
        if (($ArgumentIndex + 1) -ge $Arguments.Count) {
            if ($IcingaArguments.ContainsKey($Argument) -eq $FALSE) {
                $IcingaArguments.Add($Argument, $TRUE);
            }
            $ArgumentIndex += 1;
            continue;
        }

        # Check if our next value in the array is a string
        if ($Arguments[$ArgumentIndex + 1] -Is [string]) {
            [string]$NextValue = $Arguments[$ArgumentIndex + 1];

            # If our next value on the index is an argument in our command
            # -> The current argument seems to be a switch argument
            if ($CommandHelp.parameters.parameter.name -Contains ($NextValue.SubString(1, $NextValue.Length - 1))) {
                if ($IcingaArguments.ContainsKey($Argument) -eq $FALSE) {
                    $IcingaArguments.Add($Argument, $TRUE);
                }
                $ArgumentIndex += 1;
                continue;
            }

            # It could be that we parse strings without quotation which is broken because on how
            # Icinga is actually writing the arguments, let's fix this by building the string ourselves
            [int]$ReadStringIndex = $ArgumentIndex;
            $StringValue          = New-Object -TypeName 'System.Text.StringBuilder';
            while ($TRUE) {
                # Check if we read beyond our array
                if (($ReadStringIndex + 1) -ge $Arguments.Count) {
                    break;
                }

                # Check if the next element is no longer a string element
                if ($Arguments[$ReadStringIndex + 1] -IsNot [string]) {
                    break;
                }

                [string]$NextValue = $Arguments[$ReadStringIndex + 1];

                # Check the next string element and evaluate if it is an argument for our command
                if ($CommandHelp.parameters.parameter.name -Contains ($NextValue.SubString(1, $NextValue.Length - 1))) {
                    break;
                }

                # If we already added elements to our string builder before, add a whitespace
                if ($StringValue.Length -ne 0) {
                    $StringValue.Append(' ') | Out-Null;
                }

                # Append our string value to the string builder
                $StringValue.Append($NextValue) | Out-Null;
                $ReadStringIndex += 1;
            }

            # Add our argument with the string builder value, in case we had something to add there
            if ($StringValue.Length -ne 0) {
                if ($IcingaArguments.ContainsKey($Argument) -eq $FALSE) {
                    $IcingaArguments.Add($Argument, (ConvertTo-IcingaUTF8Value -InputObject $StringValue.ToString()));
                }
                $ArgumentIndex += 1;
                continue;
            }
        }

        # All Remaining values

        # If we are an array object, handle empty arrays
        if ($Arguments[$ArgumentIndex + 1] -Is [array]) {
            if ($null -eq $Arguments[$ArgumentIndex + 1] -Or ($Arguments[$ArgumentIndex + 1]).Count -eq 0) {
                if ($IcingaArguments.ContainsKey($Argument) -eq $FALSE) {
                    $IcingaArguments.Add($Argument, @());
                }
                $ArgumentIndex += 1;
                continue;
            }
        }

        if ($IcingaArguments.ContainsKey($Argument) -eq $FALSE) {
            # Add everything else
            $IcingaArguments.Add(
                $Argument,
                (ConvertTo-IcingaUTF8Value -InputObject $Arguments[$ArgumentIndex + 1])
            );
        }

        $ArgumentIndex += 1;
    }

    return $IcingaArguments;
}
