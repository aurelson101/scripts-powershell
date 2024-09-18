# Description: This script searches for inactive computers in a specified OU,
# disables them, and moves them to a designated OU for disabled computers.

# Import Active Directory module
Import-Module ActiveDirectory

# Define OUs
$SourceOU = "OU=Computers,DC=example,DC=com"
$DestinationOU = "OU=Disabled Computers,DC=example,DC=com"

# Calculate the date 90 days ago
$90DaysAgo = (Get-Date).AddDays(-90)

# Search for computers inactive for 90 days in the specified OU
$InactiveComputers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $90DaysAgo} -SearchBase $SourceOU -Properties Name, LastLogonTimeStamp

# Check if there are inactive computers
if ($InactiveComputers) {
    Write-Host "Computers inactive for more than 90 days:"
    
    foreach ($computer in $InactiveComputers) {
        $lastLogon = [DateTime]::FromFileTime($computer.LastLogonTimeStamp)
        
        Write-Host "Name: $($computer.Name), Last logon: $lastLogon"
        
        # Disable the computer
        Disable-ADAccount -Identity $computer
        Write-Host "  - Computer disabled"
        
        # Move the computer to the destination OU
        Move-ADObject -Identity $computer.DistinguishedName -TargetPath $DestinationOU
        Write-Host "  - Moved to 'Disabled Computers' OU"
        
        Write-Host ""
    }
} else {
    Write-Host "No computers inactive for more than 90 days were found in the specified OU."
}