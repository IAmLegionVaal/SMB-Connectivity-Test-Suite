#requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string[]]$Servers,[string[]]$SharePaths,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'SMB_Connectivity_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$rows=@()
foreach($server in $Servers){$dnsOk=$false;$addresses=$null;try{$a=Resolve-DnsName $server -Type A -ErrorAction Stop;$addresses=($a.IPAddress -join ', ');$dnsOk=$true}catch{};$port=Test-NetConnection -ComputerName $server -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue;$rows+=[PSCustomObject]@{Target=$server;Test='Host';DnsSuccess=$dnsOk;Addresses=$addresses;Port445Reachable=$port;PathAccessible=$null}}
foreach($path in $SharePaths){$rows+=[PSCustomObject]@{Target=$path;Test='SharePath';DnsSuccess=$null;Addresses=$null;Port445Reachable=$null;PathAccessible=(Test-Path $path)}}
$rows|Export-Csv (Join-Path $OutputPath "smb_connectivity_$stamp.csv") -NoTypeInformation -Encoding UTF8
$rows|ConvertTo-Json -Depth 5|Set-Content (Join-Path $OutputPath "smb_connectivity_$stamp.json") -Encoding UTF8
$html="<h1>SMB Connectivity Test Suite</h1><p>Generated $(Get-Date)</p>$($rows|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'SMB Connectivity Test Suite'|Set-Content (Join-Path $OutputPath "smb_connectivity_$stamp.html") -Encoding UTF8
$rows|Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
