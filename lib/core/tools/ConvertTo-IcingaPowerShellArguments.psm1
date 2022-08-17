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
    PS> [hashtable]$ConvertedArgs = ConvertTo-IcingaPowerShellArguments -Arguments $args;
#>

function ConvertTo-IcingaPowerShellArguments()
{
    param (
        [array]$Arguments = @()
    );

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

        # Check if it starts with '-', which should indicate it being an argument
        if ($Arguments[$ArgumentIndex][0] -ne '-') {
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
            $IcingaArguments.Add($Argument, $TRUE);
            $ArgumentIndex += 1;
            continue;
        }

        # Check if our next value in the array is a string
        if ($Arguments[$ArgumentIndex + 1] -Is [string]) {
            [string]$NextValue = $Arguments[$ArgumentIndex + 1];

            # If our next value on the index starts with '-', we found another argument
            # -> The current argument seems to be a switch argument
            if ($NextValue[0] -eq '-') {
                $IcingaArguments.Add($Argument, $TRUE);
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

                # In case the next string element starts with '-', this could be an argument
                if ($NextValue[0] -eq '-') {
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
                $IcingaArguments.Add($Argument, (ConvertTo-IcingaUTF8Value -InputObject $StringValue.ToString()));
                $ArgumentIndex += 1;
                continue;
            }
        }

        # All Remaining values

        # If we are an array object, handle empty arrays
        if ($Arguments[$ArgumentIndex + 1] -Is [array]) {
            if ($null -eq $Arguments[$ArgumentIndex + 1] -Or ($Arguments[$ArgumentIndex + 1]).Count -eq 0) {
                $IcingaArguments.Add($Argument, @());
                $ArgumentIndex += 1;
                continue;
            }
        }

        # Add everything else
        $IcingaArguments.Add(
            $Argument,
            (ConvertTo-IcingaUTF8Value -InputObject $Arguments[$ArgumentIndex + 1])
        );

        $ArgumentIndex += 1;
    }

    return $IcingaArguments;
}
