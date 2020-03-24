function ConvertTo-IcingaX509Certificate()
{
    param(
        [string]$CertFile          = $null,
        [string]$OutFile           = $null,
        [switch]$Force             = $FALSE
    );

    # Use an empty password for converted certificates
    $Password       = $null;
    # Use a target file to specify if we use temp files or not
    $TargetFile     = $null;
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
        $Password" | certutil -mergepfx "$CertFile" "$TargetFile" | Out-Null;
    }

    # If no target file exists afterwards (a valid PFX certificate)
    # then throw an exception
    if (-Not (Test-Path $TargetFile)) {
        throw 'The specified/created certificate file could not be found.';
    }

    # Now load the actual certificate from the path
    $Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $TargetFile;
    # Delete the PFX-Certificate which will be present after certutil merge
    Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue;

    # Return the certificate
    return $Certificate
}
