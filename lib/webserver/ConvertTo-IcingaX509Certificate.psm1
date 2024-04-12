function ConvertTo-IcingaX509Certificate()
{
    param(
        [string]$CertFile          = $null,
        [string]$OutFile           = $null,
        [switch]$Force             = $FALSE
    );

    if ([string]::IsNullOrEmpty($CertFile)) {
        throw 'Please specify a valid path to an existing certificate (.cer, .pem, .cert)';
    }

    if ((Test-Path $CertFile) -eq $FALSE) {
        throw 'The provided path to your certificate was not valid';
    }

    # Use an empty password for converted certificates
    $Password       = $null;
    # Use a target file to specify if we use temp files or not
    $TargetFile     = $OutFile;
    # Temp Cert
    [bool]$TempFile = $FALSE;

    # Create a temp file to store the certificate in
    if ([string]::IsNullOrEmpty($OutFile)) {
        # Create a temporary file for full path and name
        $TargetFile = New-IcingaTemporaryFile;
        # Get the actual path to work with
        $TargetFile = $TargetFile.FullName;
        # Set internally that we are using a temp file
        $TempFile   = $TRUE;
        # Delete the file again
        Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue;
    }

    # Convert our certificate if our target file does not exist
    # it is a temp file or we force its creation
    if (-Not (Test-Path $TargetFile) -Or $TempFile -Or $Force) {
        Write-Output "$Password
        $Password" | & 'C:\Windows\system32\certutil.exe' -mergepfx "$CertFile" "$TargetFile" | Set-Variable -Name 'CertUtilOutput';
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Certutil merge request has been completed. Certutil message:{0}{0}{1}',
            (New-IcingaNewLine),
            ($CertUtilOutput | Out-String)
        )
    );

    # If no target file exists afterwards (a valid PFX certificate)
    # then throw an exception
    if (-Not (Test-Path $TargetFile)) {
        [string]$ErrMessage = [string]::Format('Unable to create the Icinga for Windows certificate file "icingaforwindows.pfx". Certutil output:{0}{1}', (New-IcingaNewLine), ($CertUtilOutput | Out-String));
        Write-IcingaConsoleError $ErrMessage;
        throw $ErrMessage;
    }

    # Now load the actual certificate from the path
    $Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $TargetFile;
    # Delete the PFX-Certificate which will be present after certutil merge
    if ($TempFile) {
        Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue;
    }

    # Return the certificate
    return $Certificate
}
