# This script create user in azure and exchange365
# The script prompts the shared mailbox to new  ID user.
# Edit line 25 to yourdomain.com

## Import required modules
Import-Module ExchangeOnlineManagement
Import-Module AzureAD

# Connect to Exchange Online and Azure AD
Connect-ExchangeOnline
Connect-AzureAD

# Function to get valid input
function Get-ValidInput($prompt) {
    do {
        $input = Read-Host $prompt
    } while ([string]::IsNullOrWhiteSpace($input))
    return $input
}

# 1. Create a new user
$firstName = Get-ValidInput "Enter the user's first name"
$lastName = Get-ValidInput "Enter the user's last name"
$displayName = "$firstName $lastName"
$username = Get-ValidInput "Enter the desired username (e.g., john.doe)"
$userPrincipalName = "$username@yourdomain.com"
$password = Get-ValidInput "Enter the initial password for the user"

# Create a password profile
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $password
$PasswordProfile.ForceChangePasswordNextLogin = $false

# Create the new user
New-AzureADUser -DisplayName $displayName -GivenName $firstName -Surname $lastName -UserPrincipalName $userPrincipalName -PasswordProfile $PasswordProfile -MailNickName $username -AccountEnabled $true

Write-Host "User $displayName created successfully."

# 2. Ask for the shared mailbox
$sharedMailbox = Get-ValidInput "Enter the email address of the shared mailbox"

# 3. Change the user ID of the shared mailbox to the newly created user
try {
    # Get the shared mailbox
    $mailbox = Get-Mailbox -Identity $sharedMailbox -ErrorAction Stop

    # Update the user ID (alias) of the shared mailbox
    Set-Mailbox -Identity $sharedMailbox -Alias $username

    Write-Host "Shared mailbox user ID updated successfully."
    Write-Host "New user ID (alias): $username"
}
catch {
    Write-Host "Error: Unable to update the shared mailbox. Please check if the provided email address is correct and try again."
    Write-Host "Error details: $_"
}

# Disconnect from Exchange Online and Azure AD
Disconnect-ExchangeOnline -Confirm:$false
Disconnect-AzureAD

