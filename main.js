const NodeMediaServer = require('node-media-server');
const getPort = require('get-port');
const electron = require('electron');
const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

require('electron-context-menu')();

const { app, BrowserWindow, Tray, Menu, ipcMain } = electron;

const currentStreams = new Set();
const ASSET_PATH = path.join(app.getAppPath(), 'assets');

function getFFmpegPath() {
  if (fs.existsSync('/opt/homebrew/bin/ffmpeg')) {
    return '/opt/homebrew/bin/ffmpeg';
  }
  if (fs.existsSync('/usr/local/bin/ffmpeg')) {
    return '/usr/local/bin/ffmpeg';
  }
  try {
    const resolved = execSync('which ffmpeg', { encoding: 'utf8' }).trim();
    if (resolved) return resolved;
  } catch (e) {}
  return '/usr/local/bin/ffmpeg'; // Fallback
}

// Settings helpers
const settingsFile = path.join(app.getPath('userData'), 'settings.json');
function getSettings() {
  try {
    return JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
  } catch (e) {
    return {
      streamKeyType: 'random', // 'random' | 'fixed'
      fixedStreamKey: 'mystreamkey',
      appMode: 'menubar' // 'menubar' | 'dock'
    };
  }
}
function saveSettings(settings) {
  try {
    const dir = path.dirname(settingsFile);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2), 'utf8');
  } catch (e) {
    console.error('Failed to save settings:', e);
  }
}

let mb = null;
let mainWindow = null;
let settings = getSettings();

function changeMenubarState() {
  if (!mb || !mb.tray) return;
  if (currentStreams.size > 0) {
    mb.tray.setImage(path.resolve(ASSET_PATH, 'img/recording.png'));
  } else {
    mb.tray.setImage(path.resolve(ASSET_PATH, 'img/readyTemplate.png'));
  }
}

(async () => {
  const port = await getPort();

  const nms = new NodeMediaServer({
    rtmp: {
      port: 1935,
      chunk_size: 60000,
      gop_cache: true,
      ping: 60,
      ping_timeout: 30
    },
    http: {
      port,
      mediaroot: './media',
      allow_origin: 'http://localhost'
    },
    trans: {
      ffmpeg: getFFmpegPath(),
      tasks: [
        {
          app: 'live',
          ac: 'aac',
          hls: true,
          hlsFlags: '[hls_time=2:hls_list_size=3:hls_flags=delete_segments]'
        }
      ]
    }
  });

  let rtmpReady = true;

  nms.on('prePublish', id => {
    if (!currentStreams.has(id)) {
      currentStreams.add(id);
    }
    changeMenubarState();
  });

  nms.on('donePublish', id => {
    currentStreams.delete(id);
    changeMenubarState();
  });

  nms.run();

  await app.whenReady();

  if (settings.appMode === 'dock') {
    app.dock.show();
    mainWindow = new BrowserWindow({
      width: 400,
      height: 420,
      resizable: true,
      title: "Local RTMP Server",
      webPreferences: {
        nodeIntegration: true,
        contextIsolation: false
      }
    });
    mainWindow.loadFile(path.join(ASSET_PATH, 'index.html'));
  } else {
    app.dock.hide();
    const { menubar } = require('menubar');
    mb = menubar({
      dir: ASSET_PATH,
      icon: path.resolve(ASSET_PATH, 'img/readyTemplate.png'),
      height: 420,
      transparent: true,
      preloadWindow: true,
      browserWindow: {
        height: 420,
        resizable: true,
        webPreferences: {
          nodeIntegration: true,
          contextIsolation: false
        }
      }
    });

    mb.on('ready', () => {
      changeMenubarState();
    });
  }

  ipcMain.on('app-ready', event => {
    event.sender.send('port-ready', {
      port: port,
      appPath: app.getAppPath(),
      settings: getSettings()
    });
  });

  ipcMain.on('save-settings', (event, newSettings) => {
    saveSettings(newSettings);
    settings = newSettings;
    event.sender.send('settings-saved', newSettings);
  });

  ipcMain.on('relaunch-app', () => {
    app.relaunch();
    app.exit(0);
  });

  ipcMain.on('quit-app', () => {
    app.quit();
  });

  ipcMain.on('error', event => {
    console.error(event);
  });
})();
