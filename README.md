# Local RTMP Server (macOS) v3.0

**English** | [繁體中文](README_zh-TW.md) | [日本語](README_ja.md) | [Español](README_es.md) | [Français](README_fr.md)

A lightweight, native, and high-performance RTMP Server for macOS. Built with SwiftUI and Node Media Server, it provides a seamless way to spin up a local streaming server for broadcasting your screen, testing stream setups (like OBS), or routing video feeds on your local network.

## ✨ Features in v3.0

- **Native macOS Interface**: Completely rewritten in Swift and SwiftUI. Enjoy a stunning, modern, and ultra-responsive macOS native UI with glassmorphism effects (macOS 13+).
- **Dynamic Multi-IP Support**: Automatically detects and displays all active IPv4 interfaces on your machine. You can instantly see and copy the exact RTMP URLs for different networks (Wi-Fi, Ethernet).
- **Live HLS Preview**: Built-in, zero-latency native AVPlayer preview. Start streaming from OBS and monitor your feed instantly within the app.
- **Smart Settings Engine**: Safely change your stream key or network ports on the fly. If you are currently live, the server intelligently delays network restarts until your stream ends, preventing accidental disconnections.
- **Menu Bar & Dock Modes**: Run the server silently in the background from your Menu Bar, or keep it in your Dock like a standard application.
- **Auto Start**: Optionally configure the server to automatically launch and start hosting the RTMP server on system boot.
- **Multi-Language Support**: Fully localized in English, Traditional Chinese (繁體中文), Japanese (日本語), Spanish (Español), and French (Français).

## 🚀 Installation

1. Download the latest `Local RTMP Server 3.0.dmg` from the Releases page.
2. Double-click the DMG file to mount it.
3. Drag the **Local RTMP Server** app icon into the **Applications** folder.
4. Launch the app from Launchpad or Applications.

> **Note**: If macOS displays a security warning about downloading an app from an unidentified developer, go to **System Settings > Privacy & Security** and click **Open Anyway**.

## 📖 How to Use

1. **Start the Server**: Click the Play button in the app. The status light will turn green.
2. **Copy the RTMP URL**: The app will display your local IP addresses. Copy the URL (e.g., `rtmp://192.168.1.100/live/mystreamkey`).
3. **Configure OBS**:
   - Go to OBS Settings -> Stream.
   - Service: `Custom`
   - Server: `rtmp://192.168.1.100/live`
   - Stream Key: `mystreamkey`
4. **Start Streaming**: Hit "Start Streaming" in OBS.
5. **Preview**: Click the "Live Preview" button in the app to monitor your feed.

## 🛠 Advanced Settings
Press `Cmd + ,` or click the gear icon to open Settings.
- **Stream Key Type**: Choose between a fixed, memorable key or let the app generate a random secure key every time.
- **Custom Ports**: Change the default RTMP port (1935) or HTTP HLS port (8000) if they conflict with other services.
- **App Residence**: Switch the app between running fully in the background (Menu Bar) or as a standard app in your Dock.

## ⚖️ License and Credits

Portions of this software are derived from and inspired by the following open-source projects, used under the MIT License:

1. [mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) by Sallar Kaboli (Copyright (c) 2018)
2. [macos-RTMP-Server](https://github.com/zpqnzpqn/macos-RTMP-Server) by zpqnzpqn (Copyright (c) 2026)

This project is licensed under the MIT License.
