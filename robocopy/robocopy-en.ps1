#Requires -Version 5.1

<#
.SYNOPSIS
    Robocopy backup script with logging and summary report.
.DESCRIPTION
    Copies a list of folders from source to destination
    with detailed logging and a summary report,
    plus a separate log file containing only errors.
    Note: the script should be run in a user session, then adjust
    the drive letters for source and destination.
    If restricted folders are encountered, /ZB attempts to use backup mode
    (requires backup privileges, typically available to administrators).
#>
# Author: Husson Aurelien - aurelson.com
# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────
$Source      = "Y:\"
$Destination = "I:\"
$LogDir      = "C:\Logs"

$Folders = @(
    "Achats",
    "Agora",
    "Analyse Environnementale Defta",
    "Commercial",
    "DCI",
    "Direction",
    "DIRH",
    "Documents Process à signer",
    "Entretiens Annuels et Prof non Cadres & Fiches Descriptives Emplois",
    "Expertise CE 2012",
    "Finances",
    "Logistique",
    "Maintenance HSE",
    "Methodes",
    "Panel Defta",
    "Production",
    "Projets",
    "PSS Essomes - PDCA",
    "Responsables de services"
)

# Enable this option only if the execution account
# has rights to restore NTFS ACLs on the destination.
$CopyNtfsSecurity = $false

$RoboOptions = @(
"/E",        # Copy all subfolders, including empty ones
"/COPY:DAT", # Copy Data/Attributes/Timestamps
"/DCOPY:DAT",# Copy Data/Attributes/Timestamps for directories
"/SEC",      # Copy ACLs that your account can apply
"/BYTES",    # Show sizes in bytes
"/NC",       # No file class
"/NDL",      # No directory listing
"/NP",       # No percentage progress
"/R:3",      # 3 retries on error
"/W:10",     # Wait 10 seconds between retries
"/MT:8"      # 8 parallel threads
)

if ($CopyNtfsSecurity) {
    # /SECFIX re-applies security even on already copied files
    $RoboOptions += @("/COPY:DATSOU", "/DCOPY:DAT", "/SECFIX")
}

# ─────────────────────────────────────────────
#  INITIALIZATION
# ─────────────────────────────────────────────
# Check access to source drive
if (-not (Test-Path $Source)) {
    Write-Error "Source drive $Source is not accessible. Map the network drive before running the script."
    exit 1
}

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory | Out-Null
}

$TimeStamp    = Get-Date -Format "yyyy-MM-dd_HH-mm"
$LogFile      = Join-Path $LogDir "Robocopy_$TimeStamp.log"
$ErrorLogFile = Join-Path $LogDir "Robocopy_Errors_$TimeStamp.log"

# Clean initialization of log files
Set-Content -Path $LogFile      -Value "=== Backup started on $(Get-Date) ===" -Encoding UTF8
Set-Content -Path $ErrorLogFile -Value "=== Backup Errors - $(Get-Date) ===" -Encoding UTF8

$Results   = [System.Collections.Generic.List[PSCustomObject]]::new()
$StartTime = Get-Date

Write-Host "`n=== Backup started: $StartTime ===" -ForegroundColor Cyan

# ─────────────────────────────────────────────
#  COPY LOOP
# ─────────────────────────────────────────────
foreach ($Folder in $Folders) {

    $Src = Join-Path $Source $Folder
    $Dst = Join-Path $Destination $Folder

    # If source does not exist
    if (-not (Test-Path $Src)) {
        Write-Warning "Source not found, folder skipped: $Src"
        $Results.Add([PSCustomObject]@{
            Folder  = $Folder
            Status  = "SOURCE MISSING"
            Code    = -1
            Duration = "—"
        })
        continue
    }

    Write-Host "  Copying: $Folder ..." -NoNewline

    $JobStart = Get-Date

    # Capture Robocopy output (avoid using /LOG to prevent double reading)
    $RoboArgs   = @($Src, $Dst) + $RoboOptions + @("/TS", "/FP")
    $RoboOutput = & RoboCopy.exe @RoboArgs

    $ExitCode = $LASTEXITCODE
    $Duration = (Get-Date) - $JobStart

    # Write to main log
    Add-Content -Path $LogFile -Value "`n--- $Folder ---" -Encoding UTF8
    $RoboOutput | Add-Content -Path $LogFile -Encoding UTF8

    # Write errors only to error log
    $ErrorLines = $RoboOutput | Where-Object { $_ -match 'ERROR\s+\d+' }
    if ($ErrorLines) {
        Add-Content -Path $ErrorLogFile -Value "`n--- $Folder ---" -Encoding UTF8
        $ErrorLines | Add-Content -Path $ErrorLogFile -Encoding UTF8
    }

    # Full interpretation of Robocopy exit codes
    $Status = switch ($ExitCode) {
        0       { "Nothing to copy" }
        1       { "OK" }
        2       { "Extras detected" }
        3       { "OK + Extras" }
        4       { "Different files" }
        5       { "OK + Differences" }
        6       { "Extras + Differences" }
        7       { "OK + Extras + Differences" }
        default { if ($ExitCode -ge 8) { "ERROR" } else { "Code $ExitCode" } }
    }

    # Format duration (adapted for fast copies <1 sec)
    $DurationStr = if ($Duration.TotalSeconds -lt 1) {
        "< 1s"
    } elseif ($Duration.TotalSeconds -lt 60) {
        "$([int]$Duration.TotalSeconds)s"
    } else {
        $Duration.ToString("mm\:ss")
    }

    $Color = if ($ExitCode -ge 8) { "Red" } elseif ($ExitCode -ge 1) { "Green" } else { "Gray" }
    Write-Host " $Status ($DurationStr)" -ForegroundColor $Color

    $Results.Add([PSCustomObject]@{
        Folder   = $Folder
        Status   = $Status
        Code     = $ExitCode
        Duration = $DurationStr
    })
}

# ─────────────────────────────────────────────
#  SUMMARY REPORT
# ─────────────────────────────────────────────
$TotalDuration = (Get-Date) - $StartTime
$Errors  = @($Results | Where-Object { $_.Code -ge 8 -or $_.Code -eq -1 })
$OkCount = @($Results | Where-Object { $_.Code -ge 0 -and $_.Code -lt 8 }).Count

$SummaryLines = @(
    "",
    "─────────────────────────────────────",
    "  SUMMARY REPORT",
    "─────────────────────────────────────",
    ($Results | Format-Table -AutoSize | Out-String),
    "  Total duration: $($TotalDuration.ToString('hh\:mm\:ss'))",
    "  Folders OK    : $OkCount / $($Folders.Count)"
)

if ($Errors) {
    $SummaryLines += "  Errors on     : $(($Errors.Folder) -join ', ')"
    $SummaryLines += "  Error log file: $ErrorLogFile"
} else {
    $SummaryLines += "  No errors detected."
}

$SummaryLines += "  Full log      : $LogFile"
$SummaryLines += ""

# Display console summary
Write-Host "`n─────────────────────────────────────" -ForegroundColor DarkGray
Write-Host "  SUMMARY REPORT" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────" -ForegroundColor DarkGray
$Results | Format-Table -AutoSize
Write-Host "  Total duration: $($TotalDuration.ToString('hh\:mm\:ss'))"
Write-Host "  Folders OK    : $OkCount / $($Folders.Count)"

if ($Errors) {
    Write-Host "  ⚠ Errors on   : $(($Errors.Folder) -join ', ')" -ForegroundColor Red
    Write-Host "  Error log file: $ErrorLogFile" -ForegroundColor Red
} else {
    Write-Host "  No errors detected." -ForegroundColor Green
}
Write-Host "  Full log      : $LogFile`n" -ForegroundColor DarkGray

# Write summary to log
Add-Content -Path $LogFile -Value ($SummaryLines -join "`n") -Encoding UTF8