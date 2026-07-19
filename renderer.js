const { ipcRenderer, clipboard, shell } = require('electron');
const template = require('lodash/template');
const fs = require('fs');
const path = require('path');
const filesize = require('filesize');
const shortid = require('shortid');
const os = require('os');
const Hls = require('hls.js');

let randomStreamKey = shortid.generate();
let streamsTemplate;
const streamsContainer = document.getElementById('streams');

let appSettings = {
  streamKeyType: 'random',
  fixedStreamKey: 'mystreamkey',
  appMode: 'menubar',
  language: 'system'
};
let lastPort = 8000;

let previewActive = false;
let hlsPlayer = null;

const locales = {
  en: {
    settings: 'Settings / Preferences',
    streamKeyType: 'Stream Key Type',
    random: 'Random (Auto-generated)',
    fixed: 'Fixed Custom Key',
    fixedStreamKey: 'Fixed Stream Key',
    regenerate: 'Regenerate Random Key',
    appResidence: 'App Residence / Location',
    menubar: 'Menu Bar Tray Icon',
    dock: 'Dock (Standard Window)',
    saveAndRelaunch: 'Save & Restart App',
    close: 'Close Panel',
    noLiveStreams: 'No Live Streams Currently.',
    rtmpPublishUrl: 'RTMP Publish URL:',
    previewActive: 'Preview: Playing Stream',
    previewInactive: 'Preview: Standby / Closed',
    previewError: 'Preview: Stream Unavailable',
    previewBtnStart: 'Stream Preview',
    previewBtnStop: 'Stop Preview',
    obsGuide: 'For virtual webcam, please use',
    obsGuideLink: 'OBS Virtual Camera ↗',
    language: 'Interface Language',
    systemLang: 'System Default Language',
    streamName: 'Name',
    traffic: 'Traffic',
    audio: 'Audio',
    video: 'Video',
    urls: 'URLs',
    clients: 'clients',
    waiting: 'Waiting for stream metadata...'
  },
  zh: {
    settings: '設定與喜好選項',
    streamKeyType: '金鑰類型',
    random: '隨機（自動產生）',
    fixed: '自訂固定金鑰',
    fixedStreamKey: '固定金鑰',
    regenerate: '還原隨機',
    appResidence: '常駐位置',
    menubar: '選單列常駐圖示',
    dock: 'Dock（標準視窗模式）',
    saveAndRelaunch: '儲存並重啟',
    close: '關閉面版',
    noLiveStreams: '目前沒有活躍的串流。',
    rtmpPublishUrl: 'RTMP 推流網址：',
    previewActive: '預覽：串流播放中',
    previewInactive: '預覽：已關閉',
    previewError: '預覽：尚無可用串流',
    previewBtnStart: '串流預覽',
    previewBtnStop: '停止預覽',
    obsGuide: '如需虛擬攝影機，請使用',
    obsGuideLink: 'OBS Virtual Camera ↗',
    language: '介面語系設定',
    systemLang: '系統預設語系',
    streamName: '串流名稱',
    traffic: '傳輸流量',
    audio: '音訊規格',
    video: '視訊規格',
    urls: '串流網址',
    clients: '個用戶連線中',
    waiting: '正在等待串流數據...'
  },
  ja: {
    settings: '設定と環境設定',
    streamKeyType: 'ストリームキーの種類',
    random: 'ランダム（自動生成）',
    fixed: 'カスタム固定キー',
    fixedStreamKey: '固定ストリームキー',
    regenerate: 'ランダムキー再生成',
    appResidence: '常駐場所',
    menubar: 'メニューバー常駐アイコン',
    dock: 'ドック（標準ウィンドウ）',
    saveAndRelaunch: '保存して再起動',
    close: '閉じる',
    noLiveStreams: '現在アクティブな配信はありません。',
    rtmpPublishUrl: 'RTMP 配信URL：',
    previewActive: 'プレビュー：配信再生中',
    previewInactive: 'プレビュー：オフ',
    previewError: 'プレビュー：配信ソースなし',
    previewBtnStart: '配信プレビュー',
    previewBtnStop: 'プレビュー停止',
    obsGuide: '仮想カメラを使用するには、',
    obsGuideLink: 'OBS Virtual Camera ↗',
    language: 'インターフェース言語設定',
    systemLang: 'システムデフォルト言語',
    streamName: '配信名',
    traffic: 'トラフィック',
    audio: '音声情報',
    video: '映像情報',
    urls: '配信URL',
    clients: '接続クライアント',
    waiting: 'ストリーム情報の取得中...'
  }
};

function getSelectedLanguage() {
  let currentLang = appSettings.language || 'system';
  if (currentLang === 'system') {
    const sysLang = navigator.language.toLowerCase();
    if (sysLang.startsWith('zh')) {
      return 'zh';
    } else if (sysLang.startsWith('ja')) {
      return 'ja';
    } else {
      return 'en';
    }
  }
  return currentLang;
}

function applyTranslations() {
  const langKey = getSelectedLanguage();
  const langPack = locales[langKey] || locales.en;

  // Translate static UI elements
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (langPack[key]) {
      if (el.tagName === 'OPTION') {
        el.text = langPack[key];
      } else {
        el.innerText = langPack[key];
      }
    }
  });

  // Re-translate current preview status text
  if (previewActive) {
    previewStatusText.innerText = langPack.previewActive;
    previewToggleBtn.innerText = langPack.previewBtnStop;
  } else {
    previewStatusText.innerText = langPack.previewInactive;
    previewToggleBtn.innerText = langPack.previewBtnStart;
  }
}

function getLocalIPs() {
  const interfaces = os.networkInterfaces();
  const ips = [];
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        ips.push(iface.address);
      }
    }
  }
  return ips.length > 0 ? ips : ['127.0.0.1'];
}

function getActiveStreamKey() {
  return appSettings.streamKeyType === 'fixed'
    ? (appSettings.fixedStreamKey || 'mystreamkey')
    : randomStreamKey;
}

function fetchStreamInfo(port = 8000) {
  lastPort = port;
  fetch(`http://localhost:${port}/api/streams`)
    .then(res => res.json())
    .then(res => {
      const activeStreamKey = getActiveStreamKey();
      const localIps = getLocalIPs();
      const langKey = getSelectedLanguage();

      if (streamsTemplate) {
        streamsContainer.innerHTML = streamsTemplate(
          Object.assign({}, res, {
            rtmpUri: 'rtmp://127.0.0.1/live',
            randomStreamKey: activeStreamKey,
            localIps: localIps,
            lang: locales[langKey] || locales.en,
            tools: {
              filesize
            }
          })
        );
      }
    })
    .catch(() => {
      // NMS HTTP server not ready yet, silently ignore
    });
}

// Event delegation for copy buttons — avoids memory leak from rebinding
streamsContainer.addEventListener('click', e => {
  const copyLink = e.target.closest('.copy');
  if (copyLink) {
    e.preventDefault();
    const code = copyLink.parentElement.querySelector('code');
    if (code) {
      clipboard.writeText(code.innerText);
    }
  }
});

// UI Elements
const settingsBtn = document.getElementById('settingsBtn');
const quitBtn = document.getElementById('quitBtn');
const settingsOverlay = document.getElementById('settingsOverlay');
const closeSettingsBtn = document.getElementById('closeSettingsBtn');
const saveSettingsBtn = document.getElementById('saveSettingsBtn');
const streamKeyTypeSelect = document.getElementById('streamKeyType');
const fixedStreamKeyInput = document.getElementById('fixedStreamKey');
const regenerateRandomBtn = document.getElementById('regenerateRandomBtn');
const appModeSelect = document.getElementById('appMode');
const fixedKeyGroup = document.getElementById('fixedKeyGroup');
const appLanguageSelect = document.getElementById('appLanguage');

// Preview UI Elements
const previewToggleBtn = document.getElementById('previewToggleBtn');
const previewStatusDot = document.getElementById('previewStatusDot');
const previewStatusText = document.getElementById('previewStatusText');
const previewContainer = document.getElementById('previewContainer');
const previewVideo = document.getElementById('previewVideo');
const obsGuideLink = document.getElementById('obsGuideLink');

function toggleFixedKeyInput() {
  const type = streamKeyTypeSelect.value;
  fixedKeyGroup.style.display = type === 'fixed' ? 'flex' : 'none';
}

streamKeyTypeSelect.addEventListener('change', toggleFixedKeyInput);

settingsBtn.addEventListener('click', () => {
  streamKeyTypeSelect.value = appSettings.streamKeyType || 'random';
  fixedStreamKeyInput.value = appSettings.fixedStreamKey || '';
  appModeSelect.value = appSettings.appMode || 'menubar';
  appLanguageSelect.value = appSettings.language || 'system';
  toggleFixedKeyInput();
  settingsOverlay.style.display = 'flex';
});

closeSettingsBtn.addEventListener('click', () => {
  settingsOverlay.style.display = 'none';
});

regenerateRandomBtn.addEventListener('click', () => {
  randomStreamKey = shortid.generate();
  streamKeyTypeSelect.value = 'random';
  toggleFixedKeyInput();
  appSettings.streamKeyType = 'random';
  ipcRenderer.send('save-settings', appSettings);
  settingsOverlay.style.display = 'none';
  fetchStreamInfo(lastPort);
});

saveSettingsBtn.addEventListener('click', () => {
  appSettings.streamKeyType = streamKeyTypeSelect.value;
  appSettings.fixedStreamKey = fixedStreamKeyInput.value.trim();
  appSettings.appMode = appModeSelect.value;
  appSettings.language = appLanguageSelect.value;

  ipcRenderer.send('save-settings', appSettings);
  ipcRenderer.send('relaunch-app');
});

// HLS Preview Player
function startPreview() {
  const streamKey = getActiveStreamKey();
  const hlsUrl = `http://localhost:${lastPort}/live/${streamKey}/index.m3u8`;
  const langPack = locales[getSelectedLanguage()] || locales.en;

  if (Hls.isSupported()) {
    if (hlsPlayer) {
      hlsPlayer.destroy();
    }
    hlsPlayer = new Hls({
      enableWorker: true,
      lowLatencyMode: true
    });
    hlsPlayer.loadSource(hlsUrl);
    hlsPlayer.attachMedia(previewVideo);
    hlsPlayer.on(Hls.Events.MANIFEST_PARSED, () => {
      previewVideo.play().catch(err => console.error('Play failed:', err));
    });
    hlsPlayer.on(Hls.Events.ERROR, (event, data) => {
      if (data.fatal) {
        switch (data.type) {
          case Hls.ErrorTypes.NETWORK_ERROR:
            hlsPlayer.startLoad();
            break;
          case Hls.ErrorTypes.MEDIA_ERROR:
            hlsPlayer.recoverMediaError();
            break;
          default:
            stopPreview();
            break;
        }
      }
    });
  } else if (previewVideo.canPlayType('application/vnd.apple.mpegurl')) {
    // Native iOS/macOS Safari fallback
    previewVideo.src = hlsUrl;
    previewVideo.play().catch(err => console.error('Play failed:', err));
  }

  previewContainer.style.display = 'flex';
  previewActive = true;
  previewToggleBtn.innerText = langPack.previewBtnStop;
  previewToggleBtn.className = 'btn-preview-stop';
  previewStatusDot.className = 'preview-status-dot active';
  previewStatusText.innerText = langPack.previewActive;
}

function stopPreview() {
  if (hlsPlayer) {
    hlsPlayer.destroy();
    hlsPlayer = null;
  }
  const langPack = locales[getSelectedLanguage()] || locales.en;

  previewVideo.pause();
  previewVideo.removeAttribute('src');
  previewVideo.load();
  previewContainer.style.display = 'none';
  previewActive = false;
  previewToggleBtn.innerText = langPack.previewBtnStart;
  previewToggleBtn.className = 'btn-preview-start';
  previewStatusDot.className = 'preview-status-dot';
  previewStatusText.innerText = langPack.previewInactive;
}

previewToggleBtn.addEventListener('click', () => {
  if (previewActive) {
    stopPreview();
  } else {
    startPreview();
  }
});

// OBS guide link — open in external browser
if (obsGuideLink) {
  obsGuideLink.addEventListener('click', e => {
    e.preventDefault();
    shell.openExternal('https://obsproject.com/kb/virtual-camera-guide');
  });
}

// Handle video errors (e.g., stream not available yet)
previewVideo.addEventListener('error', () => {
  if (previewActive) {
    const langPack = locales[getSelectedLanguage()] || locales.en;
    previewStatusDot.className = 'preview-status-dot error';
    previewStatusText.innerText = langPack.previewError;
  }
});

quitBtn.addEventListener('click', () => {
  ipcRenderer.send('quit-app');
});

ipcRenderer.on('port-ready', (e, data) => {
  const { port, appPath, settings } = data;
  if (settings) {
    appSettings = settings;
  }
  applyTranslations(); // Load correct UI language on startup
  streamsTemplate = template(
    fs.readFileSync(
      path.join(appPath, 'assets/streams.ejs'),
      'utf8'
    )
  );
  fetchStreamInfo(port);
  setInterval(() => fetchStreamInfo(port), 5000);
});

ipcRenderer.send('app-ready');
