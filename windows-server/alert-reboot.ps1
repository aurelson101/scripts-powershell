#This PowerShell script is designed to run at system startup. It sends an email
#notification containing the server name and the time of the last reboot using
#a simple SMTP server on port 25.

# Email configuration parameters
$smtpServer = "smtp.yourdomain.com"
$smtpPort = 25
$fromAddress = "your_email@yourdomain.com"
$toAddress = "recipient@yourdomain.com"

# Get the server name
$serverName = $env:COMPUTERNAME

# Get the last boot time
$lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime

# Format the date and time in English
$formattedBootTime = $lastBootTime.ToString("dddd, MMMM dd, yyyy HH:mm:ss", [System.Globalization.CultureInfo]::GetCultureInfo("en-US"))

# Create the subject and body of the message
$subject = "Server Reboot Notification: $serverName"
$body = "The server ($serverName) has rebooted on $formattedBootTime"

# Send the email
try {
    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort `
        -From $fromAddress -To $toAddress -Subject $subject -Body $body -ErrorAction Stop
    Write-Host "Notification email sent successfully."
} catch {
    Write-Host "Error sending email: $_"
}
