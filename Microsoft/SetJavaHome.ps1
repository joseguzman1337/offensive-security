$batFile = "C:\Program Files\ME_Secure_Gateway_Server\bin\UpdMgr.bat"
$javaHome = "C:\Program Files\Java\jdk-23"  # Update if your JDK 23 path is different

# Read the content of the bat file
$batContent = Get-Content $batFile

# Construct the line to add
$newLine = "SET JAVA_HOME=$javaHome"

# Check if the line already exists (case-insensitive)
if (!($batContent -match "(?i)^SET JAVA_HOME=")) {
  # Add the new line at the beginning of the file
  $batContent = "$newLine`n" + $batContent
  # Write the modified content back to the file
  Set-Content -Path $batFile -Value $batContent -Force
  Write-Host "JAVA_HOME set in $batFile"
} else {
  Write-Host "JAVA_HOME already set in $batFile"
}
