# SMB Hardening Script for Windows PowerShell 5.1
# Goals:
# 1. Confirm SMBv1 is disabled
# 2. Keep SMBv2/SMBv3 enabled (required for AD)
# 3. Enforce SMB signing globally
# 4. Enable encryption for SYSVOL, NETLOGON, and custom shares
# 5. Output compliance evidence

Write-Host "`n🔍 Checking SMB configuration..."

# Check SMBv1 status
$smb1Reg = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -ErrorAction SilentlyContinue
$smb1Status = if ($smb1Reg.SMB1 -eq 0) { "Disabled" } else { "Enabled or NotConfigured" }
Write-Host "✅ SMBv1 Status: $smb1Status"

# Ensure SMBv2/SMBv3 enabled
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB2" -Value 1
Write-Host "✅ SMBv2/SMBv3 re-enabled (SMB2 = 1). Reboot may be required."

# Enforce SMB signing
Set-SmbServerConfiguration -EnableSecuritySignature $true -RequireSecuritySignature $true -Force
Write-Host "✅ SMB signing enforced globally."

# Enable encryption for SYSVOL and NETLOGON
$criticalShares = @("SYSVOL", "NETLOGON")
foreach ($share in $criticalShares) {
    try {
        Set-SmbShare -Name $share -EncryptData $true -Force
        Write-Host "✅ Encryption enabled for $share."
    } catch {
        Write-Warning "⚠️ Could not enable encryption for $share. Error: $_"
    }
}

# Enable encryption for custom shares (skip admin shares)
$shares = Get-SmbShare | Where-Object { $_.Name -notin @("ADMIN$", "C$", "IPC$") }
foreach ($share in $shares) {
    try {
        Set-SmbShare -Name $share.Name -EncryptData $true -Force
        Write-Host "✅ Encryption enabled for $($share.Name)."
    } catch {
        Write-Warning "⚠️ Could not enable encryption for $($share.Name). Error: $_"
    }
}

# Output compliance evidence
Write-Host "`n📋 Compliance Evidence:"
$smbConfig = Get-SmbServerConfiguration | Select EnableSecuritySignature, RequireSecuritySignature
$smbShares = Get-SmbShare | Select Name, EncryptData
Write-Host "`nSMB Server Config:"
$smbConfig | Format-Table -AutoSize
Write-Host "`nSMB Shares Encryption Status:"
$smbShares | Format-Table -AutoSize
Get-Date -Format "dddd, dd MMMM yyyy HH:mm:ss"
