# Import the Active Directory module
Import-Module ActiveDirectory

# Define an array of domains to query
$domains = @(
    "example1.com",
    "primary" 
)

# Create an empty array to store all results
$allResults = @()

# Loop through each domain
foreach ($domain in $domains) {
    Write-Host "Processing domain: $domain"

    try {
        # Get all users with "IBM" in their company property
        $users = Get-ADUser -LDAPFilter "(company=IBM)" -Server $domain -Properties whenCreated, Enabled

        # Add results to the $allResults array
        $users | ForEach-Object {
            $allResults += [PSCustomObject]@{
                Domain = $domain
                Account = $_.Name
                Created = $_.whenCreated
                Status = if ($_.Enabled) { "Active" } else { "Inactive" } 
            }
        }
    }
    catch {
        Write-Host "  Error retrieving users: $($_.Exception.Message)"
    }
}

# Export all results to CSV
$allResults | Export-Csv -Path "ibm_users.csv" -NoTypeInformation
