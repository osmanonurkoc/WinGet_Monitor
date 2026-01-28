<#
    .SYNOPSIS
        WinGet Monitor

    .DESCRIPTION
        A simple WinGet Update Notifier App

    .NOTES
        Author:  Osman Onur Koç
        License: MIT License

    .LINK
        https://github.com/osmanonurkoc/WinGet_Monitor
#>

# Load required .NET Assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- SETTINGS ---
$CheckIntervalSeconds = 14400 # Check every 4 Hours
$AppTitle = "Winget Update Checker"

# --- CREATE SYSTRAY ICON ---
$notifyIcon = New-Object System.Windows.Forms.NotifyIcon

# --- ICON LOGIC  ---
try {
    $currentProcess = [System.Diagnostics.Process]::GetCurrentProcess()
    $currentModule = $currentProcess.MainModule
    if ($null -ne $currentModule) {
        $exePath = $currentModule.FileName
        # Extract the icon embedded in the EXE file
        $notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
    } else {
        # Fallback if module path fails
        $notifyIcon.Icon = [System.Drawing.SystemIcons]::Shield
    }
}
catch {
    # If extraction fails entirely, use the default Shield
    $notifyIcon.Icon = [System.Drawing.SystemIcons]::Shield
}

$notifyIcon.Text = $AppTitle
$notifyIcon.Visible = $false # Start Hidden (Ghost Mode)

# --- CONTEXT MENU (Right Click) ---
$contextMenu = New-Object System.Windows.Forms.ContextMenu
$menuItemExit = $contextMenu.MenuItems.Add("Exit")

# Exit Action
$menuItemExit.add_Click({
    $notifyIcon.Visible = $false
    $notifyIcon.Dispose()
    $timer.Stop()
    [System.Windows.Forms.Application]::Exit()
})

$notifyIcon.ContextMenu = $contextMenu

# --- UPDATE CHECK FUNCTION ---
function Check-Updates {
    # Prepare to run winget in the background (hidden)
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "winget"
    $processInfo.Arguments = "upgrade --accept-source-agreements --include-unknown"
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $processInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8

    # Start the process
    $process = [System.Diagnostics.Process]::Start($processInfo)
    $process.WaitForExit()

    # Capture output
    $output = $process.StandardOutput.ReadToEnd()

    $count = 0

    # Parse Output
    if ($output -match "Name" -and $output -match "Id" -and $output -match "Version") {
        $lines = $output -split "`n"
        foreach ($line in $lines) {
            # Logic: Line contains spacing, is not the header row, and has sufficient length
            if ($line -notmatch "Name" -and $line -match "\s\s+" -and $line.Length -gt 10) {
                $count++
            }
        }
    }

    # VISIBILITY LOGIC
    if ($count -gt 0) {
        $notifyIcon.Visible = $true

        $notifyIcon.BalloonTipTitle = "Updates Available"
        $notifyIcon.BalloonTipText = "$count applications can be updated.`nClick here to install."
        $notifyIcon.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info

        # Display Notification (5 seconds)
        $notifyIcon.ShowBalloonTip(5000)
    }
    else {
        $notifyIcon.Visible = $false
    }
}

# --- INTERACTION ACTIONS ---
$ActionBlock = {
    # CMD Logic
    $cmdArgs = '/k echo Updates Found! & echo. & choice /m "Update all apps silently now" & if errorlevel 2 (exit) else (winget upgrade --all --silent --accept-source-agreements & echo. & echo Done! & pause & exit)'

    Start-Process "cmd.exe" -ArgumentList $cmdArgs

    $notifyIcon.Visible = $false
}

# Trigger action on Balloon Click
$notifyIcon.add_BalloonTipClicked($ActionBlock)

# Trigger action on Icon Left Click
$notifyIcon.add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq 'Left') {
        & $ActionBlock
    }
})

# --- TIMER LOOP ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = $CheckIntervalSeconds * 1000
$timer.add_Tick({
    Check-Updates
})
$timer.Start()

# Perform the first check immediately
Check-Updates

# --- KEEP ALIVE ---
[System.Windows.Forms.Application]::Run()
