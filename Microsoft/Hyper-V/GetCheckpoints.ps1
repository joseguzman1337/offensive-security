Get-VM | ForEach-Object {
    $VMName = $_.Name
    $Checkpoints = Get-VMCheckpoint -VMName $VMName
    if ($Checkpoints) {
        Write-Host "VM: $VMName"
        $Checkpoints | Format-Table Name, CreationTime
    }
}
