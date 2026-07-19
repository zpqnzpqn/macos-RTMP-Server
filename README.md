# Local RTMP Server for macOS (Apple Silicon)

A lightweight, native RTMP streaming server for macOS, designed specifically for **Apple Silicon (M1/M2/M3/M4)** Macs. Stream from OBS, mobile devices, or any RTMP-compatible source to your local machine.

> **Fork Notice:** This is an actively maintained fork of [sallar/mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) (archived), rebuilt for Apple Silicon with new features and bug fixes.

**English** | [繁體中文](README_zh-TW.md) | [日本語](README_ja.md) | [Español](README_es.md) | [Français](README_fr.md)

## ✨ Features

- **Native Apple Silicon Support** — Runs natively on M1/M2/M3/M4 Macs (ARM64)
- **One-Click RTMP Server** — Launch a local RTMP server instantly on port 1935
- **Auto-Detect Network IPs** — Automatically discovers all local IPv4 addresses (Wi-Fi, Ethernet, etc.) and displays ready-to-copy full RTMP URLs
- **Stream Key Management** — Choose between random (auto-generated) or fixed custom stream keys
- **HLS Live Preview** — Preview active streams directly within the app using the built-in HLS player
- **Menu Bar or Dock Mode** — Run as a lightweight menu bar app or a standard Dock application
- **Multi-Stream Support** — Handle multiple simultaneous RTMP streams
- **Real-Time Stream Info** — View codec, resolution, framerate, traffic, and client count for each active stream

## 📋 Requirements

- **macOS** 11.0 (Big Sur) or later
- **Apple Silicon** Mac (M1/M2/M3/M4) — or Intel Mac with Rosetta
- **FFmpeg** (required for HLS transcoding)

### Install FFmpeg

```bash
brew install ffmpeg
```

## 📦 Installation

### Option 1: Download DMG (Recommended)

1. Download the latest `.dmg` from the [Releases](https://github.com/zpqnzpqn/macos-RTMP-Server/releases) page.
2. Open the DMG and drag the app to your Applications folder.
3. Launch **Local RTMP Server**.

> **Note:** Since the app is not code-signed, you may need to right-click → Open on first launch, or go to System Settings → Privacy & Security → Open Anyway.

### Option 2: Build from Source

```bash
git clone https://github.com/zpqnzpqn/macos-RTMP-Server.git
cd macos-RTMP-Server
npm install
npm start        # Run in development mode
npm run dist     # Build DMG for ARM64
```

## 🚀 Usage

### Basic Streaming

1. Launch the app — it will start the RTMP server automatically on port `1935`.
2. Copy one of the displayed RTMP URLs (e.g., `rtmp://192.168.1.100/live/abc123`).
3. In your streaming software (OBS, Streamlabs, etc.):
   - Set **Server** to the copied URL
   - No separate stream key is needed — it's already included in the URL
4. Start streaming — the app will show real-time stream statistics.

### Streaming from Another Device

To stream from another device on the same network (e.g., a phone using [Larix Broadcaster](https://wmspanel.com/larix_broadcaster)):

1. Use the RTMP URL with your Mac's local IP address (shown in the app).
2. Make sure both devices are on the same Wi-Fi/LAN.

### Preview a Stream

Click the **串流預覽 (Stream Preview)** button to watch the live HLS feed directly in the app.

### Virtual Camera (via OBS)

If you need to use the RTMP stream as a virtual webcam in apps like Zoom or Google Meet:

1. Open **OBS Studio** ([download here](https://obsproject.com/))
2. Add a **Media Source** → Enter the RTMP URL
3. Click **Start Virtual Camera** in OBS
4. In Zoom/Meet, select **OBS Virtual Camera** as your camera

The app includes a direct link to the [OBS Virtual Camera Guide](https://obsproject.com/kb/virtual-camera-guide) at the bottom of the interface.

## ⚙️ Settings

Click the **gear icon** (⚙️) to access settings:

| Setting | Options | Description |
|---------|---------|-------------|
| Stream Key | Random / Fixed | Random generates a new key each launch; Fixed lets you set a persistent key |
| App Residence | Menu Bar / Dock | Choose where the app appears — lightweight menu bar tray or standard Dock window |
| Language | System Default / English / Traditional Chinese / Japanese / Spanish / French | Change the interface language of the application |

> Changing the App Residence mode requires an app restart (handled automatically).

## 🔒 Security Notes

- **Local Network Only** — The RTMP server is intended for use on trusted local networks only. There is no authentication on the RTMP port.
- **No Internet Exposure** — Do not expose port 1935 to the internet without additional security measures (firewall, VPN, etc.).
- **Stream Keys** — Stream keys provide basic stream identification but are not a security mechanism. Anyone on the same network can connect if they know the URL.

## 🛠 Technical Details

| Component | Technology |
|-----------|------------|
| Framework | Electron 30 |
| RTMP Engine | Node-Media-Server |
| Transcoding | FFmpeg (HLS) |
| UI | Native HTML/CSS/JS |
| Platform | macOS ARM64 (Apple Silicon) |

## 📝 Changelog

### v2.0.0 (Current)
- ✅ Ported to Apple Silicon (ARM64) natively
- ✅ Upgraded Electron to v30, electron-builder to v24
- ✅ Auto-detect all local network IPs
- ✅ Display complete RTMP URLs (IP + stream key combined)
- ✅ Added stream key management (random/fixed)
- ✅ Added Menu Bar / Dock mode selection
- ✅ Added HLS live stream preview
- ✅ Added OBS Virtual Camera guidance
- ✅ Fixed multiple code bugs and memory leaks
- ✅ Improved security (CORS restrictions)
- ✅ Patched node-media-server compatibility issues

## 📄 License

This project is released under the [MIT License](LICENSE).

Originally created by [Sallar Kaboli](https://github.com/sallar). This fork is maintained independently with Apple Silicon support and additional features.

## 🔗 Related Resources

- [OBS Studio](https://obsproject.com/) — Open-source streaming and recording software
- [OBS Virtual Camera Guide](https://obsproject.com/kb/virtual-camera-guide) — Use OBS as a virtual webcam
- [Larix Broadcaster](https://wmspanel.com/larix_broadcaster) — Mobile RTMP streaming app
- [VLC Media Player](https://www.videolan.org/) — Play RTMP streams with `rtmp://` URL
