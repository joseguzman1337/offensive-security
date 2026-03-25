Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3" | ForEach-Object {
    $freeSpaceGB = [Math]::Round($_.FreeSpace / 1GB, 2)
    Write-Host ("Drive {0} has {1} GB free" -f $_.DeviceID, $freeSpaceGB)
}
