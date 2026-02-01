
# WinGet Update Monitor 🚀

A lightweight, open-source tool that lives quietly in your system tray to keep your Windows applications up to date.

![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)
![Built With](https://img.shields.io/badge/Built%20With-PowerShell-5391FE)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

* **👻 Ghost Mode:** The icon remains completely hidden if no updates are found, keeping your system tray clean.
* **🔔 Smart Notifications:** Alerts you only when updates are available. If the notification is ignored for 30 seconds, the app closes automatically to save resources.
* **⚡ Quick Action:** Clicking the notification opens a terminal that allows you to install all updates silently (`--silent`) upon your confirmation.
* **🛠️ Resource Efficient:** Instead of running constantly in the background, it is designed to be triggered by Task Scheduler every 4 hours, closing itself once the check is done.

## 🚀 Setup (Task Scheduler)

Since this app is optimized to run and exit, it is recommended to add it to the **Windows Task Scheduler**. This ensures it checks for updates periodically without consuming RAM in between.

### Option 1: Automatic Setup via Terminal (Fastest)
1. Place the `WinGetMonitor.exe` in a permanent folder (e.g., `C:\Program Files\WinGetMonitor\`).
2. Open **PowerShell** or **CMD** as **Administrator**.
3. Run the following command (replace the path with your actual file location):

```powershell
schtasks /Create /TN "WinGetMonitorTask" /TR "'C:\Path\To\WinGetMonitor.exe'" /SC HOURLY /MO 4 /F
```
### Option 2: Manual Setup

1.  Open **Task Scheduler**.
    
2.  Click **Create Basic Task**.
    
3.  Set the trigger to **When I log on**.
    
4.  Set the action to **Start a program** and select your `WinGetMonitor.exe`.
    
5.  Once created, open the task's **Properties**, go to the **Triggers** tab, and edit the trigger to include **Repeat task every: 4 hours**.
    

## 🛠️ For Developers

This project is written in PowerShell and compiled using `ps2exe`.

-   Source code is available in `.ps1` format.
    
-   The system tray icon is automatically extracted from the compiled EXE.
    

## 📄 License

This project is licensed under the [MIT License](LICENSE).

----------

_Created by [@osmanonurkoc](https://github.com/osmanonurkoc)_
