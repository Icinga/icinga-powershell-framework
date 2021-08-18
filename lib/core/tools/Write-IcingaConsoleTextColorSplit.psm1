function Write-IcingaConsoleTextColorSplit()
{
    param (
        [string]$Pattern = '',
        [string]$Message = '',
        [ValidateSet('Default', 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor = 'Default'
    );

    if ($Message.Contains($Pattern)) {
        [int]$RemoveLength   = $Pattern.Length;
        [string]$SeverityMsg = $Pattern;
        Write-IcingaConsolePlain -Message ($Message.Substring(0, $Message.IndexOf($Pattern))) -NoNewLine;

        Write-IcingaConsolePlain -Message $SeverityMsg -ForeColor $ForeColor -NoNewLine;

        Write-IcingaConsolePlain -Message ($Message.Substring($Message.IndexOf($Pattern) + $RemoveLength, $Message.Length - $Message.IndexOf($Pattern) - $RemoveLength));

        return $TRUE;
    }

    return $FALSE;
}
