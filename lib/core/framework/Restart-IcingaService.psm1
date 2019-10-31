function Restart-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Restart-Service $Service;
    }
}
