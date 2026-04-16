# Robocopy Backup Script

A PowerShell script to automate folder backups using **Robocopy**, with detailed logging, error reporting, and a summary report.

---

## Features

- Copies a predefined list of folders from a **source** to a **destination**.
- Maintains detailed logs with full output.
- Generates a separate log file containing only **errors**.
- Produces a console and file **summary report** including total duration and folder status.
- Optionally restores **NTFS ACLs** on the destination.
- Supports **parallel threads** for faster copying.

---

## Requirements

- Windows PowerShell 5.1 or higher.
- Access to both source and destination drives.
- Optional: administrative privileges if using NTFS ACL restoration.

---

## Configuration

Edit the script at the top to configure:

```powershell
$Source      = "Y:\"         # Source drive or folder
$Destination = "I:\"         # Destination drive or folder
$LogDir      = "C:\Logs"    # Directory for log files

$Folders = @(
    "Purchasing",
    "Agora",
    "Projects"
)

$CopyNtfsSecurity = $false    # Set to $true if ACL restoration is needed