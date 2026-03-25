#requires -RunAsAdministrator
<#
    SMB Hardening + Evidence
      - Disable SMBv1; enable SMBv2/SMBv3
      - Require SMB signing
      - Enable share encryption for AD-critical shares (if present) and non-admin custom shares
      - Minimal identity evidence (current user only)
      - ExecutionPolicy prerequisite (process-scoped bypass)
      - Detect DC role; optionally run dcdiag
      - Export evidence (JSON, CSV)
      - Transcript logging

    Notes:
      - Admin/hidden shares ($-suffixed) are excluded from encryption.
      - Registry/feature fallback used if SMB cmdlets aren’t available; reboot may be required.
#>

[CmdletBinding()]
param(
    [string] $ExportEvidenceJsonPath,              # e.g., C:\Temp\SMB_Evidence_<HOST>.json
    [string] $ExportSharesCsvPath,                 # e.g., C:\Temp\SMB_Shares_<HOST>.csv
    [switch] $SkipDcDiag                           # Skip dcdiag even if host is a DC
)

$ErrorActionPreference = 'Stop'

# ---------- Pre-Req: Set Execution Policy (Process scope) ----------
try {
    $epBefore = Get-ExecutionPolicy -List
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop
    $epAfter  = Get-ExecutionPolicy -List
} catch {
    Write-Warning "Could not set ExecutionPolicy (Process=Bypass). A policy may be enforced by GPO. Error: $($_.Exception.Message)"
}

# ---------- Prep & Evidence: Host Identity ----------
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$domain    = ([System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()).DomainName
$fqdn      = if ($domain) { "$($env:COMPUTERNAME).$domain" } else { $env:COMPUTERNAME }
$logPath   = Join-Path $env:TEMP "SMB_Hardening_$($env:COMPUTERNAME)_$timestamp.log"

Start-Transcript -Path $logPath -Force | Out-Null

Write-Host "============================================================="
Write-Host " SMB Hardening Script (Disable SMBv1, Enable SMBv2/v3, Signing, Encryption)"
Write-Host " Host (FQDN): $fqdn"
Write-Host " Date/Time   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ssK')"
Write-Host "=============================================================`n"

# Show ExecutionPolicy before/after (if captured)
if ($epBefore) {
    Write-Host "`n--- ExecutionPolicy (Before) ---"
    $epBefore | Format-Table Scope, ExecutionPolicy -AutoSize
}
Write-Host "`n--- ExecutionPolicy (After) ---"
(Get-ExecutionPolicy -List) | Format-Table Scope, ExecutionPolicy -AutoSize

# Confirm elevation (in addition to #requires)
try {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "This script must be run in an elevated PowerShell session (Run as Administrator)."
    }
} catch {
    Write-Error $_
    Stop-Transcript | Out-Null
    exit 1
}

# ---------- Minimal identity evidence (current user only) ----------
try {
    $currId   = [Security.Principal.WindowsIdentity]::GetCurrent()
    $currPrin = New-Object Security.Principal.WindowsPrincipal($currId)
    $sam      = $currId.Name                       # DOMAIN\User or COMPUTER\User
    $sid      = $currId.User.Value
    $isAdmin  = $currPrin.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $logonSrv = $env:LOGONSERVER
    Write-Host "`n--- Current User Context ---"
    Write-Host ("User (SAM): {0}" -f $sam)
    Write-Host ("SID       : {0}" -f $sid)
    Write-Host ("Elevated  : {0}" -f $isAdmin)
    if ($logonSrv) { Write-Host ("LogonSrv  : {0}" -f $logonSrv) }
} catch {
    Write-Warning "Unable to capture current user context: $($_.Exception.Message)"
}

# Network evidence (kept for audit)
Write-Host "`n--- ipconfig /all ---"
ipconfig /all

# ---------- Role awareness ----------
$domainRoleMap = @{
    0 = 'Standalone Workstation'
    1 = 'Member Workstation'
    2 = 'Standalone Server'
    3 = 'Member Server'
    4 = 'Backup Domain Controller'
    5 = 'Primary Domain Controller'
}
$domainRoleVal = (Get-CimInstance Win32_ComputerSystem).DomainRole
$domainRole    = $domainRoleMap[$domainRoleVal]
$hostIsDc      = $domainRoleVal -in 4,5

Write-Host "`n--- Host Role ---"
Write-Host ("DomainRole : {0} ({1})" -f $domainRoleVal, $domainRole)
Write-Host ("Is DC      : {0}" -f $hostIsDc)

# ---------- Target State ----------
# 1) Disable SMBv1 completely (protocol + features)
# 2) Ensure SMBv2/SMBv3 enabled
# 3) Enforce SMB signing (enable + require)
# 4) Enable encryption for SYSVOL, NETLOGON (if present), and all non-admin user shares

Write-Host "`n=== Applying SMB Configuration ==="

$usedFallback = $false

# Prefer native SMB server configuration cmdlets if available
if (Get-Command Set-SmbServerConfiguration -ErrorAction SilentlyContinue) {
    Write-Host "Configuring SMB server settings via Set-SmbServerConfiguration..."
    Set-SmbServerConfiguration -EnableSMB1Protocol $false `
                               -EnableSMB2Protocol $true `
                               -EnableSecuritySignature $true `
                               -RequireSecuritySignature $true `
                               -Force
} else {
    $usedFallback = $true
    Write-Warning "Set-SmbServerConfiguration not available; using registry fallback."

    # Ensure LanmanServer\Parameters exists
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Force | Out-Null

    # Disable SMBv1 via registry
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
                     -Name "SMB1" -Value 0 -PropertyType DWord -Force | Out-Null

    # Ensure SMBv2/3 enabled via registry
    New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
                     -Name "SMB2" -Value 1 -PropertyType DWord -Force | Out-Null

    Write-Warning "Registry changes applied; a reboot may be required for full effect."
}

# Attempt to remove/disable SMB1 feature components when present (no reboot here)
# Client OS (Optional Feature)
try {
    if (Get-Command Get-WindowsOptionalFeature -ErrorAction SilentlyContinue) {
        $opt = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction SilentlyContinue
        if ($opt -and $opt.State -ne 'Disabled') {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction SilentlyContinue | Out-Null
            Write-Host "SMB1 optional feature disabled (client)."
        } else {
            Write-Host "SMB1 optional feature already disabled (client)."
        }
    }
} catch { Write-Verbose "OptionalFeature handling: $_" }

# Server OS (Windows Server Feature)
try {
    if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
        $fsSmb1 = Get-WindowsFeature -Name FS-SMB1 -ErrorAction SilentlyContinue
        if ($fsSmb1 -and $fsSmb1.InstallState -ne 'Removed') {
            Uninstall-WindowsFeature -Name FS-SMB1 -Restart:$false | Out-Null
            Write-Host "SMB1 server feature uninstalled (server)."
        } else {
            Write-Host "SMB1 server feature already removed (server)."
        }
    }
} catch { Write-Verbose "WindowsFeature handling: $_" }

# ---------- Encryption on critical and user shares ----------
Write-Host "`n=== Enabling SMB Encryption on shares ==="

# Critical shares first (only if present)
$criticalShares = @('SYSVOL','NETLOGON')
foreach ($share in $criticalShares) {
    try {
        $s = Get-SmbShare -Name $share -ErrorAction SilentlyContinue
        if ($s) {
            if (-not $s.EncryptData) {
                Set-SmbShare -Name $share -EncryptData $true -Force
                Write-Host "✅ Encryption enabled for $share."
            } else {
                Write-Host "ℹ️  $share already has encryption enabled."
            }
        } else {
            Write-Host "↪  $share not present on this host (skipping)."
        }
    } catch {
        Write-Warning "Could not enable encryption for $share. Error: $($_.Exception.Message)"
    }
}

# Non-admin custom shares: exclude admin/hidden ($-suffixed) and critical shares
try {
    $shares = Get-SmbShare | Where-Object {
        $_.Name -notmatch '\$$' -and $_.Name -notin $criticalShares
    }

    foreach ($share in $shares) {
        if (-not $share.EncryptData) {
            try {
                Set-SmbShare -Name $share.Name -EncryptData $true -Force
                Write-Host "✅ Encryption enabled for $($share.Name)."
            } catch {
                Write-Warning "Could not enable encryption for $($share.Name). Error: $($_.Exception.Message)"
            }
        } else {
            Write-Host "ℹ️  Encryption already enabled for $($share.Name)."
        }
    }
} catch {
    Write-Warning "Share enumeration failed: $($_.Exception.Message)"
}

# ---------- Optional DC health check ----------
$dcDiagPath = $null
if ($hostIsDc -and -not $SkipDcDiag) {
    try {
        Write-Host "`n=== DC Health Check (dcdiag) ==="
        $dcDiagPath = Join-Path $env:TEMP "dcdiag_$($env:COMPUTERNAME)_$timestamp.txt"
        # Use /c (comprehensive) but keep output manageable
        dcdiag /c | Tee-Object -FilePath $dcDiagPath
        Write-Host "dcdiag output saved to: $dcDiagPath"
    } catch {
        Write-Warning "dcdiag execution failed or not available: $($_.Exception.Message)"
    }
} else {
    Write-Host "`nDC health check skipped (Is DC: $hostIsDc; SkipDcDiag: $SkipDcDiag)."
}

# ---------- Compliance Evidence ----------
Write-Host "`n=== Compliance Evidence ==="

$serverCfg = $null
if (Get-Command Get-SmbServerConfiguration -ErrorAction SilentlyContinue) {
    Write-Host "`nSMB Server Configuration:"
    $serverCfg = Get-SmbServerConfiguration |
        Select-Object EnableSMB1Protocol, EnableSMB2Protocol, EnableSecuritySignature, RequireSecuritySignature
    $serverCfg | Format-Table -AutoSize
} else {
    Write-Host "`nSMB Server Configuration (registry fallback in use):"
}

# Registry snapshot
$reg = $null
try {
    $reg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -ErrorAction SilentlyContinue
    if ($reg) {
        Write-Host ("Registry -> SMB1={0} ; SMB2={1}" -f $reg.SMB1, $reg.SMB2)
    }
} catch { Write-Verbose "Registry snapshot error: $_" }

# Feature states
$optFeat = $null
try {
    if (Get-Command Get-WindowsOptionalFeature -ErrorAction SilentlyContinue) {
        Write-Host "`nWindows Optional Feature (client):"
        $optFeat = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
        $optFeat | Select-Object FeatureName, State | Format-Table -AutoSize
    }
} catch { Write-Verbose "OptionalFeature snapshot error: $_" }

$srvFeat = $null
try {
    if (Get-Command Get-WindowsFeature -ErrorAction SilentlyContinue) {
        Write-Host "`nWindows Feature (server):"
        $srvFeat = Get-WindowsFeature -Name FS-SMB1
        $srvFeat | Select-Object Name, InstallState | Format-Table -AutoSize
    }
} catch { Write-Verbose "WindowsFeature snapshot error: $_" }

# Shares encryption status
$shareSnap = $null
try {
    Write-Host "`nSMB Shares Encryption Status:"
    $shareSnap = Get-SmbShare | Select-Object Name, Path, EncryptData
    $shareSnap | Sort-Object Name | Format-Table -AutoSize
} catch { Write-Verbose "Shares snapshot error: $_" }

# ---------- Evidence export (optional) ----------
try {
    if ($ExportEvidenceJsonPath) {
        $evidence = [ordered]@{
            HostFqdn            = $fqdn
            TimestampUtc        = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ssK')
            Identity            = [ordered]@{
                SamAccountName = $sam
                Sid            = $sid
                Elevated       = $isAdmin
                LogonServer    = $logonSrv
            }
            ExecutionPolicy     = @{
                Before = $epBefore
                After  = $epAfter
            }
            DomainRole          = [ordered]@{
                Value = $domainRoleVal
                Name  = $domainRole
                IsDc  = $hostIsDc
            }
            SmbServerConfig     = $serverCfg
            RegistryLanman      = if ($reg) { @{ SMB1 = $reg.SMB1; SMB2 = $reg.SMB2 } } else { $null }
            OptionalFeatureSMB1 = $optFeat
            ServerFeatureSMB1   = $srvFeat
            Shares              = $shareSnap
            DcDiagFile          = $dcDiagPath
            TranscriptFile      = $logPath
        }
        $json = $evidence | ConvertTo-Json -Depth 6
        Set-Content -Path $ExportEvidenceJsonPath -Value $json -Encoding UTF8
        Write-Host ("Evidence JSON saved to: {0}" -f $ExportEvidenceJsonPath)
    }
    if ($ExportSharesCsvPath -and $shareSnap) {
        $shareSnap | Export-Csv -Path $ExportSharesCsvPath -NoTypeInformation -Encoding UTF8
        Write-Host ("Shares CSV saved to: {0}" -f $ExportSharesCsvPath)
    }
} catch {
    Write-Warning "Evidence export failed: $($_.Exception.Message)"
}

if ($usedFallback) {
    Write-Host "`nNote: Registry/feature fallback used; a reboot may be required for all changes to fully apply."
}

Write-Host "`nTranscript saved to: $logPath"
Stop-Transcript | Out-Null
