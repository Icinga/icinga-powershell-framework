function Get-IcingaExceptionString()
{
    param (
        $ExceptionObject = $null
    );

    if ($null -eq $ExceptionObject) {
        return '';
    }

    $ExceptionStack = New-Object -TypeName 'System.Text.StringBuilder';

    $ExceptionStack.AppendLine('') | Out-Null;
    $ExceptionStack.AppendLine('') | Out-Null;
    $ExceptionStack.AppendLine('Icinga for Windows exception report:') | Out-Null;

    if ([string]::IsNullOrEmpty($ExceptionObject.Exception.Message) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('Exception Message:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.Exception.Message) | Out-Null;
    }
    if ([string]::IsNullOrEmpty($ExceptionObject.InvocationInfo.InvocationName) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('Invocation Name:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.InvocationInfo.InvocationName) | Out-Null;
    }
    if ([string]::IsNullOrEmpty($ExceptionObject.InvocationInfo.CommandOrigin) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('Command Origin:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.InvocationInfo.CommandOrigin) | Out-Null;
    }
    if ([string]::IsNullOrEmpty($ExceptionObject.InvocationInfo.ScriptLineNumber) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('Script Line Number:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.InvocationInfo.ScriptLineNumber) | Out-Null;
    }
    if ([string]::IsNullOrEmpty($ExceptionObject.InvocationInfo.PositionMessage) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('Exact Position:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.InvocationInfo.PositionMessage) | Out-Null;
    }
    if ([string]::IsNullOrEmpty($ExceptionObject.Exception.StackTrace) -eq $FALSE) {
        $ExceptionStack.AppendLine('') | Out-Null;
        $ExceptionStack.AppendLine('StackTrace:') | Out-Null;
        $ExceptionStack.AppendLine($ExceptionObject.Exception.StackTrace) | Out-Null;
    }

    $CallStack = Get-PSCallStack;

    $ExceptionStack.AppendLine('') | Out-Null;
    $ExceptionStack.AppendLine('Call Stack:') | Out-Null;
    if ($CallStack.Count -gt 11) {
        $ExceptionStack.AppendLine(($CallStack[0..10] | Out-String)) | Out-Null;
    } else {
        $ExceptionStack.AppendLine(($CallStack | Out-String)) | Out-Null;
    }
    $ExceptionStack.Remove($ExceptionStack.Length - 8, 8) | Out-Null;

    return $ExceptionStack.ToString();
}
