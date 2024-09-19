#This script connects to Microsoft Graph and lists Azure AD applications with their Object IDs.
#It can help users find the correct Object ID for use in other scripts or operations.
#Requires the Microsoft Graph PowerShell SDK to be installed and imported.
#The user running this script must have sufficient permissions to read application information in Azure AD.
#This script lists all applications by default. You can modify the filter or limit the number of results as needed.

# Check if the Microsoft.Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "The Microsoft.Graph module is not installed. Installing now..."
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
    Write-Host "Microsoft.Graph module has been installed."
}

# Import the Microsoft.Graph module
Import-Module Microsoft.Graph

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.Read.All"

# Get all applications
$applications = Get-MgApplication -All

# Display applications with their Object IDs
Write-Host "Azure AD Applications and their Object IDs:"
Write-Host "----------------------------------------"

foreach ($app in $applications) {
    Write-Host "Display Name: $($app.DisplayName)"
    Write-Host "Object ID: $($app.Id)"
    Write-Host "Application ID (Client ID): $($app.AppId)"
    Write-Host "----------------------------------------"
}

# Display the total number of applications
Write-Host "Total number of applications: $($applications.Count)"

# Disconnect from Microsoft Graph
Disconnect-MgGraph
