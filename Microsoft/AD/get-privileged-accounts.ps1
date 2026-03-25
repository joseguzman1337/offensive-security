# # Check if the Active Directory module is already loaded
# if (!(Get-Module -ListAvailable -Name ActiveDirectory)) {
#     Write-Host "Active Directory module not found. Attempting to install..."

#     # Check OS version to determine installation method
#     $osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
#     if ($osVersion -match "Windows 10|Windows 11") {
#         Write-Host "Installing RSAT for Windows 10/11..."

#         # Attempt to install RSAT using DISM
#         try {
#             DISM /Online /Add-Capability /CapabilityName:"Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
#         }
#         catch {
#             Write-Host "Error installing RSAT: $($_.Exception.Message)"
#             Write-Host "Please install RSAT manually through Settings > Apps > Optional Features."
#             exit 1
#         }
#     }
#     elseif ($osVersion -match "Windows Server") {
#         Write-Host "Installing RSAT for Windows Server..."

#         # Attempt to install RSAT using Install-WindowsFeature
#         try {
#             Install-WindowsFeature -Name "RSAT-AD-Tools" -IncludeAllSubFeature
#         }
#         catch {
#             Write-Host "Error installing RSAT: $($_.Exception.Message)"
#             Write-Host "Please install RSAT manually through Server Manager."
#             exit 1
#         }
#     }
#     else {
#         Write-Host "Unsupported operating system. Please install RSAT manually."
#         exit 1
#     }

#     Write-Host "RSAT installation complete. Restarting PowerShell..."
#     # Restart PowerShell to load the newly installed module
#     powershell -command "Start-Process powershell -Verb RunAs"
#     exit 0
# }

# Import the Active Directory module
Import-Module ActiveDirectory

# Define an array of domains to query
$domains = @(
    "example1.com",
    "primary"
)

# Define an array of privileged groups to check
$privilegedGroups = @(
    "Domain Admins",
    "Enterprise Admins",
    "Schema Admins"
)

# Create an empty array to store all results
$allResults = @()

# Loop through each domain
foreach ($domain in $domains) {
    Write-Host "Processing domain: $domain"

    # Loop through each privileged group
    foreach ($group in $privilegedGroups) {
        Write-Host "  Checking group: $group"

        try {
            # Get members of the group in the current domain
            $members = Get-ADGroupMember -Identity $group -Server $domain -Recursive | Get-ADUser -Properties *

            # Add results to the $allResults array
            $members | ForEach-Object {
                $allResults += [PSCustomObject]@{
                    Domain = $domain
                    Group = $group
                    Account = $_.Name
                    Created = $_.whenCreated
                    Status = if ($_.Enabled) { "Active" } else { "Inactive" } 
                }
            } 
        }
        catch {
            Write-Host "  Error retrieving group members: $($_.Exception.Message)"
        }
    }
}

# Export all results to CSV
$allResults | Export-Csv -Path "privileged_accounts.csv" -NoTypeInformation
