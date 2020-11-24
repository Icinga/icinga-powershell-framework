function Send-IcingaTCPClientMessage()
{
    param(
        [Hashtable]$Message                     = @{},
        [System.Net.Security.SslStream]$Stream = $null
    );

    if ($null -eq $Message -Or $Message.Count -eq 0 -Or $Message.length -eq 0) {
        return;
    }

    $Stream.Write($Message.message, 0, $Message.length);
    $Stream.Flush();
}
