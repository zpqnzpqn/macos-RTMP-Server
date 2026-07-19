const NodeMediaServer = require('node-media-server');
const fs = require('fs');
const { execSync } = require('child_process');

// Parse CLI arguments
const args = process.argv.slice(2);
const options = {
  rtmpPort: 1935,
  httpPort: 8000,
  streamKey: null,
  ffmpegPath: null,
  mediaroot: './media'
};

for (let i = 0; i < args.length; i++) {
  const arg = args[i];
  if (arg === '--rtmp-port' || arg === '-r') {
    options.rtmpPort = parseInt(args[++i], 10);
  } else if (arg === '--http-port' || arg === '-h') {
    options.httpPort = parseInt(args[++i], 10);
  } else if (arg === '--stream-key' || arg === '-k') {
    options.streamKey = args[++i];
  } else if (arg === '--ffmpeg-path' || arg === '-f') {
    options.ffmpegPath = args[++i];
  } else if (arg === '--mediaroot' || arg === '-m') {
    options.mediaroot = args[++i];
  }
}

// Auto-detect FFmpeg path
function getFFmpegPath() {
  if (options.ffmpegPath && fs.existsSync(options.ffmpegPath)) {
    return options.ffmpegPath;
  }
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

// Ensure mediaroot directory exists
if (!fs.existsSync(options.mediaroot)) {
  fs.mkdirSync(options.mediaroot, { recursive: true });
}

// Configure NodeMediaServer
const config = {
  rtmp: {
    port: options.rtmpPort,
    chunk_size: 60000,
    gop_cache: true,
    ping: 60,
    ping_timeout: 30
  },
  http: {
    port: options.httpPort,
    mediaroot: options.mediaroot,
    allow_origin: '*'
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
};

const nms = new NodeMediaServer(config);

// Log and validate connections
nms.on('prePublish', (id, StreamPath, args) => {
  if (options.streamKey) {
    const expectedPath = `/live/${options.streamKey}`;
    if (StreamPath !== expectedPath) {
      console.warn(`[RTMP Reject] Unauthorized stream key attempt: ${StreamPath}. Expected: ${expectedPath}`);
      const session = nms.getSession(id);
      if (session) {
        session.reject();
      }
      return;
    }
  }
  console.log(`[RTMP Accept] Stream published: id=${id} StreamPath=${StreamPath}`);
});

nms.on('donePublish', (id, StreamPath, args) => {
  console.log(`[RTMP Terminate] Stream finished: id=${id} StreamPath=${StreamPath}`);
});

// Run server
nms.run();

console.log(`[RTMP Server] Core started.`);
console.log(` - RTMP Port: ${options.rtmpPort}`);
console.log(` - HTTP Port: ${options.httpPort}`);
console.log(` - FFmpeg Path: ${config.trans.ffmpeg}`);
console.log(` - Media Root: ${options.mediaroot}`);
if (options.streamKey) {
  console.log(` - Enforced Stream Key: ${options.streamKey}`);
} else {
  console.log(` - Stream Key Validation: Disabled (All keys allowed)`);
}

// Zombie Process protection: Check if parent process (PPID) becomes 1 (adopted by init/launchd)
setInterval(() => {
  if (process.ppid === 1) {
    console.log('[RTMP Server] Parent process exited (adopted by init). Exiting...');
    process.exit(0);
  }
}, 2000);

// Clean shutdown signals
process.on('SIGTERM', () => {
  console.log('[RTMP Server] SIGTERM received. Shutting down...');
  process.exit(0);
});
process.on('SIGINT', () => {
  console.log('[RTMP Server] SIGINT received. Shutting down...');
  process.exit(0);
});
