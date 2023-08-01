function Clear-CLIConsole()
{
    try {
        Clear-Host -ErrorAction Stop;
    } catch {
        # Nothing to do
    }
}
