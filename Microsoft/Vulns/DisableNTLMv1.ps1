# PowerShell 5.1-compatible script to disable NTLMv1 and verify the setting

$regPath = "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0"
$regName = "RestrictReceivingNTLMTraffic"
$desiredValue = 2

# Apply the setting
try {
    Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue
    Write-Host "✅ NTLMv1 inbound authentication disabled (RestrictReceivingNTLMTraffic = $desiredValue)."
} catch {
    Write-Error "❌ Failed to set $regName. Error: $_"
}

# Verify the setting
try {
    $regProps = Get-ItemProperty -Path $regPath
    $currentValue = $regProps.$regName

    if ($currentValue -eq $desiredValue) {
        Write-Host "✅ Verification successful: $regName is set to $currentValue."
    } else {
        Write-Warning "⚠️ Verification failed: $regName is set to $currentValue (expected $desiredValue)."
    }
} catch {
    Write-Warning "⚠️ Could not read $regName. It may not be set or accessible. Error: $_"
}
