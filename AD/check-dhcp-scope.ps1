# Description:
# This script monitors the available IP addresses in a specified DHCP scope.
# If the number of available addresses falls below a defined threshold,
# it sends an alert email to notify the administrator.
# The script uses PowerShell cmdlets to interact with the DHCP server
# and the Send-MailMessage cmdlet to send emails via SMTP.

# DHCP server parameters
$dhcpServer = "192.168.6.1"
$scopeId = "20.20.0.0"
$thresholdIP = 10

#remplace by this for multiple scope :
#$scopes = @(
#   @{Id = "20.20.0.0"; Threshold = 10},
#    @{Id = "192.168.1.0"; Threshold = 20},
#    @{Id = "10.0.0.0"; Threshold = 15}
#)

# SMTP server parameters for sending emails
$smtpServer = "mail.smtp.com"
$smtpPort = 25
$emailFrom = "myemail@example.com"
$emailTo = "myemail@example.com"
$emailSubject = "DHCP Alert - Few IP addresses available"

# Function to send an alert email
function Send-AlertEmail {
    param (
        [string]$body
    )
    
    $securePassword = ConvertTo-SecureString $smtpPassword -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($smtpUsername, $securePassword)
    
    Send-MailMessage -From $emailFrom -To $emailTo -Subject $emailSubject -Body $body -SmtpServer $smtpServer -Port $smtpPort
}

# Get DHCP scope statistics
$scopeStats = Get-DhcpServerv4ScopeStatistics -ScopeId $scopeId

# Check the number of available IP addresses
if ($scopeStats.Free -lt $thresholdIP) {
    $emailBody = "Warning: Only $($scopeStats.Free) available IP addresses in the range $scopeId on the local DHCP server."
    Send-AlertEmail -body $emailBody
}