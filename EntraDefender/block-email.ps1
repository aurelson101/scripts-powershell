#This script allows you to block spam emails globally from azure defender
#Don't forget to replace domain.com with your exchange admin account
#You need to install exchange module first.
# Connect to Exchange Online
$username = Read-Host -Prompt "Enter your username"

Connect-ExchangeOnline -UserPrincipalName "$username@domain.com"

$menu = @(
    "1. Display the list of blocked senders",
    "2. Block a new email address",
    "3. Unblock an email address",
    "4. Exit"
)

do {
    Write-Host "Please select an option:"
    $menu | ForEach-Object { Write-Host $_ }

    $choice = Read-Host -Prompt "Enter your choice"

    switch ($choice) {
        1 {
            # Display the list of blocked senders
            Get-TenantAllowBlockListItems -ListType Sender -Block | Format-Table Value,ExpirationDate,Identity
        }
        2 {
            # Prompt for the email address to block
            $EmailToBlock = Read-Host -Prompt "Enter the email address to block"

            # Block the specified email address without expiration
            New-TenantAllowBlockListItems -ListType Sender -Block -Entries $EmailToBlock -NoExpiration

            # Display the updated list of blocked senders
            Get-TenantAllowBlockListItems -ListType Sender -Block | Format-Table Value,ExpirationDate,Identity
        }
        3 {
            # Display the list of blocked senders
            $blockedSenders = Get-TenantAllowBlockListItems -ListType Sender -Block

            # Prompt for the email address to unblock
            $EmailToUnblock = Read-Host -Prompt "Enter the email address to unblock"

            # Find the ID of the email address to unblock
            $senderId = $blockedSenders | Where-Object { $_.Value -eq $EmailToUnblock } | Select-Object -ExpandProperty Identity

            if ($senderId) {
                # Unblock the specified email address using the ID
                Remove-TenantAllowBlockListItems -ListType Sender -Ids $senderId

                # Display the updated list of blocked senders
                Get-TenantAllowBlockListItems -ListType Sender -Block | Format-Table Value,ExpirationDate,Identity
            } else {
                Write-Host "Email address not found in the blocked senders list."
            }
        }
        4 {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid choice. Please try again."
        }
    }
} while ($true)

# Disconnect from Exchange Online
Disconnect-ExchangeOnline
