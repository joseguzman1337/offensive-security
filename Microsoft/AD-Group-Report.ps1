Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
    Write-Error "The Active Directory module is not installed. Please install it and try again."
    return
}
$GroupName = "abc-group"
$OutputCSVPath = "C:\ADGroupMembers_withDomains.csv"
$DomainsToCheck = @(
    "abc.com"
    "dbe.abc.com"
    "fgh.abc.com"
    "ijk.com"
)
try {
    Write-Host "Retrieving members of group '$GroupName' from Active Directory..."
    $GroupMembers = Get-ADGroupMember -Identity $GroupName
    if ($GroupMembers) {
        Write-Host "Successfully retrieved group members."
        $ExportData = @()
        foreach ($Member in $GroupMembers) {
            $UPN = ""
            $Email = ""
            if ($Member.objectClass -eq "user") {
                $User = Get-ADUser -Identity $Member.DistinguishedName -Properties UserPrincipalName, mail
                $UPN = $User.UserPrincipalName
                $Email = $User.mail
            }
            $DomainMatch = "No"
            foreach ($Domain in $DomainsToCheck) {
                if (($UPN -like "*@$Domain") -or ($Email -like "*@$Domain")) {
                    $DomainMatch = "Yes"
                    break
                }
            }
            $ObjectToExport = [PSCustomObject]@{
                Name              = $Member.Name
                SamAccountName    = $Member.SamAccountName
                ObjectClass       = $Member.objectClass
                DistinguishedName = $Member.DistinguishedName
                UserPrincipalName = $UPN
                EmailAddress      = $Email
                DomainMatch       = $DomainMatch
            }
            $ExportData += $ObjectToExport
        }
        $ExportData | Export-Csv -Path $OutputCSVPath -NoTypeInformation
        Write-Host "Group members exported to CSV file with domain information: '$OutputCSVPath'"
    }
    else {
        Write-Warning "No members found in group '$GroupName' or group does not exist."
    }
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    Write-Error "Please ensure the Active Directory module is installed and you have permissions to query Active Directory."
}
Write-Host "Script execution completed."
