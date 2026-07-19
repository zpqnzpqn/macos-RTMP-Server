# macOS 本機 RTMP 串流伺服器（Apple Silicon 版）

專為 **Apple Silicon (M1/M2/M3/M4)** Mac 打造的輕量級本機 RTMP 串流伺服器。支援從 OBS、手機或任何 RTMP 相容來源串流至您的 Mac。

> **Fork 說明：** 本專案是 [sallar/mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server)（已封存）的活躍維護分支，重新針對 Apple Silicon 建構，並新增多項功能與修復。

[English](README.md) | **繁體中文** | [日本語](README_ja.md) | [Español](README_es.md) | [Français](README_fr.md)

## ✨ 功能特色

- **原生 Apple Silicon 支援** — 在 M1/M2/M3/M4 Mac 上原生運行（ARM64）
- **一鍵啟動 RTMP 伺服器** — 啟動後立即在 port 1935 開啟本機 RTMP 伺服器
- **自動偵測網路 IP** — 自動搜尋所有本機 IPv4 位址（Wi-Fi、有線網路等），並顯示可直接複製的完整 RTMP 網址
- **串流金鑰管理** — 可選擇隨機自動產生或自訂固定金鑰
- **HLS 即時預覽** — 在應用程式內直接預覽正在進行的串流畫面
- **選單列或 Dock 模式** — 可選擇常駐在選單列（輕量模式）或應用程式列（Dock 模式）
- **多串流支援** — 同時處理多組 RTMP 串流
- **即時串流資訊** — 查看每組串流的編碼格式、解析度、幀率、流量與連線數

## 📋 系統需求

- **macOS** 11.0（Big Sur）或更新版本
- **Apple Silicon** Mac（M1/M2/M3/M4）— Intel Mac 可透過 Rosetta 運行
- **FFmpeg**（HLS 轉碼所需）

### 安裝 FFmpeg

```bash
brew install ffmpeg
```

## 📦 安裝方式

### 方式一：下載 DMG 安裝檔（推薦）

1. 從 [Releases 頁面](https://github.com/zpqnzpqn/Local-RTMP-Server/releases) 下載最新的 `.dmg` 檔案。
2. 打開 DMG，將應用程式拖入「應用程式」資料夾。
3. 啟動 **Local RTMP Server**。

> **注意：** 由於此應用程式未經 Apple 簽署，首次啟動時可能需要按右鍵 → 打開，或前往「系統設定 → 隱私與安全性 → 仍然打開」。

### 方式二：從原始碼建構

```bash
git clone https://github.com/zpqnzpqn/Local-RTMP-Server.git
cd Local-RTMP-Server
npm install
npm start        # 開發模式運行
npm run dist     # 建構 ARM64 DMG
```

## 🚀 使用方式

### 基本串流

1. 啟動應用程式 — RTMP 伺服器將自動在 port `1935` 上啟動。
2. 複製畫面上顯示的 RTMP 網址（例如 `rtmp://192.168.1.100/live/abc123`）。
3. 在您的串流軟體中（OBS、Streamlabs 等）：
   - 將 **伺服器** 設定為複製的網址
   - 不需要另外輸入串流金鑰 — 已經包含在網址中
4. 開始串流 — 應用程式會即時顯示串流統計數據。

### 從其他裝置串流

若要從同一網路的其他裝置串流（例如使用 [Larix Broadcaster](https://wmspanel.com/larix_broadcaster) 的手機）：

1. 使用應用程式中顯示的本機 IP RTMP 網址。
2. 確保兩台裝置在同一個 Wi-Fi / 區域網路。

### 預覽串流

點擊 **「串流預覽」** 按鈕，即可在應用程式內觀看即時 HLS 串流畫面。

### 虛擬攝影機（透過 OBS）

如果您需要在 Zoom 或 Google Meet 中使用 RTMP 串流作為虛擬攝影機：

1. 開啟 **OBS Studio**（[點此下載](https://obsproject.com/)）
2. 新增 **媒體來源** → 輸入 RTMP 網址
3. 在 OBS 中點擊 **啟動虛擬攝影機**
4. 在 Zoom / Meet 中選擇 **OBS Virtual Camera** 作為攝影機

應用程式底部提供 [OBS 虛擬攝影機教學](https://obsproject.com/kb/virtual-camera-guide) 的直接連結。

## ⚙️ 設定選項

點擊 **齒輪圖示**（⚙️）進入設定：

| 設定項目 | 選項 | 說明 |
|----------|------|------|
| 串流金鑰 | 隨機 / 固定 | 隨機模式每次啟動產生新金鑰；固定模式使用您自訂的金鑰 |
| 常駐位置 | 選單列 / Dock | 選擇應用程式顯示位置 — 輕量選單列或標準 Dock 視窗 |
| 介面語言 | 系統預設 / 英文 / 繁體中文 / 日本語 / 西班牙文 / 法文 | 切換應用程式顯示的語系 |

> 切換常駐位置需要重新啟動應用程式（會自動處理）。

## 🔒 安全注意事項

- **僅限本機區域網路** — RTMP 伺服器僅供受信任的區域網路使用。RTMP 連接埠無認證機制。
- **請勿暴露至網際網路** — 未經額外安全措施（防火牆、VPN 等），請勿將 port 1935 公開至網際網路。
- **串流金鑰** — 串流金鑰提供基本的串流識別功能，但並非安全機制。同一網路上的任何人在知道網址的情況下都可以連接。

## 🛠 技術詳情

| 元件 | 技術 |
|------|------|
| 框架 | Electron 30 |
| RTMP 引擎 | Node-Media-Server |
| 轉碼 | FFmpeg（HLS） |
| 介面 | 原生 HTML/CSS/JS |
| 平台 | macOS ARM64（Apple Silicon） |

## 📝 版本紀錄

### v2.0.0（目前版本）
- ✅ 原生移植至 Apple Silicon（ARM64）
- ✅ 升級 Electron 至 v30、electron-builder 至 v24
- ✅ 自動偵測所有本機網路 IP
- ✅ 顯示完整 RTMP 網址（IP + 金鑰合併）
- ✅ 新增串流金鑰管理（隨機 / 固定）
- ✅ 新增選單列 / Dock 模式選擇
- ✅ 新增 HLS 即時串流預覽
- ✅ 新增 OBS 虛擬攝影機使用引導
- ✅ 修復多個程式碼錯誤與記憶體洩漏
- ✅ 強化安全性（CORS 限制）
- ✅ 修補 node-media-server 相容性問題

## 📄 授權條款

本專案採用 [MIT License](LICENSE) 發佈。

原始版本由 [Sallar Kaboli](https://github.com/sallar) 建立。本分支由 [zpqnzpqn](https://github.com/zpqnzpqn) 獨立維護，支援 Apple Silicon 並新增多項功能。

## 🔗 相關資源

- [OBS Studio](https://obsproject.com/) — 開源串流與錄影軟體
- [OBS 虛擬攝影機教學](https://obsproject.com/kb/virtual-camera-guide) — 使用 OBS 作為虛擬攝影機
- [Larix Broadcaster](https://wmspanel.com/larix_broadcaster) — 手機 RTMP 串流應用程式
- [VLC Media Player](https://www.videolan.org/) — 使用 `rtmp://` 網址播放 RTMP 串流
