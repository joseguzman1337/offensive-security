# NTLM Hardening Script for PowerShell 5.1
# Goals:
# - Disable LM and NTLMv1
# - Enforce NTLMv2 only
# - Print system info for compliance evidence

Write-Host "`n🔍 Collecting system information..."
$hostname = (Get-WmiObject Win32_ComputerSystem).DNSHostName + "." + (Get-WmiObject Win32_ComputerSystem).Domain
$user = whoami
$ipconfig = ipconfig

Write-Host "`n📌 Hostname (FQDN): $hostname"
Write-Host "📌 Current User: $user"
Write-Host "`n📌 IP Configuration:"
$ipconfig

Write-Host "`n🔍 Applying NTLM hardening settings..."

# Registry paths
$lsaPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$msvPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"

# Desired values
$lmLevel = 5
$restrictRecv = 2
$restrictSend = 2

# Apply settings
try {
    Set-ItemProperty -Path $lsaPath -Name "LmCompatibilityLevel" -Value $lmLevel
    Write-Host "✅ LmCompatibilityLevel set to $lmLevel (NTLMv2 only)."
} catch {
    Write-Error "❌ Failed to set LmCompatibilityLevel. Error: $_"
}

# Ensure MSV1_0 key exists
if (-not (Test-Path -Path $msvPath)) {
    New-Item -Path $lsaPath -Name "MSV1_0" -Force | Out-Null
    Write-Host "🛠️ Created missing registry key: $msvPath"
}

try {
    Set-ItemProperty -Path $msvPath -Name "RestrictReceivingNTLMTraffic" -Value $restrictRecv
    Write-Host "✅ RestrictReceivingNTLMTraffic set to $restrictRecv (deny inbound NTLM)."
} catch {
    Write-Error "❌ Failed to set RestrictReceivingNTLMTraffic. Error: $_"
}

try {
    Set-ItemProperty -Path $msvPath -Name "RestrictSendingNTLMTraffic" -Value $restrictSend
    Write-Host "✅ RestrictSendingNTLMTraffic set to $restrictSend (deny outbound NTLM)."
} catch {
    Write-Error "❌ Failed to set RestrictSendingNTLMTraffic. Error: $_"
}

# Verify settings
Write-Host "`n📋 Compliance Evidence:"
try {
    $lsaProps = Get-ItemProperty -Path $lsaPath | Select LmCompatibilityLevel
    $msvProps = Get-ItemProperty -Path $msvPath | Select RestrictReceivingNTLMTraffic, RestrictSendingNTLMTraffic

    Write-Host "`nNTLM Registry Settings:"
    $lsaProps | Format-Table -AutoSize
    $msvProps | Format-Table -AutoSize
} catch {
    Write-Warning "⚠️ Could not read registry values. Error: $_"
}

Write-Host "`n✅ NTLM hardening applied. Reboot recommended for full effect."
