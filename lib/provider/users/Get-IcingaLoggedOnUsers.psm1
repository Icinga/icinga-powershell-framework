function Get-IcingaLoggedOnUsers()
{
    param(
        [array]$UserFilter = @()
    );

    [hashtable]$UserList = @{};
    [int]$UserCount      = 0;
    $UserList.Add('users', @{ });

    $Users = Get-CIMInstance Win32_LoggedOnUser | Select-Object Antecedent, Dependent;

    foreach ($user in $Users) {
        [string]$username = $user.Antecedent.Name;

        if ($UserFilter.Count -ne 0) {
            if (-Not $UserFilter.Contains($username)) {
                continue;
            }
        }

        $UserCount += 1;

        if ($UserList.users.ContainsKey($username) -eq $FALSE) {
            $UserList.users.Add(
                $username,
                @{
                    'domains' = @($user.Antecedent.Domain);
                    'logonid' = @($user.Dependent.LogonId);
                    'count'   = 1;
                }
            );
        } else {
            $UserList.users[$username].domains += $user.Antecedent.Domain;
            $UserList.users[$username].logonid += $user.Dependent.LogonId;
            $UserList.users[$username].count   += 1;
        }
    }

    $UserList.Add('count', $UserCount);

    return $UserList;
}
