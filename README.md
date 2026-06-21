# SMB Connectivity Test Suite

PowerShell tools for SMB host, port and share-path testing plus guarded Windows SMB client repair.

## Test

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SMB_Connectivity_Test_Suite.ps1 -Servers FILESERVER01 -SharePaths '\\FILESERVER01\Public'
```

## Repair

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SMB_Connectivity_Repair_Toolkit.ps1 -Server FILESERVER01 -RestartWorkstationService -DryRun
```

Examples:

```powershell
.\SMB_Connectivity_Repair_Toolkit.ps1 -RestartWorkstationService
.\SMB_Connectivity_Repair_Toolkit.ps1 -FlushDns
.\SMB_Connectivity_Repair_Toolkit.ps1 -HardenSmbClient
.\SMB_Connectivity_Repair_Toolkit.ps1 -SharePath '\\FILESERVER01\Public' -ReconnectShare
```

The repair script captures Workstation service, SMB client, connection and target state before and after changes. `-HardenSmbClient` enables SMB2 and signing while disabling SMB1 client support. Active file sessions may be interrupted by service restart.

## Author

Dewald Pretorius — L2 IT Support Engineer
