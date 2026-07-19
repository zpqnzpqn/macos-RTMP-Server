# Local RTMP Server (macOS) v3.0

[English](README.md) | **繁體中文** | [日本語](README_ja.md) | [Español](README_es.md) | [Français](README_fr.md)

這是一個輕量、原生且高效能的 macOS 專用 RTMP 伺服器。採用 SwiftUI 與 Node Media Server 打造，提供無縫的方式在本地網路中快速啟動串流伺服器，非常適合用來進行螢幕廣播、測試串流軟體（例如 OBS），或是在區域網路內傳輸影片訊號。

## ✨ v3.0 新功能亮點

- **macOS 原生介面**：使用 Swift 與 SwiftUI 徹底重寫。享受美觀、現代化且極度流暢的 macOS 原生介面與毛玻璃特效 (macOS 13+)。
- **動態多重 IP 支援**：自動偵測並顯示您電腦上所有活躍的 IPv4 網路介面。您可以立即查看並複製不同網路環境 (Wi-Fi, 乙太網路) 下準確的 RTMP 網址。
- **無延遲 HLS 預覽**：內建零延遲的原生 AVPlayer 預覽視窗。當您從 OBS 開始推流時，可以直接在 App 內即時監看畫面。
- **智慧設定引擎**：隨時安全地更改串流金鑰或連接埠。如果您目前正在串流中，伺服器會智慧地延遲網路重啟程序直到串流結束，避免意外導致直播斷線。
- **選單列與 Dock 模式**：讓伺服器安靜地在背景的「選單列 (Menu Bar)」中運作，或是像一般應用程式一樣常駐在您的 Dock 上。
- **開機自動啟動**：可設定在系統開機時，自動啟動 App 並立即啟動 RTMP 伺服器。
- **多國語系支援**：完整支援英文、繁體中文、日文 (日本語)、西班牙文 (Español) 與法文 (Français)。

## 🚀 安裝說明

1. 從 Releases 頁面下載最新的 `Local RTMP Server 3.0.dmg`。
2. 雙擊掛載 DMG 檔案。
3. 將 **Local RTMP Server** 應用程式圖示拖曳至 **應用程式 (Applications)** 資料夾中。
4. 從 Launchpad 或應用程式資料夾啟動 App。

> **注意**：如果 macOS 顯示「無法打開未識別開發者的應用程式」的安全性警告，請前往 **系統設定 > 隱私權與安全性**，並點擊 **強制打開 (Open Anyway)**。

## 📖 使用教學

1. **啟動伺服器**：點擊 App 中的「播放 (Play)」按鈕，狀態燈號將會變為綠色。
2. **複製 RTMP 網址**：App 會顯示您目前的本地 IP 位址，請複製該網址 (例如：`rtmp://192.168.1.100/live/mystreamkey`)。
3. **設定 OBS**：
   - 前往 OBS 設定 -> 串流。
   - 服務：`自訂 (Custom)`
   - 伺服器：`rtmp://192.168.1.100/live`
   - 串流金鑰：`mystreamkey`
4. **開始串流**：在 OBS 中按下「開始串流」。
5. **預覽畫面**：點擊 App 中的「預覽串流」按鈕，即可即時監看您的串流畫面。

## 🛠 進階設定
按下 `Cmd + ,` 或點擊齒輪圖示開啟「設定」。
- **串流金鑰類型**：選擇使用固定、好記的金鑰，或是讓 App 每次自動產生一組安全的隨機金鑰。
- **自訂連接埠**：如果與其他服務發生衝突，您可以更改預設的 RTMP 連接埠 (1935) 或 HTTP HLS 連接埠 (8000)。
- **應用程式顯示模式**：切換 App 要完全在背景執行 (選單列模式)，或是作為標準 App 顯示在 Dock 上。

## ⚖️ 授權與版權宣告

本軟體的部分原始碼衍生或啟發自以下開源專案，並基於 MIT 授權條款使用：

1. [mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) 作者：Sallar Kaboli (Copyright (c) 2018)
2. [macos-RTMP-Server](https://github.com/zpqnzpqn/macos-RTMP-Server) 作者：zpqnzpqn (Copyright (c) 2026)

本專案採用 MIT 授權條款 (MIT License)。
