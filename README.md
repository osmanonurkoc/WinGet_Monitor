# Winget Update Monitor 🚀

A lightweight, silent, open-source tool that resides in the system tray to keep your Windows applications up to date.

![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)
![Built With](https://img.shields.io/badge/Built%20With-PowerShell-5391FE)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

* **👻 Ghost Mode:** The icon remains completely hidden when there are no updates, keeping your system tray clean.
* **🔔 Native Notifications:** Uses the native Windows 10/11 notification system (Toast).
* **⚡ Quick Action:** Clicking the notification or icon opens the terminal prompt; with your confirmation, it silently installs all updates (`--silent`).
* **🛡️ Lightweight:** Built on PowerShell, consuming minimal resources in the background.

## 🚀 Installation & Usage

1.  Download the `WingetMonitor.exe` file from the **[Releases Page](https://github.com/osmanonurkoc/WinGet_Monitor/releases/latest)**.
2.  Run the application. (Note: It will not be visible initially if there are no pending updates; it runs in the background).
3.  To start the application automatically on boot, place a shortcut of the `.exe` file into your `shell:startup` folder.

## 🛠️ Build (For Developers)

This project is compiled using **PowerShell Studio**. The source code (`.ps1`) is included in the repository. To use a custom icon, the script automatically extracts it from the executable or looks for an `app.ico` file in the same directory.

## 📄 License
This project is licensed under the [MIT License](LICENSE).

---
*Created by [@osmanonurkoc](https://www.osmanonurkoc.com)*
