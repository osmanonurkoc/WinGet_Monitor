<#
    .SYNOPSIS
        WinGet Monitor A simple WinGet Update Notifier
    .DESCRIPTION
        Checks for updates. If found, shows a notification for 30 seconds.
        If ignored, it closes to free resources and avoid systray clutter.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$AppTitle = "WinGet Update Notifier"

# --- SINGLE INSTANCE CHECK ---
$currentProcess = [System.Diagnostics.Process]::GetCurrentProcess()
$others = Get-Process -Name $currentProcess.ProcessName -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $currentProcess.Id }
if ($others) { exit }

# --- UPDATE CHECK FUNCTION ---
function Check-Updates {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "winget"
    $processInfo.Arguments = "list --upgrade-available --accept-source-agreements"
    $processInfo.RedirectStandardOutput = $true
    $processInfo.UseShellExecute = $false
    $processInfo.CreateNoWindow = $true
    $processInfo.StandardOutputEncoding = [System.Text.Encoding]::UTF8

    try {
        $process = [System.Diagnostics.Process]::Start($processInfo)
        if (-not $process.WaitForExit(60000)) {
            $process.Kill()
            return 0
        }
        $output = $process.StandardOutput.ReadToEnd()
        $count = 0
        $lines = $output -split "`r`n"
        foreach ($line in $lines) {
            if ($line -match "(\d+\.\d+\.\d+)" -and $line -notmatch "Name|ID|Version") { $count++ }
        }
        return $count
    } catch { return 0 }
}

# --- UI & NOTIFICATION LOGIC ---
function Show-Notification ($count) {
    $global:notifyIcon = New-Object System.Windows.Forms.NotifyIcon

    try {
        $exePath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
        $global:notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)
    } catch {
        $global:notifyIcon.Icon = [System.Drawing.SystemIcons]::Shield
    }

    $global:notifyIcon.Text = $AppTitle
    $global:notifyIcon.Visible = $true

    # AUTO-EXIT TIMER (30 Seconds)
    $global:exitTimer = New-Object System.Windows.Forms.Timer
    $global:exitTimer.Interval = 30000
    $global:exitTimer.add_Tick({
        $global:notifyIcon.Visible = $false
        $global:notifyIcon.Dispose()
        [System.Windows.Forms.Application]::Exit()
    })
    $global:exitTimer.Start()

    # ACTION BLOCK (When user clicks)
    $ActionBlock = {
        $global:exitTimer.Stop()
        $global:notifyIcon.Visible = $false

        # Injecting $count into the CMD string
        $cmdArgs = "/k title WinGet Updater & echo $count updates found! & echo. & choice /m ""Update all apps silently now"" & if errorlevel 2 (exit) else (winget upgrade --all --silent --accept-source-agreements & echo. & echo Process Complete! & pause & exit)"

        $p = Start-Process "cmd.exe" -ArgumentList $cmdArgs -PassThru
        $p.WaitForExit()

        $global:notifyIcon.Dispose()
        [System.Windows.Forms.Application]::Exit()
    }.GetNewClosure() # This ensures $count is captured inside the block

    # EVENTS
    $global:notifyIcon.add_BalloonTipClicked($ActionBlock)
    $global:notifyIcon.add_MouseClick({ param($s, $e) if ($e.Button -eq 'Left') { & $ActionBlock } })

    # Context Menu
    $contextMenu = New-Object System.Windows.Forms.ContextMenu
    $contextMenu.MenuItems.Add("Update Now", $ActionBlock)
    $contextMenu.MenuItems.Add("Close", {
        $global:notifyIcon.Visible = $false
        $global:notifyIcon.Dispose()
        [System.Windows.Forms.Application]::Exit()
    })
    $global:notifyIcon.ContextMenu = $contextMenu

    $global:notifyIcon.BalloonTipTitle = "Updates Available"
    $global:notifyIcon.BalloonTipText = "$count applications can be updated.`nClick here to install."
    $global:notifyIcon.ShowBalloonTip(30000)

    [System.Windows.Forms.Application]::Run()
}

# --- EXECUTION ---
$updateCount = Check-Updates
if ($updateCount -gt 0) {
    Show-Notification $updateCount
} else {
    exit
}
