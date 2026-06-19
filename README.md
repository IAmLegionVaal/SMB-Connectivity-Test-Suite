# SMB Connectivity Test Suite

A read-only PowerShell toolkit for SMB host, port, and share-path connectivity testing.

## Features

- DNS resolution checks
- TCP port 445 reachability
- Optional UNC path accessibility checks
- CSV, JSON, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\SMB_Connectivity_Test_Suite.ps1 -Servers FILESERVER01
```

Optional share paths:

```powershell
.\SMB_Connectivity_Test_Suite.ps1 -Servers FILESERVER01 -SharePaths '\\FILESERVER01\Public'
```

## Safety

Read-only connectivity tests only. No SMB or share settings are changed.
