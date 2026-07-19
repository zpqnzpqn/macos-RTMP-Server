const { ipcRenderer, clipboard, shell } = require('electron');
const template = require('lodash/template');
const fs = require('fs');
const path = require('path');
const filesize = require('filesize');
const shortid = require('shortid');
const os = require('os');

let randomStreamKey = shortid.generate();
let streamsTemplate;
const streamsContainer = document.getElementById('streams');

let appSettings = {
  streamKeyType: 'random',
  fixedStreamKey: 'mystreamkey',
  appMode: 'menubar'
};
let lastPort = 8000;

let previewActive = false;

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

      if (streamsTemplate) {
        streamsContainer.innerHTML = streamsTemplate(
          Object.assign({}, res, {
            rtmpUri: 'rtmp://127.0.0.1/live',
            randomStreamKey: activeStreamKey,
            localIps: localIps,
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
  const type = streamKeyTypeSelect.value;
  const fixedKey = fixedStreamKeyInput.value.trim();
  const mode = appModeSelect.value;

  const needsRelaunch = (mode !== appSettings.appMode);

  appSettings.streamKeyType = type;
  appSettings.fixedStreamKey = fixedKey;
  appSettings.appMode = mode;

  ipcRenderer.send('save-settings', appSettings);

  if (needsRelaunch) {
    ipcRenderer.send('relaunch-app');
  } else {
    settingsOverlay.style.display = 'none';
    fetchStreamInfo(lastPort);
  }
});

// HLS Preview Player
function startPreview() {
  const streamKey = getActiveStreamKey();
  const hlsUrl = `http://localhost:${lastPort}/live/${streamKey}/index.m3u8`;

  previewVideo.src = hlsUrl;
  previewVideo.load();
  previewVideo.play().catch(() => {
    // Playback may fail if the HLS segments are not yet available
  });

  previewContainer.style.display = 'flex';
  previewActive = true;
  previewToggleBtn.innerText = '停止預覽';
  previewToggleBtn.className = 'btn-preview-stop';
  previewStatusDot.className = 'preview-status-dot active';
  previewStatusText.innerText = '預覽：播放中';
}

function stopPreview() {
  previewVideo.pause();
  previewVideo.removeAttribute('src');
  previewVideo.load();
  previewContainer.style.display = 'none';
  previewActive = false;
  previewToggleBtn.innerText = '串流預覽';
  previewToggleBtn.className = 'btn-preview-start';
  previewStatusDot.className = 'preview-status-dot';
  previewStatusText.innerText = '預覽：已關閉';
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
    previewStatusDot.className = 'preview-status-dot error';
    previewStatusText.innerText = '預覽：尚無可用串流';
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
