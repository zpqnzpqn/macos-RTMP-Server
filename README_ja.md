# macOS ローカル RTMP ストリーミングサーバー（Apple Silicon 版）

**Apple Silicon (M1/M2/M3/M4)** Mac 向けに設計された、軽量でネイティブなローカル RTMP ストリーミングサーバーです。OBS、モバイルデバイス、またはその他の RTMP 対応ソースから Mac に直接配信できます。

> **フォークに関する注意：** 本プロジェクトは、非推奨となった [sallar/mac-local-rtmp-server](https://github.com/sallar/mac-local-rtmp-server) のアクティブにメンテナンスされているフォーク版であり、Apple Silicon 用に再構築され、多数の新機能とバグ修正が含まれています。

[English](README.md) | [繁體中文](README_zh-TW.md) | **日本語** | [Español](README_es.md) | [Français](README_fr.md)

## ✨ 主な機能

- **ネイティブ Apple Silicon 対応** — M1/M2/M3/M4 Mac 上でネイティブ動作（ARM64）
- **ワンクリックで RTMP 起動** — アプリ起動後、すぐにポート 1935 でローカル RTMP サーバーを開始
- **ネットワーク IP 自動検出** — すべてのローカル IPv4 アドレス（Wi-Fi、有線LANなど）を自動検出し、コピー可能なフル RTMP URL を表示
- **ストリームキー管理** — ランダム（自動生成）またはカスタム固定ストリームキーの選択が可能
- **HLS 即時プレビュー** — アプリ内に組み込まれた HLS プレイヤーを使用して、配信中の映像を直接プレビュー可能
- **メニューバーとドックモード** — メニューバー常駐（軽量モード）またはドック常駐（標準ウィンドウモード）の切り替えに対応
- **マルチストリーム対応** — 複数の同時 RTMP ストリームを受信・処理可能
- **リアルタイムストリーム情報** — 稼働中の各配信のコーデック、解像度、フレームレート、データトラフィック、クライアント接続数を表示

## 📋 システム要件

- **macOS** 11.0 (Big Sur) 以降
- **Apple Silicon** Mac (M1/M2/M3/M4) — ※Intel Mac では Rosetta 経由で動作
- **FFmpeg** (HLS トランスコーディングに必要)

### FFmpeg のインストール

```bash
brew install ffmpeg
```

## 📦 インストール方法

### 方法 1：DMG インストーラーからインストール（推奨）

1. [Releases ページ](https://github.com/zpqnzpqn/macos-RTMP-Server/releases) から最新の `.dmg` ファイルをダウンロードします。
2. DMG ファイルを開き、アプリケーションフォルダにドラッグ＆ドロップします。
3. **Local RTMP Server** を起動します。

> **注意：** 本アプリは Apple によるデジタル署名がされていないため、初回起動時に「右クリック → 開く」を押すか、「システム設定 → プライバシーとセキュリティ → このまま開く」を選択する必要があります。

### 方法 2：ソースコードからビルド

```bash
git clone https://github.com/zpqnzpqn/macos-RTMP-Server.git
cd macos-RTMP-Server
npm install
npm start        # 開発モードで実行
npm run dist     # ARM64 向け DMG のパッケージング
```

## 🚀 使用方法

### 基本的な配信方法

1. アプリを起動すると、自動的にポート `1935` で RTMP サーバーが開始されます。
2. 画面に表示された RTMP URL（例：`rtmp://192.168.1.100/live/abc123`）をコピーします。
3. 配信ソフト（OBS、Streamlabs など）側で：
   - **サーバー** にコピーした URL を設定します
   - 別途「ストリームキー」を入力する必要はありません（URL 内に含まれています）
4. 配信を開始すると、アプリ内にリアルタイムで統計情報が表示されます。

### 他のデバイスから配信する

同じネットワーク内にある別のデバイス（[Larix Broadcaster](https://wmspanel.com/larix_broadcaster) を使用するスマートフォンなど）から配信する場合：

1. アプリに表示された、Mac のローカル IP アドレスを含む RTMP URL を使用します。
2. 両方のデバイスが同じ Wi-Fi / 局内ネットワークに接続されていることを確認してください。

### 配信をプレビューする

**「配信プレビュー (Stream Preview)」** ボタンをクリックすると、アプリ内で即時に HLS ライブ映像を視聴できます。

### 仮想カメラの使用（OBS 経由）

RTMP 配信を Zoom、Google Meet、Teams などの仮想ウェブカメラとして使用したい場合：

1. **OBS Studio** を起動します（[ダウンロードはこちら](https://obsproject.com/)）
2. **メディアソース** を追加し、RTMP URL を入力します
3. OBS 画面で **「仮想カメラ開始 (Start Virtual Camera)」** をクリックします
4. Zoom または Meet 側で、カメラデバイスとして **「OBS Virtual Camera」** を選択します

アプリ下部に [OBS 仮想カメラ設定ガイド](https://obsproject.com/kb/virtual-camera-guide) への直リンクを用意しています。

## ⚙️ 環境設定

**歯車アイコン**（⚙️）をクリックして設定を開きます：

| 設定項目 | 選択肢 | 説明 |
|----------|--------|------|
| ストリームキー | ランダム / 固定 | ランダムは起動ごとにキーを自動生成；固定は任意のカスタムキーを維持します |
| 常駐場所 | メニューバー / ドック | アプリの配置先を設定 — メニューバー常駐または標準ドックウィンドウ |
| 言語設定 | システムデフォルト / 英語 / 繁体字中国語 / 日本語 / スペイン語 / フランス語 | アプリケーションの表示言語を切り替えます |

> 常駐場所および言語設定の変更を適用するには、アプリの再起動が必要です（保存時に自動で処理されます）。

## 🔒 セキュリティに関する注意

- **ローカルネットワーク専用** — 本 RTMP サーバーは信頼できるローカルネットワーク内での使用を想定しています。RTMP ポートに対する認証機能はありません。
- **インターネット公開の禁止** — ファイアウォールや VPN などの保護手段なしで、ポート 1935 をインターネット上に直接公開しないでください。

## 🛠 技術仕様

| コンポーネント | 採用技術 |
|----------------|----------|
| フレームワーク | Electron 30 |
| RTMP エンジン | Node-Media-Server |
| 変換処理 | FFmpeg (HLS) |
| UI | ネイティブ HTML / CSS / JS |
| プラットフォーム | macOS ARM64 (Apple Silicon) |

## 📄 ライセンス

本プロジェクトは [MIT License](LICENSE) に基づいてリリースされています。

Original Creator: [Sallar Kaboli](https://github.com/sallar)
This fork is maintained by [zpqnzpqn](https://github.com/zpqnzpqn).
