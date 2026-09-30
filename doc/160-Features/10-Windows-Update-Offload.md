# Windows Update Offload

The Windows Update Offload feature allows Icinga for Windows to retrieve pending Windows updates using a dedicated background scheduled task running under the `NT AUTHORITY\SYSTEM` account, securely caching the results for the monitoring check plugin.

**Note:** Before using any of the commands below, you must initialize the Icinga PowerShell Framework inside an administrative PowerShell instance with `icinga -Shell`.

---

## Overview and Motivation

By default, security best practices dictate that the Icinga Agent should be run with the least necessary privileges—such as `NT AUTHORITY\NetworkService` or a dedicated service account—rather than `NT AUTHORITY\SYSTEM`.

However, the Windows Update API (`Microsoft.Update.Session` COM object) cannot be queried over remote connections or by unprivileged service accounts without administrative or SYSTEM permissions. Calling update checks in such environments leads to permission errors.

### Related Knowledge Base Articles

* **[IWKB000006](../knowledgebase/IWKB000006.md):** The user you are running this command as does not have permission to access the Windows Update ComObject "Microsoft.Update.Session".

### When to Use Windows Update Offload

* **Preferred Alternative to Running Everything as SYSTEM:** Rather than elevating the entire Icinga Agent service to `SYSTEM` (which introduces broader security risks), only the update-fetching routine is offloaded to a background task running as `SYSTEM`.
* **Alternative when JEA is not possible:** While [Just Enough Administration (JEA)](../130-JEA/01-Introduction.md) is supported by Icinga for Windows to grant elevated privileges, JEA cannot be implemented or deployed in every environment. If JEA is not viable and you want to monitor Windows Updates without running the Icinga Agent as `SYSTEM`, **Windows Update Offload is the preferred and recommended solution**.

---

## How It Works

1. **Background Scheduled Task:**
   When enabled, a Windows Scheduled Task named `Fetch Windows Updates` is created under `\Icinga\Icinga for Windows\`. This task is configured to start automatically at system startup and runs as `NT AUTHORITY\SYSTEM` (`S-1-5-18`).

2. **Periodic Update Fetching:**
   The task runs `jobs\FetchWindowsUpdates.ps1` in an endless loop. Every **10 minutes (600 seconds)**, it queries the `Microsoft.Update.Session` COM object for pending updates that are not yet installed (`IsInstalled=0`).

3. **Atomic and Secure Cache Storage:**
   The serialized update objects are first written to a temporary file (`pending.xml.tmp`) and then atomically moved to `pending.xml` inside the cache directory (`cache\provider\windows_updates\pending.xml`). Directory and file permissions are strictly secured with `Set-IcingaUserPermissions` so that only `SYSTEM` and the Icinga for Windows service account have access.

4. **Transparent Check Integration:**
   When `Invoke-IcingaCheckUpdates` is executed:
   * **Offload Enabled:** The plugin reads the update list directly from the cached XML file, eliminating the need for elevated permissions at check execution time.
   * **Offload Disabled:** The plugin queries the Windows Update COM object directly and live.

---

## Cache Age Monitoring & Thresholds

To ensure you are never monitoring stale or outdated information if the background task fails or hangs, the plugin checks the last write timestamp of the cache file:

| Cache Age | Check State | Meaning |
| --- | --- | --- |
| `< 20 minutes` | **OK** | Background task is updating the cache normally. |
| `> 20 minutes (1200s)` | **WARNING** | Data is stale. The background task may have been delayed or failed its last run. |
| `> 30 minutes (1800s)` | **CRITICAL** | Data is severely outdated. The background task is likely hung, terminated, disabled, or encountering persistent errors. |

The check output displays:
* **`Last Update Check`:** Time offset in seconds since the cache file was last written.
* **`Last Fetch Timestamp`:** The exact UTC timestamp when the cache was written (e.g. `2026-09-21 11:30:00 UTC`).

---

## Enabling Windows Update Offload

To enable the feature, open an administrative PowerShell prompt and run:

```powershell
Enable-IcingaWindowsUpdateOffload;
```

```text
[Notice]: The task "Fetch Windows Updates" has been successfully registered at location "\Icinga\Icinga for Windows\".
```

This will:
* Set `Framework.WindowsUpdateOffload` to `$TRUE` in your framework configuration.
* Register the scheduled task `Fetch Windows Updates` under `\Icinga\Icinga for Windows\`.
* Automatically trigger the initial run of the task so that the cache file is created immediately.

### Silent Mode

If you are automating the setup, you can suppress console output by passing the `-Silent` switch:

```powershell
Enable-IcingaWindowsUpdateOffload -Silent;
```

---

## Checking Offload Status

You can verify whether the feature is currently active with `Get-IcingaWindowsUpdateOffload`:

```powershell
Get-IcingaWindowsUpdateOffload;
```

```text
True
```

You can also check the state of the scheduled task using the standard PowerShell cmdlet:

```powershell
Get-ScheduledTask -TaskName 'Fetch Windows Updates' -TaskPath '\Icinga\Icinga for Windows\';
```

```text
TaskPath                          TaskName                          State
--------                          --------                          -----
\Icinga\Icinga for Windows\       Fetch Windows Updates             Running
```

---

## Disabling Windows Update Offload

To disable the offload feature, open an administrative PowerShell prompt and run:

```powershell
Disable-IcingaWindowsUpdateOffload;
```

```text
[Notice]: The "Fetch Windows Updates" task was removed from the system.
```

This will:
* Set `Framework.WindowsUpdateOffload` to `$FALSE`.
* Stop and unregister the `Fetch Windows Updates` scheduled task.
* Remove the `pending.xml` cache file to prevent stale data from being kept on disk.
* Revert `Invoke-IcingaCheckUpdates` to querying updates directly.

---

## Check Plugin Example Output

When `Invoke-IcingaCheckUpdates` runs with Windows Update Offload enabled:

```powershell
Invoke-IcingaCheckUpdates;
```

```text
[OK] Windows Updates: 8 Ok (All must be [OK])
\_ [INFO] Last Fetch Timestamp: 2026-09-21 11:54:18 UTC
\_ [OK] Last Update Check: 1m
\_ [INFO] Microsoft Defender (All must be [OK])
   \_ [INFO] Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.459.318.0) - Current Channel (Broad) [9/21/2026 12:00:00 AM]: Nothing
   \_ [INFO] Update Count: 1c
\_ [INFO] Other (All must be [OK])
   \_ [INFO] Update Count: 0c
\_ [INFO] Reboot Pending: No
\_ [INFO] Security Updates (All must be [OK])
   \_ [INFO] 2026-09 Security Update (KB5129195) (26200.9457) [9/14/2026 12:00:00 AM]: Nothing
   \_ [INFO] Update Count: 1c
\_ [INFO] Total Pending Updates: 2c
\_ [INFO] Update Rollups (All must be [OK])
   \_ [INFO] Update Count: 0c
```

If the background task stops running and the cache exceeds the threshold:

```text
[WARNING] Windows Updates: 1 Warning 7 Ok [WARNING] Last Update Check (All must be [OK])
\_ [INFO] Last Fetch Timestamp: 2026-09-21 11:59:18 UTC
\_ [WARNING] Last Update Check: Value 26.37m is greater than threshold 20m
\_ [INFO] Microsoft Defender (All must be [OK])
   \_ [INFO] Security Intelligence Update for Microsoft Defender Antivirus - KB2267602 (Version 1.459.318.0) - Current Channel (Broad) [9/21/2026 12:00:00 AM]: Nothing
   \_ [INFO] Update Count: 1c
\_ [INFO] Other (All must be [OK])
   \_ [INFO] Update Count: 0c
\_ [INFO] Reboot Pending: Yes
\_ [INFO] Security Updates (All must be [OK])
   \_ [INFO] 2026-09 Security Update (KB5129195) (26200.9457) [9/14/2026 12:00:00 AM]: Nothing
   \_ [INFO] Update Count: 1c
\_ [INFO] Total Pending Updates: 2c
\_ [INFO] Update Rollups (All must be [OK])
   \_ [INFO] Update Count: 0c
```

This immediately signals that the background process requires attention.
