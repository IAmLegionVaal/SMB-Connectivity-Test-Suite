[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [switch]$RestartWorkstationService,
 [switch]$FlushDns,
 [switch]$HardenSmbClient,
 [string]$Server,
 [string]$SharePath,
 [switch]$ReconnectShare,
 [switch]$DryRun,
 [switch]$Yes,
 [string]$OutputPath=(Join-Path $env:ProgramData 'SMBConnectivityRepair')
)
$ErrorActionPreference='Stop';$script:Failures=0;$script:Actions=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$before=Join-Path $run 'before.json';$after=Join-Path $run 'after.json'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
function Admin{$p=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent());$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function State{[pscustomobject]@{Collected=Get-Date;Workstation=Get-Service LanmanWorkstation|Select-Object Name,Status,StartType;Client=Get-SmbClientConfiguration|Select-Object EnableSMB1Protocol,EnableSMB2Protocol,EnableSecuritySignature,RequireSecuritySignature;Connections=Get-SmbConnection -ErrorAction SilentlyContinue|Select-Object ServerName,ShareName,Dialect,Signed,Encrypted;Target=if($Server){[pscustomobject]@{Server=$Server;Dns=[bool](Resolve-DnsName $Server -ErrorAction SilentlyContinue);Port445=Test-NetConnection $Server -Port 445 -InformationLevel Quiet -WarningAction SilentlyContinue}}}}
function Act($d,[scriptblock]$a){$script:Actions++;Log $d;if($DryRun){Log "DRY-RUN: $d";return};try{&$a;Log "SUCCESS: $d"}catch{$script:Failures++;Log "FAILED: $d - $($_.Exception.Message)"}}
State|ConvertTo-Json -Depth 6|Set-Content $before -Encoding UTF8
if(-not($RestartWorkstationService -or $FlushDns -or $HardenSmbClient -or $ReconnectShare)){Write-Error 'Choose at least one repair action.';exit 2}
if($ReconnectShare -and -not $SharePath){Write-Error '-SharePath is required.';exit 2}
if(($RestartWorkstationService -or $HardenSmbClient) -and -not $DryRun -and -not(Admin)){Write-Error 'Run from elevated PowerShell.';exit 4}
if(-not $Yes -and -not $DryRun){if((Read-Host 'Apply selected SMB client repairs? Active file sessions may be interrupted. Type YES') -ne 'YES'){Log 'Cancelled.';exit 10}}
if($RestartWorkstationService){Act 'Restarting Workstation service' {Restart-Service LanmanWorkstation -Force}}
if($FlushDns){Act 'Flushing DNS resolver cache' {Clear-DnsClientCache}}
if($HardenSmbClient){Act 'Enabling SMB2 and SMB signing while disabling SMB1 client support' {Set-SmbClientConfiguration -EnableSMB2Protocol $true -EnableSecuritySignature $true -EnableSMB1Protocol $false -Force}}
if($ReconnectShare){Act "Testing and reconnecting $SharePath" {if(-not(Test-Path $SharePath)){throw 'Share path is not accessible'};Get-ChildItem $SharePath -ErrorAction Stop|Select-Object -First 1|Out-Null}}
Start-Sleep 2;State|ConvertTo-Json -Depth 6|Set-Content $after -Encoding UTF8
if($script:Failures){exit 20};Log "Repair completed. Actions: $script:Actions";exit 0
